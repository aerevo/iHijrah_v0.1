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

              // ── Baris tindakan: Suka · Simpan ────────────
              SizedBox(
                height: 40,
                child: Row(children: [
                  Expanded(child: _ActionSlot(
                      icon: Icons.thumb_up_alt_outlined,
                      activeIcon: Icons.thumb_up_rounded,
                      label: 'Suka', activeColor: accent)),
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
