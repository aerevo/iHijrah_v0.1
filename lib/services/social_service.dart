// lib/services/social_service.dart
// Akses Firestore untuk interaksi sosial (like → comment → reply).
//
// Prinsip:
// → Kaunter `posts.likes` TIDAK pernah ditulis bebas. Setiap perubahan
//   ialah increment(±1) dalam transaction yang sama dgn create/delete
//   dokumen posts/{postId}/likes/{uid}; firestore.rules menguatkuasakan
//   pasangan ini (existsAfter/getAfter) — client tak boleh memintas.
// → Ralat dipulangkan sbg Result<_, SocialFailure>, bukan ditelan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/comment_model.dart';
import '../utils/result.dart';
import 'social_failure.dart';

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
}
