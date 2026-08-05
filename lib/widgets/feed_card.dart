// lib/widgets/feed_card.dart  (V5 — Islamic Luxury Editorial)
//
// Perubahan utama drpd V4:
// VIDEO/ARTIKEL: Tajuk kini guna GoogleFonts.playfairDisplay (italic,
//   besar), progress bar dibuang, whitespace ditambah — rasa editorial
//   majalah, bukan social feed.
// KUOTA: Tanda petik besar dekoratif atasnya, teks petikan Playfair
//   Display italic besar & gelap, latar krim/sage bersih tanpa lattice
//   — rasa halaman buku/majalah premium.
// ACARA: Tiket kekal (struktur fungsian, bukan hiasan).
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

// Fallback gradient bila post takde assetPath
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// ── Tona latar kad PETIKAN — krim & sage sahaja, lerp siang/malam ──
class _QuoteTone {
  final Color dayBg, dayText, nightBg, nightText;
  const _QuoteTone(this.dayBg, this.dayText, this.nightBg, this.nightText);
}

const List<_QuoteTone> _quoteTones = [
  _QuoteTone(Color(0xFFF7F3EA), Color(0xFF1C1710), Color(0xFF1B170F), Color(0xFFF3EEE2)),
  _QuoteTone(Color(0xFFE8EDE1), Color(0xFF1F2E1B), Color(0xFF161C14), Color(0xFFE3ECD9)),
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

// ── Badge jenis — fade keluar waktu siang (editorial clean) ──
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

// ── Bookmark terapung ─────────────────────────────────────────
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

// ── Dash line (untuk tiket acara) ────────────────────────────
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

  // ── VIDEO (gaya bulatan HIJAU) ────────────────────────────
  // Foto hero penuh atas, tiada progress bar, tiada scrim teks,
  // tajuk Playfair besar bawah atas latar palette.surface.
  Widget _buildVideo() {
    final Color accent = kTypeVideo;
    final int h = post.id.hashCode.abs();
    final int fakeMinutes = 1 + h % 12;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final double chromeOpacity = (1 - palette.t).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Foto hero ─────────────────────────────────────
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImg
                  ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(_palettes[h % _palettes.length], 'video'))
                  : _gradBg(_palettes[h % _palettes.length], 'video'),

              // Scrim lembut — bukan teks overlay, cuma enhance kontra
              // play button supaya nampak pada foto terang.
              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x33000000)],
                    stops: [0.6, 1.0],
                  ),
                )),
              ),

              // Play button — fungsian, kekal walaupun chrome lain kurang
              Center(
                child: PopScaleIn(
                  delay: const Duration(milliseconds: 160),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.28),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 26, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Badge fade waktu siang, bookmark kekal
              Positioned(top: 10, left: 10,
                child: Opacity(opacity: chromeOpacity, child: _glassTag('video'))),
              Positioned(top: 10, right: 10, child: _floatingBookmark(palette)),
              // TIADA progress bar — dibuang (chrome noise)
            ],
          ),
        ),

        // ── Panel teks editorial ───────────────────────────
        Container(
          color: palette.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tajuk: Playfair Display besar, gelap, editorial
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 19, fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700, color: palette.textPrimary,
                    height: 1.28, letterSpacing: -0.2,
                  )),
              const SizedBox(height: 6),
              // Deskripsi ringkas — 2 baris, muted
              Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: palette.textSecondary,
                      height: 1.5)),
              const SizedBox(height: 14),
              Row(children: [
                _authorAvatar(post.author, accent, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('${post.author}  ·  $fakeMinutes min  ·  ${post.time}',
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

  // ── ARTIKEL (gaya bulatan HIJAU — sama seperti VIDEO) ─────
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
              // Scrim bawah lembut sahaja
              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x22000000)],
                    stops: [0.65, 1.0],
                  ),
                )),
              ),
              Positioned(top: 10, left: 10,
                  child: Opacity(opacity: chromeOpacity, child: _glassTag('article'))),
              Positioned(top: 10, right: 10, child: _floatingBookmark(palette)),
            ],
          ),
        ),

        Container(
          color: palette.surface,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 19, fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700, color: palette.textPrimary,
                    height: 1.28, letterSpacing: -0.2,
                  )),
              const SizedBox(height: 6),
              Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: palette.textSecondary, height: 1.5)),
              const SizedBox(height: 14),
              Row(children: [
                _authorAvatar(post.author, palette.accent, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('oleh ${post.author}  ·  ${post.time}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9.5, color: palette.textMuted,
                        fontWeight: FontWeight.w600))),
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

  // ── ACARA: tiket kekal ─────────────────────────────────────
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

  // ── KUOTA (gaya bulatan MERAH) ─────────────────────────────
  // Latar krim/sage bersih TANPA lattice. Tanda petik besar di atas
  // sebagai elemen dekoratif (bukan ikon fungsian), teks petikan
  // Playfair Display italic besar & gelap — rasa pull-quote majalah
  // premium atau halaman buku.
  Widget _buildQuote() {
    final _QuoteTone tone = _quoteTones[post.id.hashCode.abs() % _quoteTones.length];
    final Color bg   = Color.lerp(tone.nightBg,   tone.dayBg,   palette.t)!;
    final Color text = Color.lerp(tone.nightText,  tone.dayText, palette.t)!;
    // Warna tanda petik: emas jenama (waktu siang) atau amber gelap
    // (waktu malam) — kontras cukup tapi tak dominan.
    final Color quoteMarkColor = Color.lerp(
      kPrimaryGold.withOpacity(0.22),
      kGoldLight.withOpacity(0.14),
      palette.t,
    )!;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tanda petik buka — dekoratif, saiz besar, warna muted
          Text('\u201C',
              style: GoogleFonts.playfairDisplay(
                fontSize: 64, color: quoteMarkColor,
                fontWeight: FontWeight.w900, height: 0.7,
              )),
          const SizedBox(height: 10),
          // Teks petikan — HERO tiada tandingan, besar, italic, gelap
          Text(post.content, maxLines: 8, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: 17.5, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600, color: text,
                height: 1.52, letterSpacing: -0.1,
              )),
          const SizedBox(height: 20),
          // Metadata — minimal, kecil, diletakkan jauh di bawah
          Row(children: [
            Container(width: 22, height: 1.5, color: text.withOpacity(0.40)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(post.author, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700,
                      color: text.withOpacity(0.70), letterSpacing: 0.2)),
            ),
            const SizedBox(width: 4),
            PopLikeButton(baseCount: post.likes, iconSize: 11,
                mutedColor: text.withOpacity(0.40), likedColor: text,
                countStyle: TextStyle(fontSize: 9.5, color: text.withOpacity(0.55))),
          ]),
        ],
      ),
    );
  }

  // Fallback gradient — bila post takde assetPath
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
