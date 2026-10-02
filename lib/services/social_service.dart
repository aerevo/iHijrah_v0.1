// lib/services/social_service.dart
// Akses Firestore untuk interaksi sosial (like → comment → reply).
//
// Prinsip:
// → Kaunter `posts.likes` TIDAK pernah ditulis bebas. Setiap perubahan
//   ialah increment(±1) dalam transaction yang sama dgn create/delete
//   dokumen posts/{postId}/likes/{uid}; firestore.rules menguatkuasakan
//   pasangan ini (existsAfter/getAfter) — client tak boleh memintas.
// → Ralat dipulangkan sbg Result<_, SocialFailure>, bukan ditelan.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/comment_model.dart';
import '../utils/bounded_timeout.dart';
import '../utils/result.dart';
import 'social_failure.dart';

/// Hasil [SocialService.purgeMySocialContent] — untuk diagnostik padam
/// akaun. `isClean == false` bermakna ada kandungan pengguna yang MASIH
/// tertinggal (bukan "berjaya sepenuhnya").
class SocialCleanupReport {
  const SocialCleanupReport({
    required this.postsScanned,
    required this.likesRemoved,
    required this.commentsRemoved,
    required this.repliesRemoved,
    required this.failedCount,
    required this.failedPaths,
    required this.scanComplete,
  });

  final int postsScanned;
  final int likesRemoved;
  final int commentsRemoved;
  final int repliesRemoved;

  /// Jumlah item yang gagal dipadam / gagal disenaraikan.
  final int failedCount;

  /// Contoh laluan yang gagal (dihadkan supaya laporan tidak membengkak).
  final List<String> failedPaths;

  /// false jika imbasan berhenti awal (had post, had masa, atau ralat
  /// membaca senarai) — kandungan yang belum diimbas tidak diketahui.
  final bool scanComplete;

  int get itemsRemoved => likesRemoved + commentsRemoved + repliesRemoved;

  bool get isClean => scanComplete && failedCount == 0;
}

class _PurgeTally {
  _PurgeTally(this._budget) {
    _clock.start();
  }

  static const int _maxFailedPaths = 50;

  final Duration _budget;
  final Stopwatch _clock = Stopwatch();

  int postsScanned = 0;
  int likesRemoved = 0;
  int commentsRemoved = 0;
  int repliesRemoved = 0;
  int failedCount = 0;
  bool scanComplete = true;
  bool stopped = false;
  final List<String> failedPaths = <String>[];

  void fail(String path) {
    failedCount++;
    if (failedPaths.length < _maxFailedPaths) {
      failedPaths.add(path);
    }
  }

  /// Had masa untuk satu operasi rangkaian: [cap] tetapi tidak melebihi
  /// baki bajet. Zero = bajet habis (jangan mulakan operasi).
  Duration opTimeout(Duration cap) =>
      boundedOpTimeout(remaining: _budget - _clock.elapsed, cap: cap);

  /// true (dan imbasan ditanda tak lengkap) apabila bajet masa habis.
  bool outOfBudget() {
    if (stopped) {
      return true;
    }
    if (_clock.elapsed > _budget) {
      stopped = true;
      scanComplete = false;
      return true;
    }
    return false;
  }

  SocialCleanupReport toReport() => SocialCleanupReport(
        postsScanned: postsScanned,
        likesRemoved: likesRemoved,
        commentsRemoved: commentsRemoved,
        repliesRemoved: repliesRemoved,
        failedCount: failedCount,
        failedPaths: List<String>.unmodifiable(failedPaths),
        scanComplete: scanComplete,
      );
}

class SocialService {
  SocialService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Instance kongsi. Dicipta lazily (selepas Firebase.initializeApp).
  static final SocialService instance = SocialService();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  /// uid pengguna semasa (untuk tunjuk butang padam pada komen sendiri).
  String? get currentUid => _uid;

  DocumentReference<Map<String, dynamic>> _post(String postId) =>
      _db.collection('posts').doc(postId);

  // ── LIKE ─────────────────────────────────────────────────────

