// lib/widgets/comments_sheet.dart
// Bottom sheet komen untuk satu post. Data sebenar dari Firestore
// (posts/{postId}/comments) — loading / kosong / ralat dikendalikan.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/social_failure.dart';
import '../services/social_service.dart';
import '../utils/constants.dart';
import '../utils/result.dart';

const Color _kSheetBorder = Color(0xFFE4E6EA);
const int kCommentMaxLength = 500;

Future<void> showCommentsSheet(BuildContext context, {required String postId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kFeedCardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: CommentsSheet(postId: postId),
      ),
    ),
  );
}

void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: kWarningRed,
        behavior: SnackBarBehavior.floating),
  );
}

Future<bool> _confirmDelete(BuildContext context, String noun) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Padam $noun?'),
      content: const Text('Ini akan dipadam secara kekal.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal')),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Padam', style: TextStyle(color: kWarningRed))),
      ],
    ),
  );
  return ok == true;
}

class CommentsSheet extends StatefulWidget {
  final String postId;
  const CommentsSheet({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late Stream<List<CommentModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = SocialService.instance.watchComments(widget.postId);
  }

  Future<void> _delete(CommentModel c) async {
    if (!await _confirmDelete(context, 'komen')) return;
    if (!mounted) return;
    final res = await SocialService.instance.deleteComment(widget.postId, c.id);
    if (!mounted) return;
    res.onError((f) => _snack(context, f.message));
  }

  @override
  Widget build(BuildContext context) {
    final String? myUid = SocialService.instance.currentUid;

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(children: [
            const Expanded(
              child: Text('Komen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: kTextPrimary)),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: kTextMuted),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
        ),
        const Divider(height: 1, thickness: 1, color: _kSheetBorder),

        // ── Senarai ─────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<CommentModel>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                debugPrint('CommentsSheet: stream gagal: ${snap.error}');
                final bool denied = snap.error is FirebaseException &&
                    (snap.error as FirebaseException).code == 'permission-denied';
                return _StatusMessage(
                  text: denied
                      ? 'Tak dapat muat komen. Pastikan e-mel anda sudah disahkan.'
                      : 'Tak dapat muat komen. Semak sambungan internet.',
                  actionLabel: 'Cuba lagi',
                  onAction: () => setState(() {
                    _stream = SocialService.instance.watchComments(widget.postId);
                  }),
                );
              }
              if (!snap.hasData) {
                return const Center(
                  child: SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kPrimaryGold),
                  ),
                );
              }
              final List<CommentModel> items = snap.data!;
              if (items.isEmpty) {
                return const _StatusMessage(
                    text: 'Belum ada komen. Jadilah yang pertama.');
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final c = items[i];
                  return CommentTile(
                    comment: c,
                    isOwn: myUid != null && c.authorId == myUid,
                    onDelete: () => _delete(c),
                    footer: _RepliesSection(
                        postId: widget.postId, commentId: c.id),
                  );
                },
              );
            },
          ),
        ),

        // ── Tulis komen ─────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: _kSheetBorder),
        _Composer(
          hint: 'Tulis komen...',
          onSubmit: (text) {
            final String name =
                Provider.of<UserModel>(context, listen: false).name;
            return SocialService.instance
                .addComment(widget.postId, content: text, authorName: name);
          },
        ),
      ],
    );
  }
}

// ── Satu baris komen / reply ────────────────────────────────────
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isOwn;
  final VoidCallback? onDelete;
  final Widget? footer; // cth. butang "Balas" + senarai reply (Batch 3)
  final double avatarRadius;

  const CommentTile({
    Key? key,
    required this.comment,
    required this.isOwn,
    this.onDelete,
    this.footer,
    this.avatarRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String initial = comment.author.trim().isNotEmpty
        ? comment.author.trim()[0].toUpperCase() : '?';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: kPrimaryGold.withOpacity(0.15),
          child: Text(initial, style: const TextStyle(
              color: kPrimaryGold, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                  child: Text(comment.author,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: kTextPrimary)),
                ),
                const SizedBox(width: 6),
                Text(comment.timeAgo,
                    style: const TextStyle(fontSize: 11.5, color: kTextMuted)),
                const Spacer(),
                if (isOwn && onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 17, color: kTextMuted),
                    ),
                  ),
              ]),
              const SizedBox(height: 2),
              Text(comment.content,
                  style: const TextStyle(fontSize: 13.5, height: 1.4,
                      color: kTextSecondary)),
              if (footer != null) footer!,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reply (satu tahap) di bawah setiap komen ───────────────────
