// lib/widgets/feed_card.dart  (V4 — Islamic Luxury Editorial)
//
// Rombak drpd V3: kurangkan badge/chrome, besarkan typography, ARTIKEL
// ditukar drpd overlay penuh kepada "imej + panel bawah" gaya Medium.
// Semua warna sekarang datang dari FeedPalette (theme/feed_theme.dart)
// yg beranimasi ikut Subuh/Maghrib sebenar — bukan const tetap lagi.
//
// `palette.t` (0=malam,1=siang) digunakan utk fade badge jenis
// (VIDEO/ARTIKEL chip) terus dlm build() — masa DayNightTheme animate,
// setiap frame bagi `t` baharu, so badge fade sekali dgn warna lain,
// bukan snap on/off.
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../theme/feed_theme.dart';
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

// Fallback imej kosong (gradient jenama, bukan foto random)
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// ── PETIKAN: 2 tona tenang sahaja (krim & sage) — bukan 6 warna vivid
// lagi. Setiap tona ada versi siang & malam sendiri, di-lerp ikut
// palette.t supaya turut crossfade lembut.
class _QuoteTone {
  final Color dayBg, dayText, nightBg, nightText;
  const _QuoteTone(this.dayBg, this.dayText, this.nightBg, this.nightText);
}

const List<_QuoteTone> _quoteTones = [
  _QuoteTone(Color(0xFFF7F3EA), Color(0xFF201C14), Color(0xFF1B170F), Color(0xFFF3EEE2)), // krim/gading
  _QuoteTone(Color(0xFFE8EDE1), Color(0xFF23301F), Color(0xFF161C14), Color(0xFFE3ECD9)), // sage
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

// ── Tag jenis (VIDEO/ARTIKEL) — duduk atas FOTO (bukan atas latar
// app), jadi warnanya sendiri kekal tetap tak kira siang/malam (foto
// ada tona sendiri). Yang berubah cuma OPACITY dia — caller bungkus
// dgn Opacity(opacity: chromeOpacity) ikut palette.t. ──────────────
Widget _glassTag(String type) {
  return PopScaleIn(
    delay: const Duration(milliseconds: 180),
    child: PremiumGlass(
      level: GlassLevel.badge,
      borderRadius: BorderRadius.circular(8),
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

// ── Bookmark — FUNGSIAN, jadi tak pernah hilang macam badge jenis.
// onImage=true: chip kaca gelap universal (selamat atas apa jua foto).
// onImage=false: chip ikut token FeedPalette (utk kad rata cth tiket).
Widget _floatingBookmark(FeedPalette palette, {bool onImage = true}) {
  return PopScaleIn(
    delay: const Duration(milliseconds: 220),
    child: PremiumGlass(
      level: GlassLevel.badge,
      tint: onImage ? Colors.black : palette.surfaceAlt,
      opacity: onImage ? 0.45 : 0.92,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.all(6),
      child: PopBookmarkButton(
        iconSize: 13,
        mutedColor: onImage ? Colors.white.withOpacity(0.9) : palette.textSecondary,
        savedColor: onImage ? kGoldLight : palette.accent,
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
  bool shouldRepaint(covariant _GeoLatticePainter o) => o.color != color;
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
  bool shouldRepaint(covariant _DashLinePainter o) => o.color != color;
}

// ── FEED CARD ────────────────────────────────────────────────
class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final double imageAspectRatio;
  final FeedPalette palette;

  const FeedCard({
    Key? key,
    required this.post,
    required this.palette,
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
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(color: palette.divider, width: AppStroke.hairline),
            boxShadow: palette.cardShadow,
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

  // ── VIDEO: imej + panel bawah, badge chip fade ikut siang/malam ──
  Widget _buildVideo() {
    final Color accent = kTypeVideo;
    final int h = post.id.hashCode.abs();
    final double progress = 0.25 + (h % 50) / 100;
    final int fakeMinutes = 1 + h % 12;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final double chromeOpacity = (1 - palette.t).clamp(0.0, 1.0);

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
                    colors: [Color(0x1F000000), Color(0x4D000000)],
                  ),
                )),
              ),

              // Play — kekal (fungsian, bukan chrome hiasan), diperkecil
              Center(
                child: PopScaleIn(
                  delay: const Duration(milliseconds: 160),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.32),
                          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.1),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Badge jenis — fade keluar waktu siang (editorial), balik
              // nampak waktu malam. Bukan swap terus, ikut palette.t.
              Positioned(top: 10, left: 10,
                child: Opacity(opacity: chromeOpacity, child: _glassTag('video'))),
              Positioned(top: 10, right: 10, child: _floatingBookmark(palette)),

              // Garis progress — kekal, ni maklumat fungsian (brp byk
              // dah ditonton), bukan hiasan.
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

        // Panel — warna ikut palette (dulu hardcode 0xFF12161C)
        Container(
          color: palette.surface,
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800,
                      color: palette.textPrimary, height: 1.28, letterSpacing: -0.2)),
              const SizedBox(height: 9),
              Row(children: [
                _authorAvatar(post.author, accent, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('${post.author} · $fakeMinutes minit · ${post.time}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9.5, color: palette.textMuted))),
                const SizedBox(width: 4),
                PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                    mutedColor: palette.textMuted, likedColor: accent,
                    countStyle: TextStyle(fontSize: 9.5, color: palette.textMuted)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── ARTIKEL: DITUKAR drpd overlay penuh kepada imej + panel bawah
  // (gaya Medium) — ikut cadangan "Islamic Luxury Editorial". Ada
  // petikan 2 baris + "oleh {author}" sekarang, dulu takde.
  Widget _buildArticle() {
    final int h = post.id.hashCode.abs();
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final double chromeOpacity = (1 - palette.t).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImg
                  ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(_palettes[h % _palettes.length], 'article'))
                  : _gradBg(_palettes[h % _palettes.length], 'article'),
              Positioned(top: 10, left: 10,
                  child: Opacity(opacity: chromeOpacity, child: _glassTag('article'))),
              Positioned(top: 10, right: 10, child: _floatingBookmark(palette)),
            ],
          ),
        ),

        Container(
          color: palette.surface,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: palette.textPrimary, height: 1.26, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: palette.textSecondary, height: 1.42)),
              const SizedBox(height: 11),
              Row(children: [
                _authorAvatar(post.author, palette.accent, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('oleh ${post.author} · ${post.time}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9.5, color: palette.textMuted, fontWeight: FontWeight.w600))),
                const SizedBox(width: 4),
                PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                    mutedColor: palette.textMuted, likedColor: palette.accent,
                    countStyle: TextStyle(fontSize: 9.5, color: palette.textMuted)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── ACARA: tiket — struktur kekal (dah distinctive & fungsian),
  // cuma warna ikut palette sekarang.
  Widget _buildTicket() {
    final int h = post.id.hashCode.abs();
    final String day = (1 + h % 28).toString().padLeft(2, '0');
    final String month = _months[h % 12];
    const LinearGradient dateGradient = LinearGradient(
        colors: [Color(0xFF3E8EF0), Color(0xFF2563C9)],
        begin: Alignment.topLeft, end: Alignment.bottomRight);
    const Color dateAccent = Color(0xFF2563C9);

    return Container(
      color: palette.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: dateGradient,
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
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800,
                              color: palette.textPrimary, height: 1.3)),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(Icons.access_time_rounded, size: 10, color: palette.textMuted),
                        const SizedBox(width: 4),
                        Expanded(child: Text('8:00 pagi', style: TextStyle(fontSize: 9.5,
                            color: palette.textMuted, fontWeight: FontWeight.w600))),
                      ]),
                    ],
                  ),
                ),
                _floatingBookmark(palette, onImage: false),
              ],
            ),
          ),

          LayoutBuilder(builder: (c, cons) => CustomPaint(
                size: Size(cons.maxWidth, 2),
                painter: _DashLinePainter(palette.divider),
              )),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(children: [
              _authorAvatar(post.author, dateAccent, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(post.author, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: palette.textMuted,
                      fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: dateAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('DAFTAR', style: TextStyle(fontSize: 8,
                    fontWeight: FontWeight.w800, color: dateAccent, letterSpacing: 0.8)),
              ),
              const SizedBox(width: 6),
              PopLikeButton(baseCount: post.likes, iconSize: 11.5,
                  mutedColor: palette.textMuted, likedColor: const Color(0xFFE8433F),
                  countStyle: TextStyle(fontSize: 9.5, color: palette.textMuted)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── PETIKAN: krim/sage sahaja, TIADA ikon watermark lagi (arahan
  // "tiada icon langsung"). Corak geometri halus (~5%) dikekalkan —
  // itu identiti jenama, bukan hiasan chrome yg dikomplen.
  Widget _buildQuote() {
    final _QuoteTone tone = _quoteTones[post.id.hashCode.abs() % _quoteTones.length];
    final Color bg = Color.lerp(tone.nightBg, tone.dayBg, palette.t)!;
    final Color text = Color.lerp(tone.nightText, tone.dayText, palette.t)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      color: bg,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GeoLatticePainter(color: text.withOpacity(0.05))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.content, maxLines: 7, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: text, fontSize: 17,
                      fontWeight: FontWeight.w700, height: 1.46, letterSpacing: -0.2)),
              const SizedBox(height: 18),
              Row(children: [
                Container(width: 20, height: 2, color: text.withOpacity(0.55)),
                const SizedBox(width: 8),
                Expanded(child: Text(post.author, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700,
                        color: text.withOpacity(0.75), letterSpacing: 0.3))),
                PopLikeButton(baseCount: post.likes, iconSize: 11,
                    mutedColor: text.withOpacity(0.45), likedColor: text,
                    countStyle: TextStyle(fontSize: 9.5, color: text.withOpacity(0.6))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // Fallback gradient jenama (bila post takde imej) — kekal, 5% opacity
  // ikon jenis kandungan = identiti halus, bukan clutter.
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