  /// Stream: adakah pengguna semasa sudah like post ini?
  /// (Dokumen like sendiri sahaja boleh dibaca — lihat rules.)
  Stream<bool> watchLiked(String postId) {
    final String? uid = _uid;
    if (uid == null) return Stream<bool>.value(false);
    return _post(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((s) => s.exists);
  }

  /// Like / unlike secara idempotent. Transaction membaca dokumen like
  /// dulu: like pada post yang sudah di-like (atau unlike pada yang
  /// belum) jadi no-op — tiada duplicate, kaunter tak drift.
  Future<Result<bool, SocialFailure>> setLiked(
    String postId, {
    required bool like,
  }) async {
    final String? uid = _uid;
    if (uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }

    final DocumentReference<Map<String, dynamic>> postRef = _post(postId);
    final DocumentReference<Map<String, dynamic>> likeRef =
        postRef.collection('likes').doc(uid);

    try {
      await _db.runTransaction<void>((Transaction tx) async {
        final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(likeRef);
        if (like) {
          if (snap.exists) return;
          tx.set(likeRef, <String, dynamic>{
            'createdAt': FieldValue.serverTimestamp(),
          });
          tx.update(postRef, <String, dynamic>{'likes': FieldValue.increment(1)});
        } else {
          if (!snap.exists) return;
          tx.delete(likeRef);
          tx.update(postRef, <String, dynamic>{'likes': FieldValue.increment(-1)});
        }
      });
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('SocialService.setLiked gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  // ── COMMENT ──────────────────────────────────────────────────
  // Kiraan komen TIDAK disimpan pada post: diambil dgn aggregate
  // count() (dikira pelayan → tak boleh dimanipulasi / drift).

  CollectionReference<Map<String, dynamic>> _comments(String postId) =>
      _post(postId).collection('comments');

  /// Komen terbaru dahulu, maks [limit]. (Pagination bukan skop Phase 1.)
  Stream<List<CommentModel>> watchComments(String postId, {int limit = 100}) {
    return _comments(postId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map(CommentModel.fromDoc).toList());
  }

  /// null = gagal dikira (UI sembunyikan kiraan, bukan tunjuk 0 palsu).
  Future<int?> commentCount(String postId) async {
    try {
      final AggregateQuerySnapshot agg = await _comments(postId).count().get();
      return agg.count;
    } catch (e) {
      debugPrint('SocialService.commentCount gagal: $e');
      return null;
    }
  }

  /// [authorName] mesti sama dgn nama profil (rules menyemak); kosong →
  /// 'Hamba Allah', sama seperti create post.
  Future<Result<bool, SocialFailure>> addComment(
    String postId, {
    required String content,
    required String authorName,
  }) async {
    final String? uid = _uid;
    if (uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    try {
      await _comments(postId).add(<String, dynamic>{
        'authorId': uid,
        'author': authorName.isEmpty ? 'Hamba Allah' : authorName,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('SocialService.addComment gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  Future<Result<bool, SocialFailure>> deleteComment(
    String postId,
    String commentId,
  ) async {
    if (_uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    try {
      await _comments(postId).doc(commentId).delete();
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('SocialService.deleteComment gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  // ── REPLY (satu tahap: posts/{p}/comments/{c}/replies/{r}) ───

  CollectionReference<Map<String, dynamic>> _replies(
          String postId, String commentId) =>
      _comments(postId).doc(commentId).collection('replies');

  /// Reply paling lama dahulu (susunan perbualan), maks [limit].
  Stream<List<CommentModel>> watchReplies(
    String postId,
    String commentId, {
    int limit = 50,
  }) {
    return _replies(postId, commentId)
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map(CommentModel.fromDoc).toList());
  }

  Future<Result<bool, SocialFailure>> addReply(
    String postId,
    String commentId, {
    required String content,
    required String authorName,
  }) async {
    final String? uid = _uid;
    if (uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    try {
      await _replies(postId, commentId).add(<String, dynamic>{
        'authorId': uid,
        'author': authorName.isEmpty ? 'Hamba Allah' : authorName,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('SocialService.addReply gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  Future<Result<bool, SocialFailure>> deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    if (_uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    try {
      await _replies(postId, commentId).doc(replyId).delete();
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('SocialService.deleteReply gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  // ── PADAM AKAUN: BERSIHKAN KANDUNGAN SOSIAL SAYA ─────────────
  //
  // Apa yang rules BENARKAN pengguna padam sendiri (dan hanya itu):
  //   • like sendiri  — mesti berpasangan dgn kaunter (setLiked)
  //   • komen sendiri, reply sendiri — di post MANA-MANA
  // Apa yang TIDAK boleh (perlu backend berkeistimewaan): like / komen /
  // reply ORANG LAIN, termasuk yang berada di bawah post milik pengguna
  // ini — tiada siapa selain penulisnya boleh memadamnya.
  //
  // Rules tiada laluan carian merentas post (tiada collection-group,
  // dokumen like tiada medan uid), jadi satu-satunya cara yang selamat
  // ialah mengimbas koleksi posts berhalaman dan menyoal setiap post.
  // Kos ∝ jumlah post + komen — sebab itu ada had post dan bajet masa
  // (tetingkap recent-auth 5 minit utk padam profil/users mesti kekal
  // terbuka selepas ini). Jika had dicapai, laporan ditanda TIDAK bersih.

  static const int _purgePageSize = 100;
  static const int _purgeMaxPosts = 5000;
  static const int _purgeConcurrency = 10;
  static const Duration _purgeTimeBudget = Duration(seconds: 120);

  /// Had atas satu operasi rangkaian dalam purge. Had sebenar ialah
  /// min(had ini, baki bajet 120s) — lihat [_purgeOp].
  static const Duration _purgeOpTimeout = Duration(seconds: 30);

  /// Bacaan KRITIKAL padam akaun: pelayan sahaja. Jika pelayan tak dapat
  /// dicapai ia melempar (unavailable) — TIDAK jatuh ke cache. Hasil cache
  /// (mungkin kosong/lapuk) tak boleh dianggap muktamad semasa memadam.
  static const GetOptions _serverOnly = GetOptions(source: Source.server);

  /// Jalankan satu operasi rangkaian dalam purge dengan had masa
  /// min(_purgeOpTimeout, baki bajet). Melempar [TimeoutException] jika
  /// bajet sudah habis atau operasi tidak selesai dalam had — pemanggil
  /// merekodnya sebagai kegagalan/tidak lengkap (TIDAK pernah sebagai
  /// kosong/berjaya).
  ///
  /// NOTA: timeout hanya berhenti MENUNGGU; ia tak membatalkan operasi
  /// asas. Tulis yang beratur boleh siap kemudian — memang yang dikehendaki
  /// (padam itu idempoten), tetapi laporan tetap mencatatnya sebagai gagal.
  Future<R> _purgeOp<R>(_PurgeTally t, Future<R> Function() op) async {
    final Duration limit = t.opTimeout(_purgeOpTimeout);
    if (limit <= Duration.zero) {
      t.scanComplete = false;
      t.stopped = true;
      throw TimeoutException('Bajet purge habis', _purgeTimeBudget);
    }
    return op().timeout(limit);
  }

  /// Padam like / komen / reply milik pengguna semasa pada SEMUA post
  /// (termasuk post sendiri, sebelum post itu dipadam).
  ///
  /// Pulangkan failure HANYA jika imbasan tak dapat bermula (belum ada
  /// apa dipadam). Kegagalan selepas itu direkod dalam
  /// [SocialCleanupReport] (best-effort, sama seperti edge follow) —
  /// caller mesti menyemak [SocialCleanupReport.isClean].
  Future<Result<SocialCleanupReport, SocialFailure>>
      purgeMySocialContent() async {
    final String? me = _uid;
    if (me == null) {
      return Result<SocialCleanupReport, SocialFailure>.failure(
        SocialFailure.unauthenticated,
      );
    }

    final _PurgeTally tally = _PurgeTally(_purgeTimeBudget);
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    bool firstPage = true;

    while (true) {
      if (tally.outOfBudget()) {
        break;
      }

      Query<Map<String, dynamic>> query = _db
          .collection('posts')
          .orderBy(FieldPath.documentId)
          .limit(_purgePageSize);
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      QuerySnapshot<Map<String, dynamic>>? page;
      Object? pageError;
      try {
        page = await _purgeOp(tally, () => query.get(_serverOnly));
      } catch (e) {
        pageError = e;
      }

      if (page == null) {
        debugPrint('SocialService.purge: senarai post gagal: $pageError');
        if (firstPage) {
          return Result<SocialCleanupReport, SocialFailure>.failure(
            pageError is TimeoutException
                ? SocialFailure.network
                : socialFailureFromError(pageError ?? StateError('page null')),
          );
        }
        tally.scanComplete = false;
        tally.fail('posts (senarai selepas ${cursor?.id})');
        break;
      }
      firstPage = false;
      if (page.docs.isEmpty) {
        break;
      }

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = page.docs;
      for (var i = 0; i < docs.length; i += _purgeConcurrency) {
        if (tally.outOfBudget()) {
          break;
        }
        if (tally.postsScanned >= _purgeMaxPosts) {
          tally.scanComplete = false;
          tally.stopped = true;
          break;
        }
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> chunk =
            docs.skip(i).take(_purgeConcurrency).toList();
        tally.postsScanned += chunk.length;
        await Future.wait(
          chunk.map((d) => _purgeMyContentInPost(d.id, me, tally)),
        );
      }
      if (tally.stopped) {
        break;
      }

      cursor = docs.last;
      if (docs.length < _purgePageSize) {
        break;
      }
    }

    return Result<SocialCleanupReport, SocialFailure>.success(
      tally.toReport(),
    );
  }

  /// Satu post: like saya → komen & reply saya. Tidak melempar; semua
  /// kegagalan direkod dalam [t].
  Future<void> _purgeMyContentInPost(
    String postId,
    String me,
    _PurgeTally t,
  ) async {
    // 1. Like saya. Guna setLiked(false) supaya delete like + kaunter
    //    kekal berpasangan seperti yang dikuatkuasakan rules.
    try {
      final DocumentSnapshot<Map<String, dynamic>> likeSnap = await _purgeOp(
        t,
        () => _post(postId).collection('likes').doc(me).get(_serverOnly),
      );
      if (likeSnap.exists) {
        // setLiked() TIDAK diubah (transaksi berpasangan kaunter kekal);
        // hanya penantiannya dihadkan di sini, pada laluan padam sahaja.
        final Result<bool, SocialFailure> r =
            await _purgeOp(t, () => setLiked(postId, like: false));
        if (r.isSuccess) {
          t.likesRemoved++;
        } else {
          t.fail('posts/$postId/likes/$me');
        }
      }
    } catch (e) {
      debugPrint('SocialService.purge: like $postId gagal: $e');
      t.fail('posts/$postId/likes/$me');
    }

    // 2. Semua komen post ini (berhalaman): reply saya dipadam dulu,
    //    kemudian komen saya sendiri.
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      if (t.outOfBudget()) {
        return;
      }

      Query<Map<String, dynamic>> query = _comments(postId)
          .orderBy(FieldPath.documentId)
          .limit(_purgePageSize);
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }
      final QuerySnapshot<Map<String, dynamic>>? page =
          await _tryGet(query, t);
      if (page == null) {
        t.scanComplete = false;
        t.fail('posts/$postId/comments (senarai)');
        return;
      }
      if (page.docs.isEmpty) {
        return;
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> c in page.docs) {
        if (t.outOfBudget()) {
          return;
        }
        await _purgeMyRepliesUnder(postId, c.id, me, t);
        if (c.data()['authorId'] == me) {
          try {
            await _purgeOp(t, () => c.reference.delete());
            t.commentsRemoved++;
          } catch (e) {
            debugPrint('SocialService.purge: komen ${c.id} gagal: $e');
            t.fail('posts/$postId/comments/${c.id}');
          }
        }
      }

      cursor = page.docs.last;
      if (page.docs.length < _purgePageSize) {
        return;
      }
    }
  }

  /// Reply milik saya di bawah satu komen (komen sesiapa). Batch < had 500.
  Future<void> _purgeMyRepliesUnder(
    String postId,
    String commentId,
    String me,
    _PurgeTally t,
  ) async {
    final Set<String> seen = <String>{};
    while (true) {
      final QuerySnapshot<Map<String, dynamic>>? page = await _tryGet(
        _replies(postId, commentId)
            .where('authorId', isEqualTo: me)
            .limit(_purgePageSize),
        t,
      );
      if (page == null) {
        t.scanComplete = false;
        t.fail('posts/$postId/comments/$commentId/replies (senarai)');
        return;
      }

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> fresh =
          page.docs.where((d) => !seen.contains(d.id)).toList();
      if (fresh.isEmpty) {
        return;
      }

      try {
        final WriteBatch batch = _db.batch();
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in fresh) {
          seen.add(d.id);
          batch.delete(d.reference);
        }
        await _purgeOp(t, () => batch.commit());
        t.repliesRemoved += fresh.length;
      } catch (e) {
        debugPrint(
          'SocialService.purge: reply $postId/$commentId gagal: $e',
        );
        t.fail('posts/$postId/comments/$commentId/replies (padam)');
        return;
      }

      if (page.docs.length < _purgePageSize) {
        return;
      }
    }
  }

  /// Bacaan senarai dalam purge: pelayan sahaja + berhad masa. Kegagalan
  /// (termasuk timeout / pelayan tak dapat dicapai) dipulangkan sebagai
  /// null — pemanggil menandakan imbasan TIDAK lengkap; ia tak pernah
  /// ditafsir sebagai senarai kosong.
  Future<QuerySnapshot<Map<String, dynamic>>?> _tryGet(
    Query<Map<String, dynamic>> query,
    _PurgeTally t,
  ) async {
    try {
      return await _purgeOp(t, () => query.get(_serverOnly));
    } catch (e) {
      debugPrint('SocialService.purge: query gagal: $e');
      return null;
    }
  }
}
