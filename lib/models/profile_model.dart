// lib/models/profile_model.dart
// Profil AWAM pengguna (profiles/{uid}) — apa yang orang lain boleh lihat.
// Sengaja minimum: nama, bio, kiraan pengikut. Tiada e-mel, tarikh lahir,
// jantina atau data gamifikasi (itu kekal dalam users/{uid}, owner-only).
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String uid;
  final String name;
  final String bio;

  /// Kaunter server-authoritative (rules: hanya ±1 bersama edge follow).
  final int followersCount;

  /// null = tulisan tempatan yang belum disahkan pelayan.
  final DateTime? createdAt;

  const ProfileModel({
    required this.uid,
    required this.name,
    required this.bio,
    required this.followersCount,
    this.createdAt,
  });

  factory ProfileModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.data() ?? const <String, dynamic>{};
    final dynamic ts = d['createdAt'];
    final dynamic count = d['followersCount'];
    return ProfileModel(
      uid: doc.id,
      name: (d['name'] as String?) ?? 'Hamba Allah',
      bio: (d['bio'] as String?) ?? '',
      followersCount: count is int ? count : 0,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  /// Huruf pertama nama untuk avatar ringkas (avatar sebenar orang lain
  /// perlu Firebase Storage — belum ada).
  String get initial {
    final String t = name.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCodes(t.runes.take(1)).toUpperCase();
  }
}

/// Satu edge follow: [otherUid] ialah pihak satu lagi (bergantung pada
/// senarai mana yang dibaca — pengikut atau yang diikuti).
class FollowEdge {
  final String otherUid;
  final DateTime? createdAt;

  const FollowEdge({required this.otherUid, this.createdAt});

  factory FollowEdge.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required bool otherIsFollowee,
  }) {
    final Map<String, dynamic> d = doc.data() ?? const <String, dynamic>{};
    final dynamic ts = d['createdAt'];
    final String key = otherIsFollowee ? 'followeeId' : 'followerId';
    return FollowEdge(
      otherUid: (d[key] as String?) ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
