// lib/widgets/feed_card.dart  (V3 — identiti tersendiri)
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';
import 'premium_glass.dart';

// ── TYPE MAPPING ─────────────────────────────────────────────
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
    default:        return Icons.circle;
  }
}

// Fallback imej kosong
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// Palet petikan vivid
class _QuoteStyle {
  final List<Color> bg;
  final Color text;
  const _QuoteStyle(this.bg, this.text);
}

const List<_QuoteStyle> _quoteStyles = [
  _QuoteStyle([Color(0xFFFFC53D), Color(0xFFFF9500)], Color(0xFF2B1D00)),
  _QuoteStyle([Color(0xFF00C6D7), Color(0xFF0891B2)], Color(0xFF002E38)),
  _QuoteStyle([Color(0xFF8B5CF6), Color(0xFF6D28D9)], Colors.white),
  _QuoteStyle([Color(0xFFFF6B6B), Color(0xFFE8433F)], Colors.white),
  _QuoteStyle([Color(0xFFF9A8C9), Color(0xFFEE7FB2)], Color(0xFF40102A)),
  _QuoteStyle([Color(0xFF34D399), Color(0xFF059669)], Color(0xFF022A1C)),
];

const List<String> _months = ['JAN','FEB','MAC','APR','MEI','JUN',
                              'JUL','OGO','SEP','OKT','NOV','DIS'];

// ── Avatar ───────────────────────────────────────────────────
Widget _authorAvatar(String author, Color accent, {double size = 18}) {
  final String initial =
      author.trim().isNotEmpty ? author.trim()[0].toUpperCase() : '?';
  return Container(
    width: size, height: size, alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withOpacity(0.18),
      border: Border.all(color: accent.withOpacity(0.4), width: 0.8),
    ),
    child: Text(initial,
        style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w800,
            color: accent, height: 1)),
  );
}

// ── Tag kaca (kekal utk imej) ────────────────────────────────
Widget _glassTag(String type) {
  return PopScaleIn(
    delay: const Duration(milliseconds: 180),
    child: PremiumGlass(
      level: GlassLevel.badge,
      borderRadius: BorderRadius.circular(8), // segi sedikit — kurangkan 'semua bulat'
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_typeIcon(type), size: 10, color: _typeColor(type)),
        const SizedBox(width: 4),
        Text(type == 'video' ? 'VIDEO' : 'ARTIKEL',
            style: const TextStyle(color: Colors.white, fontSize: 8.5,
                fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ]),
    ),
  );
}

// ── Bookmark (2 varian: gelap & cerah) ───────────────────────
Widget _floatingBookmark({bool onLight = false}) {
  return PopScaleIn(
    delay: const Duration(milliseconds: 220),
    child: PremiumGlass(
      level: GlassLevel.badge, // saiz kecil bulat — guna blur ringan (level1)
      tint: onLight ? Colors.white : Colors.black,
      opacity: onLight ? 0.85 : 0.45, // chip kecil perlu lebih pekat drpd badge biasa supaya kekal legible
      borderRadius: BorderRadius.circular(999), // bulat penuh
      padding: const EdgeInsets.all(6),
      child: PopBookmarkButton(
        iconSize: 13,
        mutedColor: onLight ? const Color(0xFF5B5647) : Colors.white.withOpacity(0.9),
        savedColor: onLight ? const Color(0xFFB98A1C) : kGoldLight,
      ),
    ),
  );
}

// ── Painters ─────────────────────────────────────────────────
class _GeoLatticePainter extends CustomPainter {
  final Color color;
  const _GeoLatticePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double s = 25;
    for (double y = -s; y < size.height + s; y += s) {
      for (double x = -s; x < size.width + s; x += s) {
        final Path path = Path()
          ..moveTo(x, y - s / 2)
          ..lineTo(x + s / 2, y)
          ..lineTo(x, y + s / 2)
          ..lineTo(x - s / 2, y)
          ..close();
        canvas.drawPath(path, p);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _GeoLatticePainter o) => false;
}

class _DashLinePainter extends CustomPainter {
  final Color color;
  const _DashLinePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color..strokeWidth = 1.2;
    const dash = 4.0, gap = 4.0;
    for (double x = 0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset(math.min(x + dash, size.width), size.height / 2), p);
    }
  }
  @override
  bool shouldRepaint(covariant _DashLinePainter o) => false;
}

