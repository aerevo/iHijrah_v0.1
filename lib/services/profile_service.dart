// lib/services/profile_service.dart
// Akses Firestore untuk profil awam (profiles/{uid}) dan follow
// (follows/{followerId}_{followeeId}).
//
// Prinsip (dikuatkuasakan oleh firestore.rules, bukan sekadar client):
// → Profil awam = nama + bio + followersCount SAHAJA. Data peribadi kekal
//   dalam users/{uid} (owner-only).
// → `followersCount` TIDAK pernah ditulis bebas. Setiap perubahan ialah
//   increment(±1) dalam batch yang sama dgn create/delete edge follow.
// → Follow satu arah (Follow != Friend). Senarai follow hanya boleh
//   dibaca pihak terlibat; kiraan awam datang dari profiles.followersCount.
// → Ralat dipulangkan sbg Result<_, SocialFailure>, bukan ditelan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/profile_model.dart';
import '../utils/result.dart';
import 'social_failure.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Instance kongsi. Dicipta lazily (selepas Firebase.initializeApp).
  static final ProfileService instance = ProfileService();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // Had mesti sepadan dgn firestore.rules (validProfileName/Bio).
  static const int maxNameLength = 120;
  static const int maxBioLength = 300;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _db.collection('profiles').doc(uid);

  CollectionReference<Map<String, dynamic>> get _follows =>
      _db.collection('follows');

  // ID edge tetap: '{followerId}_{followeeId}' (rules menyemaknya).
  DocumentReference<Map<String, dynamic>> _edge(
    String followerId,
    String followeeId,
  ) =>
      _follows.doc('${followerId}_$followeeId');

  // ── Pembersihan input ────────────────────────────────────────

  static String _truncate(String s, int max) {
    if (s.runes.length <= max) return s;
    return String.fromCharCodes(s.runes.take(max));
  }

  /// Nama kosong → 'Hamba Allah' (sama seperti post/komen).
  @visibleForTesting
  static String cleanName(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) return 'Hamba Allah';
    return _truncate(t, maxNameLength);
  }

  @visibleForTesting
  static String cleanBio(String raw) => _truncate(raw.trim(), maxBioLength);

  // ── PROFIL AWAM ──────────────────────────────────────────────

  /// Cipta profil awam kalau belum ada; kalau sudah ada dan nama/bio
  /// berbeza, kemas kini. Selamat dipanggil berulang (idempotent).
  /// Rules: hanya boleh dicipta SELEPAS e-mel disahkan — sebelum itu
  /// pulangkan failure (bukan crash).
  Future<Result<bool, SocialFailure>> ensureMyProfile({
    required String name,
    required String bio,
  }) async {
    final String? uid = _uid;
    if (uid == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    final String n = cleanName(name);
    final String b = cleanBio(bio);
    try {
      final DocumentReference<Map<String, dynamic>> ref = _profile(uid);
      final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
      if (!snap.exists) {
        await ref.set(<String, dynamic>{
          'name': n,
          'bio': b,
          'followersCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final Map<String, dynamic> d = snap.data() ?? <String, dynamic>{};
        if (d['name'] != n || d['bio'] != b) {
          await ref.update(<String, dynamic>{'name': n, 'bio': b});
        }
      }
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('ProfileService.ensureMyProfile gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  /// Profil seseorang. Data null = profil belum wujud / sudah dipadam
  /// (UI patut papar 'Pengguna tidak dijumpai', bukan crash).
  Future<Result<ProfileModel?, SocialFailure>> getProfile(String uid) async {
    if (_uid == null) {
      return Result<ProfileModel?, SocialFailure>.failure(
        SocialFailure.unauthenticated,
      );
    }
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _profile(uid).get();
      return Result<ProfileModel?, SocialFailure>.success(
        snap.exists ? ProfileModel.fromDoc(snap) : null,
      );
    } catch (e) {
      debugPrint('ProfileService.getProfile gagal: $e');
      return Result<ProfileModel?, SocialFailure>.failure(
        socialFailureFromError(e),
      );
    }
  }

  /// Stream profil (kiraan pengikut dikemas kini secara langsung).
  Stream<ProfileModel?> watchProfile(String uid) {
    return _profile(uid)
        .snapshots()
        .map((s) => s.exists ? ProfileModel.fromDoc(s) : null);
  }

  // ── FOLLOW ───────────────────────────────────────────────────

  /// Stream: adakah pengguna semasa mengikuti [targetUid]?
  /// (Query dua penapis sama-dengan — rules benarkan kerana followerId
  /// sama dgn uid sendiri; tiada indeks komposit diperlukan.)
  Stream<bool> watchIsFollowing(String targetUid) {
    final String? uid = _uid;
    if (uid == null) return Stream<bool>.value(false);
    return _follows
        .where('followerId', isEqualTo: uid)
        .where('followeeId', isEqualTo: targetUid)
        .limit(1)
        .snapshots()
        .map((q) => q.docs.isNotEmpty);
  }

  /// Follow / unfollow secara idempotent. Semak status dulu: follow pada
  /// yang sudah diikuti (atau unfollow pada yang belum) jadi no-op.
  /// Edge + kaunter ditulis dalam SATU batch (atomik); rules menolak
  /// kalau pasangan itu tak sepadan.
  Future<Result<bool, SocialFailure>> setFollowing(
    String targetUid, {
    required bool follow,
  }) async {
    final String? me = _uid;
    if (me == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }
    if (targetUid.isEmpty || targetUid == me) {
      return Result<bool, SocialFailure>.failure(
        SocialFailure.permissionDenied,
      );
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> existing = await _follows
          .where('followerId', isEqualTo: me)
          .where('followeeId', isEqualTo: targetUid)
          .limit(1)
          .get();
      final bool alreadyFollowing = existing.docs.isNotEmpty;
      if (alreadyFollowing == follow) {
        return Result<bool, SocialFailure>.success(true);
      }

      final DocumentReference<Map<String, dynamic>> edge = _edge(me, targetUid);
      final DocumentReference<Map<String, dynamic>> targetProfile =
          _profile(targetUid);
      final WriteBatch batch = _db.batch();

      if (follow) {
        // Rules mewajibkan profil awam KEDUA-DUA pihak wujud. Kalau profil
        // sendiri belum sempat dicipta (cth. offline semasa HomePage
        // dibuka), pulangkan conflict → UI: 'Cuba lagi'.
        final DocumentSnapshot<Map<String, dynamic>> mine =
            await _profile(me).get();
        if (!mine.exists) {
          return Result<bool, SocialFailure>.failure(SocialFailure.conflict);
        }
        batch.set(edge, <String, dynamic>{
          'followerId': me,
          'followeeId': targetUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.update(targetProfile, <String, dynamic>{
          'followersCount': FieldValue.increment(1),
        });
      } else {
        batch.delete(edge);
        // Profil sasaran sudah dipadam (akaun dipadam) → edge yatim
        // dipadam tanpa kaunter; rules membenarkannya.
        final DocumentSnapshot<Map<String, dynamic>> target =
            await targetProfile.get();
        if (target.exists) {
          batch.update(targetProfile, <String, dynamic>{
            'followersCount': FieldValue.increment(-1),
          });
        }
      }

      await batch.commit();
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('ProfileService.setFollowing gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }

  /// Orang yang mengikut SAYA (terbaru dahulu). Disusun di client kerana
  /// query + orderBy memerlukan indeks komposit; pagination kemudian.
  Stream<List<FollowEdge>> watchMyFollowers({int limit = 100}) {
    final String? uid = _uid;
    if (uid == null) return Stream<List<FollowEdge>>.value(<FollowEdge>[]);
    return _follows
        .where('followeeId', isEqualTo: uid)
        .limit(limit)
        .snapshots()
        .map((q) => _sortedEdges(q, otherIsFollowee: false));
  }

  /// Orang yang SAYA ikut (terbaru dahulu).
  Stream<List<FollowEdge>> watchMyFollowing({int limit = 100}) {
    final String? uid = _uid;
    if (uid == null) return Stream<List<FollowEdge>>.value(<FollowEdge>[]);
    return _follows
        .where('followerId', isEqualTo: uid)
        .limit(limit)
        .snapshots()
        .map((q) => _sortedEdges(q, otherIsFollowee: true));
  }

  List<FollowEdge> _sortedEdges(
    QuerySnapshot<Map<String, dynamic>> q, {
    required bool otherIsFollowee,
  }) {
    final List<FollowEdge> list = q.docs
        .map((d) => FollowEdge.fromDoc(d, otherIsFollowee: otherIsFollowee))
        .where((e) => e.otherUid.isNotEmpty)
        .toList();
    list.sort((a, b) {
      final DateTime? ta = a.createdAt;
      final DateTime? tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1; // tulisan tempatan (belum disahkan) di atas
      if (tb == null) return 1;
      return tb.compareTo(ta);
    });
    return list;
  }

  /// Bilangan orang yang saya ikut (aggregate count — dikira pelayan).
  /// null = gagal dikira (UI sembunyikan kiraan, bukan tunjuk 0 palsu).
  Future<int?> myFollowingCount() async {
    final String? uid = _uid;
    if (uid == null) return null;
    try {
      final AggregateQuerySnapshot agg =
          await _follows.where('followerId', isEqualTo: uid).count().get();
      return agg.count;
    } catch (e) {
      debugPrint('ProfileService.myFollowingCount gagal: $e');
      return null;
    }
  }

  // ── PADAM AKAUN ──────────────────────────────────────────────

  /// Dipanggil oleh UserModel.deleteAccount SELEPAS reauth berjaya dan
  /// SEBELUM users/{uid} + akaun Auth dipadam.
  ///
  /// 1. Unfollow semua yang saya ikut (kaunter mereka dikurangkan) —
  ///    BEST-EFFORT: edge yang gagal dilangkau (dilog), tidak menghalang
  ///    pemadaman akaun. Akibatnya kaunter followee mungkin terlebih 1
  ///    untuk edge yang gagal — dikenal pasti sebagai had reka bentuk
  ///    tanpa Cloud Function.
  /// 2. Padam profil awam sendiri — WAJIB berjaya (kalau gagal, pulangkan
  ///    failure supaya caller tak teruskan padam akaun separuh jalan).
  ///
  /// Edge di mana orang LAIN mengikut saya tidak boleh dipadam dari sini
  /// (rules: hanya follower boleh padam edge). Ia menjadi yatim; pengikut
  /// itu boleh membersihkannya sendiri bila unfollow.
  Future<Result<bool, SocialFailure>> deleteMyProfileAndEdges() async {
    final String? me = _uid;
    if (me == null) {
      return Result<bool, SocialFailure>.failure(SocialFailure.unauthenticated);
    }

    try {
      final Set<String> seen = <String>{};
      while (true) {
        final QuerySnapshot<Map<String, dynamic>> page =
            await _follows.where('followerId', isEqualTo: me).limit(100).get();
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> fresh =
            page.docs.where((d) => !seen.contains(d.id)).toList();
        if (fresh.isEmpty) break; // habis, atau semua yang tinggal gagal

        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in fresh) {
          seen.add(doc.id);
          final String target = (doc.data()['followeeId'] as String?) ?? '';
          try {
            final WriteBatch batch = _db.batch();
            batch.delete(doc.reference);
            if (target.isNotEmpty) {
              final DocumentReference<Map<String, dynamic>> tRef =
                  _profile(target);
              final DocumentSnapshot<Map<String, dynamic>> tSnap =
                  await tRef.get();
              if (tSnap.exists) {
                batch.update(tRef, <String, dynamic>{
                  'followersCount': FieldValue.increment(-1),
                });
              }
            }
            await batch.commit();
          } catch (e) {
            debugPrint('ProfileService: unfollow ${doc.id} dilangkau: $e');
          }
        }
      }

      await _profile(me).delete();
      return Result<bool, SocialFailure>.success(true);
    } catch (e) {
      debugPrint('ProfileService.deleteMyProfileAndEdges gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }
  }
}
