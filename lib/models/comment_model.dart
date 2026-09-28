// lib/models/comment_model.dart
// Model ringkas untuk comment DAN reply (bentuk dokumen sama:
// authorId, author, content, createdAt). Sengaja tiada medan profil
// lain — users/{uid} orang lain tak boleh dibaca, jadi nama paparan
// disimpan denormalized dalam dokumen (disahkan oleh firestore.rules).
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorId;
  final String author;
  final String content;

  /// null = tulisan tempatan yang belum disahkan pelayan (server timestamp
  /// belum diselesaikan).
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.authorId,
    required this.author,
    required this.content,
    this.createdAt,
  });

  factory CommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.data() ?? const <String, dynamic>{};
    final dynamic ts = d['createdAt'];
    return CommentModel(
      id: doc.id,
      authorId: (d['authorId'] as String?) ?? '',
      author: (d['author'] as String?) ?? 'Pengguna iHijrah',
      content: (d['content'] as String?) ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  String get timeAgo {
    final DateTime? t = createdAt;
    if (t == null) return 'Baru sahaja';
    final Duration diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Baru sahaja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h lalu';
  }
}
