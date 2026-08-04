// lib/widgets/feed_card.dart
// Kad komuniti — Bahasa Reka Bentuk Bersatu (Unified Design Language):
//   - KAD MEDIA (Video, Artikel, Acara): Menggunakan struktur bersatu Gambar 2
//     (Imej di atas + Panel Maklumat di bawah). Video dibezakan melalui ikon Play
//     terapung di atas gambar, bukan menukar keseluruhan layout kad.
//   - KAD PETIKAN (Quote): Latar gradien gelap eksklusif dengan tipografi sebagai hero.

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';

// ── TYPE COLOR MAPPING ────────────────────────────────────────
Color _typeColor(String t) {
  switch (t) {
    case 'video':   return kTypeVideo;
    case 'article': return kTypeArticle;
    case 'event':   return kTypeEvent;
    case 'quote':   return kTypeQuote;
    default:        return kPrimaryGold;
  }
}

IconData _typeIcon(String t) {
  switch (t) {
    case 'video':   return Icons.play_arrow_rounded;
    case 'article': return Icons.article_rounded;
    case 'event':   return Icons.event_rounded;
    case 'quote':   return Icons.format_quote_rounded;
    default:        return Icons.circle;
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'video':   return 'VIDEO';
    case 'article': return 'ARTIKEL';
    case 'event':   return 'ACARA';
    case 'quote':   return 'PETIKAN';
    default:        return t.toUpperCase();
  }
}

// ── GRADIENT PALETTES (Fallback untuk imej kosong) ──────────
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// Pool warna kad PETIKAN (Quote)
const List<List<Color>> _quotePalettes = [
  [Color(0xFF241C0C), Color(0xFF120D05)], // emas gelap
  [Color(0xFF163A2E), Color(0xFF0A1D17)], // emerald gelap
  [Color(0xFF17253F), Color(0xFF0B1220)], // navy-indigo
  [Color(0xFF3A1620), Color(0xFF1D0A10)], // maroon
  [Color(0xFF3E2A1C), Color(0xFF1F150E)], // gangsa
  [Color(0xFF123A3E), Color(0xFF091E20)], // teal gelap
];

List<Color> _quoteGradientFor(PostModel post) =>
    _quotePalettes[post.id.hashCode.abs() % _quotePalettes.length];

// ── Avatar bulat kecil ────────────────────────────────────────
Widget _authorAvatar(String author, Color accent, {double size = 18}) {
  final String initial =
      author.trim().isNotEmpty ? author.trim()[0].toUpperCase() : '?';
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withOpacity(0.18),
      border: Border.all(color: accent.withOpacity(0.4), width: 0.8),
    ),
    child: Text(
      initial,
      style: TextStyle(
        fontSize: size * 0.42,
        fontWeight: FontWeight.w800,
        color: accent,
        height: 1,
      ),
    ),
  );
}

// ── Tag jenis (Kapsul Kaca) ───────────────────────────────────
Widget _glassTag(String type) {
  final Color accent = _typeColor(type);
  return PopScaleIn(
    delay: const Duration(milliseconds: 180),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_typeIcon(type), size: 10, color: accent),
          const SizedBox(width: 4),
          Text(
            _typeLabel(type),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Ikon Bookmark Terapung ───────────────────────────────────
Widget _floatingBookmark() {
  return PopScaleIn(
    delay: const Duration(milliseconds: 220),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
      ),
      child: PopBookmarkButton(
        iconSize: 13,
        mutedColor: Colors.white.withOpacity(0.9),
        savedColor: kGoldLight,
      ),
    ),
  );
}

// ── Pattern Geometri Halus (Untuk Kad Petikan) ───────────────
class _GeoLatticePainter extends CustomPainter {
  final Color color;
  const _GeoLatticePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double spacing = 25;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final Path path = Path()
          ..moveTo(x, y - spacing / 2)
          ..lineTo(x + spacing / 2, y)
          ..lineTo(x, y + spacing / 2)
          ..lineTo(x - spacing / 2, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeoLatticePainter oldDelegate) => false;
}

// ── FEED CARD MAIN WIDGET ─────────────────────────────────────
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
    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kFeedCardSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kFeedCardShadows(),
          ),
          clipBehavior: Clip.antiAlias,
          child: post.type == 'quote'
              ? _buildQuoteLayout()
              : _buildMediaLayout(), // Semua Video, Artikel, & Acara guna layout seragam ini
        ),
      ),
    );
  }

  // ── LAYOUT 1: KAD MEDIA BERSATU (VIDEO, ARTIKEL, ACARA) ──────
  Widget _buildMediaLayout() {
    final Color accent = _typeColor(post.type);
    final int pi = post.id.hashCode.abs() % _palettes.length;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final bool isVideo = post.type == 'video';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. BAHAGIAN IMEJ (ATAS)
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImg
                  ? Image.asset(
                      post.assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(_palettes[pi], post.type),
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedSwitcher(
                          duration: AppDurations.fast,
                          child: frame == null
                              ? const ShimmerBox(key: ValueKey('shimmer'))
                              : KeyedSubtree(key: const ValueKey('img'), child: child),
                        );
                      },
                    )
                  : _gradBg(_palettes[pi], post.type),

              // Shadow halus di bawah imej
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x33000000)],
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Overlay Khas VIDEO: Ikon Play Terapung di tengah imej
              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),

              Positioned(top: 8, left: 8, child: _glassTag(post.type)),
              Positioned(top: 8, right: 8, child: _floatingBookmark()),
            ],
          ),
        ),

        // 2. BAHAGIAN PANEL MAKLUMAT / TEKS (BAWAH)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: kTextPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _authorAvatar(post.author, accent, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${post.author} · ${post.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9.5, color: kTextSecondary),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopLikeButton(
                    baseCount: post.likes,
                    iconSize: 11.5,
                    mutedColor: kTextMuted,
                    likedColor: kTypeVideo,
                    countStyle: const TextStyle(fontSize: 9.5, color: kTextMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── LAYOUT 2: KAD PETIKAN (QUOTE) ────────────────────────────
  Widget _buildQuoteLayout() {
    final List<Color> quoteColors = _quoteGradientFor(post);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: quoteColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GeoLatticePainter(color: Colors.white.withOpacity(0.035)),
            ),
          ),
          Positioned(top: 0, right: 0, child: _floatingBookmark()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PopScaleIn(
                delay: const Duration(milliseconds: 140),
                child: Icon(Icons.format_quote_rounded, size: 26, color: kGoldLight),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${post.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: kGoldLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PopLikeButton(
                    baseCount: post.likes,
                    iconSize: 11.5,
                    mutedColor: Colors.white.withOpacity(0.55),
                    likedColor: kTypeVideo,
                    countStyle: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradBg(List<Color> colors, String type) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10, bottom: -10,
              child: Icon(
                _typeIcon(type),
                size: 78,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ],
        ),
      );
}
