// lib/widgets/feed_card.dart  (V6 — Classic FB, satu struktur universal)
//
// Rombak besar drpd sistem HERO/STANDARD/TICKET/QUOTE (V1-V5): buang
// terus "layout lain-lain ikut jenis post" — itu punca redesign
// berulang-ulang sebelum ni. Kembali ke SATU struktur kad gaya
// Facebook klasik: avatar+nama+masa di atas, teks, gambar (kalau
// ada), garis, kiraan suka, baris tindakan. Semua jenis post guna
// struktur SAMA — video/artikel/acara/kuota cuma beza kandungan,
// bukan beza seni bina. Tiada lagi FeedPalette/PremiumGlass/Playfair
// — kad kekal putih, static, ringkas macam FB sebenar.
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';
import '../services/social_service.dart';
import 'comments_sheet.dart';

Color _typeColor(String t) {
  switch (t) {
    case 'video':   return kTypeVideo;
    case 'article': return kTypeArticle;
    case 'event':   return kTypeEvent;
    case 'quote':   return kTypeQuote;
    default:        return kPrimaryGold;
  }
}

IconData _typeMetaIcon(String t) {
  switch (t) {
    case 'video': return Icons.play_circle_outline_rounded;
    case 'event': return Icons.event_outlined;
    case 'quote': return Icons.format_quote_rounded;
    default:      return Icons.public_rounded;
  }
}

const Color _kBorder = Color(0xFFE4E6EA);

const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

String _fmtCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}J';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final double imageAspectRatio;

  const FeedCard({
    Key? key,
    required this.post,
    this.onTap,
    this.imageAspectRatio = 1.45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accent = _typeColor(post.type);
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final bool isVideo = post.type == 'video';
    // Post sebenar (Firestore) sentiasa ada authorId; seed/dummy tiada.
    // Hanya post sebenar boleh disuka/dikomen (seed tiada dokumen di Firestore).
    final bool isLive = post.authorId.isNotEmpty;
    final int h = post.id.hashCode.abs();
    final String initial = post.author.trim().isNotEmpty
        ? post.author.trim()[0].toUpperCase() : '?';

    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kFeedCardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder, width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header: avatar + nama + masa ────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accent.withOpacity(0.15),
                      child: Text(initial, style: TextStyle(color: accent,
                          fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.author, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700,
                                  color: kTextPrimary)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Text(post.time, style: const TextStyle(fontSize: 12, color: kTextMuted)),
                            const SizedBox(width: 4),
                            Icon(_typeMetaIcon(post.type), size: 11, color: kTextMuted),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz_rounded, color: kTextMuted, size: 20),
                  ],
                ),
              ),

              // ── Kapsyen: tajuk + kandungan ───────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700,
                            color: kTextPrimary, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(post.content,
                        maxLines: post.type == 'quote' ? 6 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, color: kTextSecondary, height: 1.45)),
                  ],
                ),
              ),

              // ── Media: gambar/video (kalau ada) ─────────
              if (hasImg || isVideo)
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      hasImg
                          ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _gradBg(h))
                          : _gradBg(h),
                      if (isVideo)
                        Center(
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.45)),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 30),
                          ),
                        ),
                    ],
                  ),
                ),

              // ── Kiraan suka ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                    child: const Icon(Icons.thumb_up_rounded, size: 9, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(_fmtCount(post.likes),
                      style: const TextStyle(fontSize: 12.5, color: kTextMuted)),
                ]),
              ),

              const Divider(height: 1, thickness: 1, color: _kBorder),

              // ── Baris tindakan: Suka · Komen · Simpan ────────
              SizedBox(
                height: 40,
                child: Row(children: [
                  Expanded(child: _LikeSlot(
                      postId: post.id, isLive: isLive, accent: accent)),
                  Container(width: 1, color: _kBorder),
                  Expanded(child: _CommentSlot(postId: post.id, isLive: isLive)),
                  Container(width: 1, color: _kBorder),
                  Expanded(child: _ActionSlot(
                      icon: Icons.bookmark_border_rounded,
                      activeIcon: Icons.bookmark_rounded,
                      label: 'Simpan', activeColor: kPrimaryGold)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradBg(int h) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _palettes[h % _palettes.length],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
      );
}

// ── Slot butang tindakan (Suka / Simpan) — toggle mudah, tiada
// animasi pop-bounce (sengaja, gaya FB memang subtle bukan flashy) ──
class _ActionSlot extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
  const _ActionSlot({
    required this.icon, required this.activeIcon,
    required this.label, required this.activeColor,
  });

  @override
  State<_ActionSlot> createState() => _ActionSlotState();
}

class _ActionSlotState extends State<_ActionSlot> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final Color c = _active ? widget.activeColor : kTextSecondary;
    return InkWell(
      onTap: () => setState(() => _active = !_active),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_active ? widget.activeIcon : widget.icon, size: 18, color: c),
          const SizedBox(width: 6),
          Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }
}