class _RepliesSection extends StatefulWidget {
  final String postId;
  final String commentId;
  const _RepliesSection({required this.postId, required this.commentId});

  @override
  State<_RepliesSection> createState() => _RepliesSectionState();
}

class _RepliesSectionState extends State<_RepliesSection> {
  bool _open = false;
  Stream<List<CommentModel>>? _stream;

  Stream<List<CommentModel>> _openStream() => SocialService.instance
      .watchReplies(widget.postId, widget.commentId);

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) _stream ??= _openStream();
    });
  }

  Future<void> _deleteReply(CommentModel r) async {
    if (!await _confirmDelete(context, 'balasan')) return;
    if (!mounted) return;
    final res = await SocialService.instance
        .deleteReply(widget.postId, widget.commentId, r.id);
    if (!mounted) return;
    res.onError((f) => _snack(context, f.message));
  }

  @override
  Widget build(BuildContext context) {
    final String? myUid = SocialService.instance.currentUid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_open ? 'Tutup balasan' : 'Balas',
                  style: const TextStyle(fontSize: 12.5,
                      fontWeight: FontWeight.w700, color: kPrimaryGold)),
            ),
          ),
        ),
        if (_open) ...[
          StreamBuilder<List<CommentModel>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                debugPrint('RepliesSection: stream gagal: ${snap.error}');
                return Row(children: [
                  const Flexible(
                    child: Text('Tak dapat muat balasan.',
                        style: TextStyle(fontSize: 12, color: kTextMuted)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _stream = _openStream()),
                    child: const Text('Cuba lagi',
                        style: TextStyle(color: kPrimaryGold, fontSize: 12)),
                  ),
                ]);
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: kPrimaryGold)),
                );
              }
              final List<CommentModel> items = snap.data!;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Belum ada balasan.',
                      style: TextStyle(fontSize: 12, color: kTextMuted)),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  children: [
                    for (final r in items) ...[
                      CommentTile(
                        comment: r,
                        avatarRadius: 12,
                        isOwn: myUid != null && r.authorId == myUid,
                        onDelete: () => _deleteReply(r),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              );
            },
          ),
          _Composer(
            hint: 'Tulis balasan...',
            onSubmit: (text) {
              final String name =
                  Provider.of<UserModel>(context, listen: false).name;
              return SocialService.instance.addReply(
                  widget.postId, widget.commentId,
                  content: text, authorName: name);
            },
          ),
        ],
      ],
    );
  }
}

// ── Mesej status tengah (kosong / ralat) ────────────────────────
class _StatusMessage extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _StatusMessage({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: kTextMuted)),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!,
                      style: const TextStyle(color: kPrimaryGold)),
                ),
            ],
          ),
        ),
      );
}

// ── Kotak tulis (dikongsi comment & reply) ─────────────────────
// onSubmit memulangkan Result; kejayaan mengosongkan medan, kegagalan
// memaparkan mesej generik dan KEKALKAN teks supaya boleh cuba lagi.
class _Composer extends StatefulWidget {
  final String hint;
  final Future<Result<bool, SocialFailure>> Function(String text) onSubmit;
  const _Composer({required this.hint, required this.onSubmit});

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (text.length > kCommentMaxLength) {
      _snack(context, 'Terlalu panjang (maks $kCommentMaxLength aksara).');
      return;
    }
    setState(() => _sending = true);
    final Result<bool, SocialFailure> res = await widget.onSubmit(text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (res.isSuccess) {
      _ctrl.clear();
    } else {
      _snack(context, (res.error ?? SocialFailure.unknown).message);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                enabled: !_sending,
                minLines: 1,
                maxLines: 4,
                maxLength: kCommentMaxLength,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 14, color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: kTextMuted),
                  counterText: '',
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF0F2F5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _sending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kPrimaryGold)),
                  )
                : IconButton(
                    icon: const Icon(Icons.send_rounded, color: kPrimaryGold),
                    onPressed: _send,
                  ),
          ]),
        ),
      );
}