// ── FEED CARD ────────────────────────────────────────────────
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
    // Bayang kuat sikit supaya kad 'terangkat' dari latar pakis
    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.8),
            boxShadow: const [
              BoxShadow(color: Color(0x4D000000), blurRadius: 18, offset: Offset(0, 8)),
              BoxShadow(color: Color(0x2E000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _layoutFor(post.type),
        ),
      ),
    );
  }

  Widget _layoutFor(String t) {
    switch (t) {
      case 'video':   return _buildVideo();
      case 'article': return _buildArticle();
      case 'event':   return _buildTicket();
      case 'quote':   return _buildQuote();
      default:        return _buildArticle();
    }
  }

  // ── VIDEO: sinematik + progress + badge neon ───────────────
  Widget _buildVideo() {
    final Color accent = kTypeVideo;
    final int h = post.id.hashCode.abs();
    final double progress = 0.25 + (h % 50) / 100;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImg
                  ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(_palettes[h % _palettes.length], 'video'))
                  : _gradBg(_palettes[h % _palettes.length], 'video'),

              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x29000000), Color(0x66000000)],
                  ),
                )),
              ),

              // Play premium — kaca blur
              Center(
                child: PopScaleIn(
                  delay: const Duration(milliseconds: 160),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.35),
                          border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Badge neon segi
              Positioned(top: 10, left: 10,
                child: PopScaleIn(
                  delay: const Duration(milliseconds: 180),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 8)],
                    ),
                    child: const Text('VIDEO', style: TextStyle(fontSize: 8,
                        fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.8)),
                  ),
                ),
              ),
              Positioned(top: 10, right: 10, child: _floatingBookmark()),

              // Progress line
              Positioned(left: 0, right: 0, bottom: 0,
                child: SizedBox(height: 3,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    Container(color: Colors.white.withOpacity(0.22)),
                    FractionallySizedBox(widthFactor: progress,
                        child: Container(color: accent)),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // Panel gelap minimum
        Container(
          color: const Color(0xFF12161C),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Colors.white, height: 1.3)),
              const SizedBox(height: 8),
              Row(children: [
                _authorAvatar(post.author, accent, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('${post.author} · ${post.time}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF98A2B3)))),
                const SizedBox(width: 4),
                PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                    mutedColor: const Color(0xFF8B93A1), likedColor: accent,
                    countStyle: const TextStyle(fontSize: 9.5, color: Color(0xFF8B93A1))),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── ARTIKEL: full-bleed, Spotify Editorial ─────────────────
  Widget _buildArticle() {
    final int h = post.id.hashCode.abs();
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;

    return AspectRatio(
      aspectRatio: 0.82, // tinggi — variasi masonry
      child: Stack(
        fit: StackFit.expand,
        children: [
          hasImg
              ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _gradBg(_palettes[h % _palettes.length], 'article'))
              : _gradBg(_palettes[h % _palettes.length], 'article'),

          // Scrim bawah
          const Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
                stops: [0.45, 1.0],
              ),
            )),
          ),

          Positioned(top: 10, left: 10, child: _glassTag('article')),
          Positioned(top: 10, right: 10, child: _floatingBookmark()),

          // Tajuk + author terapung atas imej
          Positioned(left: 11, right: 11, bottom: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(post.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800,
                        color: Colors.white, height: 1.3, letterSpacing: -0.2)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 0.6),
                  ),
                  child: Row(children: [
                    _authorAvatar(post.author, kGoldLight, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${post.author} · ${post.time}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: Colors.white70))),
                    const SizedBox(width: 4),
                    PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                        mutedColor: Colors.white60, likedColor: kTypeVideo,
                        countStyle: const TextStyle(fontSize: 9.5, color: Colors.white70)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACARA: tiket ───────────────────────────────────────────
  Widget _buildTicket() {
    final int h = post.id.hashCode.abs();
    final String day = (1 + h % 28).toString().padLeft(2, '0');
    final String month = _months[h % 12];
    const Color ink = Color(0xFF2A2418);
    const Color paper = Color(0xFFFBF6EA);

    return Container(
      color: paper,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blok tarikh
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3E8EF0), Color(0xFF2563C9)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Text(day, style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                    Text(month, style: const TextStyle(fontSize: 8.5,
                        fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.2)),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                              color: ink, height: 1.3)),
                      const SizedBox(height: 5),
                      Row(children: const [
                        Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF8A8270)),
                        SizedBox(width: 4),
                        Expanded(child: Text('8:00 pagi', style: TextStyle(fontSize: 9.5,
                            color: Color(0xFF8A8270), fontWeight: FontWeight.w600))),
                      ]),
                    ],
                  ),
                ),
                _floatingBookmark(onLight: true),
              ],
            ),
          ),

          // Perforasi
          LayoutBuilder(builder: (c, cons) => CustomPaint(
                size: Size(cons.maxWidth, 2),
                painter: const _DashLinePainter(Color(0x4D2A2418)),
              )),

          // Stub
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(children: [
              _authorAvatar(post.author, const Color(0xFF2563C9), size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(post.author, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF8A8270),
                      fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563C9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('DAFTAR', style: TextStyle(fontSize: 8,
                    fontWeight: FontWeight.w800, color: Color(0xFF2563C9), letterSpacing: 0.8)),
              ),
              const SizedBox(width: 6),
              PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                  mutedColor: const Color(0xFFB0A88F), likedColor: const Color(0xFFE8433F),
                  countStyle: const TextStyle(fontSize: 9.5, color: Color(0xFF8A8270))),
            ]),
          ),
        ],
      ),
    );
  }

  // ── PETIKAN: typography hero + watermark ───────────────────
  Widget _buildQuote() {
    final _QuoteStyle s = _quoteStyles[post.id.hashCode.abs() % _quoteStyles.length];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: s.bg,
            begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _GeoLatticePainter(color: Color(0x0FFFFFFF))),
          ),
          // Quote mark gergasi translucent
          Positioned(right: -8, top: -24,
            child: Icon(Icons.format_quote_rounded, size: 110,
                color: (s.text == Colors.white ? Colors.white : s.text).withOpacity(0.14))),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Text(post.content, maxLines: 7, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: s.text, fontSize: 16.5,
                      fontWeight: FontWeight.w800, height: 1.42, letterSpacing: -0.2)),
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 18, height: 2.5, color: s.text.withOpacity(0.8)),
                const SizedBox(width: 7),
                Expanded(child: Text('— ${post.author}', maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800,
                        color: s.text.withOpacity(0.9)))),
                const SizedBox(width: 6),
                PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                    mutedColor: s.text.withOpacity(0.55), likedColor: s.text,
                    countStyle: TextStyle(fontSize: 9.5, color: s.text.withOpacity(0.75))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradBg(List<Color> colors, String type) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Stack(children: [
          Positioned(right: -12, bottom: -12,
            child: Icon(type == 'video' ? Icons.videocam_rounded : _typeIcon(type),
                size: 78, color: Colors.white.withOpacity(0.05))),
        ]),
      );
}