// ── Badan butang tindakan (ikon + label) — dikongsi oleh slot yang
// keadaannya datang dari Firebase (bukan toggle tempatan) ──────────
class _SlotBody extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _SlotBody({
    required this.icon, required this.label,
    required this.color, this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );
}

void _showFeedSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: kWarningRed,
        behavior: SnackBarBehavior.floating),
  );
}

// ── Suka — keadaan sebenar dari Firestore (posts/{id}/likes/{uid}) ──
// Kiraan di atas datang dari dokumen post (stream feed), jadi ia hanya
// berubah bila pelayan mengesahkan transaction — bukan kiraan tempatan.
class _LikeSlot extends StatefulWidget {
  final String postId;
  final bool isLive;
  final Color accent;
  const _LikeSlot({
    required this.postId, required this.isLive, required this.accent,
  });

  @override
  State<_LikeSlot> createState() => _LikeSlotState();
}

class _LikeSlotState extends State<_LikeSlot> {
  Stream<bool>? _likedStream;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLive) {
      _likedStream = SocialService.instance.watchLiked(widget.postId);
    }
  }

  Future<void> _toggle(bool currentlyLiked) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await SocialService.instance
        .setLiked(widget.postId, like: !currentlyLiked);
    if (!mounted) return;
    setState(() => _busy = false);
    result.onError((f) => _showFeedSnack(context, f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLive) {
      return _SlotBody(
        icon: Icons.thumb_up_alt_outlined,
        label: 'Suka',
        color: kTextMuted,
        onTap: () => _showFeedSnack(
            context, 'Ini kandungan contoh — hanya post komuniti boleh disuka.'),
      );
    }

    return StreamBuilder<bool>(
      stream: _likedStream,
      initialData: false,
      builder: (context, snap) {
        if (snap.hasError) {
          debugPrint('LikeSlot: stream like gagal: ${snap.error}');
        }
        final bool liked = snap.data ?? false;
        final Color c = _busy
            ? kTextMuted
            : (liked ? widget.accent : kTextSecondary);
        return _SlotBody(
          icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
          label: 'Suka',
          color: c,
          onTap: _busy ? null : () => _toggle(liked),
        );
      },
    );
  }
}

// ── Komen — kiraan dari aggregate count() (dikira pelayan) ─────────
// Dimuat semula selepas sheet ditutup supaya kiraan segar.
class _CommentSlot extends StatefulWidget {
  final String postId;
  final bool isLive;
  const _CommentSlot({required this.postId, required this.isLive});

  @override
  State<_CommentSlot> createState() => _CommentSlotState();
}

class _CommentSlotState extends State<_CommentSlot> {
  Future<int?>? _count;

  @override
  void initState() {
    super.initState();
    if (widget.isLive) {
      _count = SocialService.instance.commentCount(widget.postId);
    }
  }

  Future<void> _open() async {
    if (!widget.isLive) {
      _showFeedSnack(
          context, 'Ini kandungan contoh — hanya post komuniti boleh dikomen.');
      return;
    }
    await showCommentsSheet(context, postId: widget.postId);
    if (!mounted) return;
    setState(() {
      _count = SocialService.instance.commentCount(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _count,
      builder: (context, snap) {
        final int? n = snap.data;
        final String label = (n != null && n > 0) ? 'Komen · $n' : 'Komen';
        return _SlotBody(
          icon: Icons.chat_bubble_outline_rounded,
          label: label,
          color: widget.isLive ? kTextSecondary : kTextMuted,
          onTap: _open,
        );
      },
    );
  }
}
