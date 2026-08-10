// lib/widgets/feed_card.dart  (V8 — Premium Editorial)
//
// 6 perubahan serentak drpd V7:
// 1. Hero image → full-width, aspectRatio 0.75 (portrait tinggi)
// 2. CTA → button hitam penuh lebar "BACA LAGI ——→"
// 3. Whitespace → +30-50% pada semua spacing
// 4. Typography → headline 54px, height 0.88, letterSpacing -1.5
// 5. Grid → meta atas, hero full-bleed, konten padded, CTA full-bleed
// 6. Footer → opacity 0.12, icon 10px — sangat senyap
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../theme/feed_theme.dart';
import 'anim_helpers.dart';
import 'premium_glass.dart';

// ── TYPE MAPPING ──────────────────────────────────────────────
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

String _typeLabel(String t) {
  switch (t) {
    case 'video':   return 'Video';
    case 'article': return 'Tazkirah';
    case 'quote':   return 'Petikan';
    case 'hadith':  return 'Hadith';
    case 'amalan':  return 'Amalan';
    case 'sirah':   return 'Sirah';
    default:        return t;
  }
}

const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

class _QuoteTone {
  final Color dayBg, dayText, nightBg, nightText;
  const _QuoteTone(this.dayBg, this.dayText, this.nightBg, this.nightText);
}

const List<_QuoteTone> _quoteTones = [
  _QuoteTone(Color(0xFFF7F3EA), Color(0xFF1C1710),
             Color(0xFF1B170F), Color(0xFFF3EEE2)),
  _QuoteTone(Color(0xFFE8EDE1), Color(0xFF1F2E1B),
             Color(0xFF161C14), Color(0xFFE3ECD9)),
];

const List<String> _months = [
  'JAN','FEB','MAC','APR','MEI','JUN',
  'JUL','OGO','SEP','OKT','NOV','DIS',
];

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
        mutedColor:
            onImage ? Colors.white.withOpacity(0.9) : palette.textSecondary,
        savedColor: onImage ? kGoldLight : palette.accent,
      ),
    ),
  );
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

// ══════════════════════════════════════════════════════════════
// FEED CARD  (V8 — Premium Editorial)
// ══════════════════════════════════════════════════════════════
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
        child: _layoutFor(post.type),
      ),
    );
  }

  Widget _layoutFor(String t) {
    switch (t) {
      case 'video':   return _buildEditorial(isVideo: true);
      case 'article': return _buildEditorial();
      case 'event':   return _buildTicket();
      case 'quote':
      case 'hadith':  return _buildQuote();
      default:        return _buildEditorial();
    }
  }

  // ════════════════════════════════════════════════════════
  // INSTANCE HELPERS
  // ════════════════════════════════════════════════════════

  // ── Gold tick + kategori ─────────────────────────────────
  Widget _metaRow() {
    final String cat = (post.category?.isNotEmpty == true
            ? post.category! : _typeLabel(post.type)).toUpperCase();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 16, height: 1.5, color: kGoldMid),
      const SizedBox(width: 10),
      Text(cat,
          style: const TextStyle(
            fontSize: 10, letterSpacing: 2.4,
            fontWeight: FontWeight.w800, color: kGoldDeep,
          )),
    ]);
  }

  // ── Author badge dalam hero ───────────────────────────────
  Widget _heroAuthorBadge() {
    final String age =
        post.authorAge.isNotEmpty ? ' · ${post.authorAge}' : '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black.withOpacity(0.55),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 15, height: 15, alignment: Alignment.center,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: kGoldMid),
              child: const Icon(Icons.person_rounded,
                  size: 9, color: Color(0xFF15130F)),
            ),
            const SizedBox(width: 6),
            Text('${post.author}$age'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600,
                  letterSpacing: 0.5, color: Color(0xEAFFFFFF),
                )),
          ]),
        ),
      ),
    );
  }

  // ── Author badge dalam bar hitam quote ───────────────────
  Widget _quoteAuthorBadge() {
    final String age =
        post.authorAge.isNotEmpty ? ' · ${post.authorAge}' : '';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 15, height: 15, alignment: Alignment.center,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: kGoldMid),
        child: const Icon(Icons.person_rounded,
            size: 9, color: Color(0xFF15130F)),
      ),
      const SizedBox(width: 6),
      Text('${post.author}$age'.toUpperCase(),
          style: const TextStyle(
            fontSize: 9, fontWeight: FontWeight.w600,
            letterSpacing: 0.4, color: Color(0xD9F5F1E6),
          )),
    ]);
  }

  // ── Hero image — FULL WIDTH, portrait tinggi ─────────────
  // Perubahan V8: FractionallySizedBox 76% → full-width
  // aspectRatio 0.82 → 0.75 (lebih tinggi, lebih dominan)
  Widget _heroImage({bool isVideo = false}) {
    final int h = post.id.hashCode.abs();
    final bool hasImg =
        post.assetPath != null && post.assetPath!.isNotEmpty;

    return AspectRatio(
      aspectRatio: 0.75,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar atau gradient fallback
          hasImg
              ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _gradBg(_palettes[h % _palettes.length], post.type))
              : _gradBg(_palettes[h % _palettes.length], post.type),

          // Scrim bawah — gradient lebih dalam untuk CTA kontras
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x55000000)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
          ),

          // Play button — video sahaja
          if (isVideo)
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
                        color: Colors.black.withOpacity(0.30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.85),
                            width: 1.2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

          // Author badge — kanan bawah
          Positioned(
            right: 14, bottom: 14,
            child: _heroAuthorBadge(),
          ),
        ],
      ),
    );
  }

  // ── Headline editorial — Playfair split, lebih besar ─────
  // V8: fontSize 46→54, height 0.95→0.88, letterSpacing -1.0→-1.5
  Widget _editorialHeadline() {
    final List<String> words = post.title.trim().split(RegExp(r'\s+'));

    final TextStyle bigStyle = GoogleFonts.playfairDisplay(
      fontSize: 54,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
      height: 0.88,
      letterSpacing: -1.5,
    );
    final TextStyle bridgeStyle = GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
      color: palette.textSecondary,
      height: 0.88,
      letterSpacing: -0.3,
    );

    if (words.length == 1) {
      return Text(words[0].toUpperCase(), style: bigStyle);
    }
    if (words.length == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(words[0].toUpperCase(), style: bigStyle),
          const SizedBox(height: 6),
          Text(words[1].toUpperCase(), style: bigStyle),
        ],
      );
    }
    final String bridgeText = words.sublist(1, words.length - 1).join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(words[0].toUpperCase(), style: bigStyle),
            const SizedBox(width: 12),
            Flexible(child: Text(bridgeText,
                style: bridgeStyle, overflow: TextOverflow.ellipsis)),
          ],
        ),
        Text(words.last.toUpperCase(), style: bigStyle),
      ],
    );
  }

  // ── Badan teks dengan fade mask ───────────────────────────
  // V8: height 1.90→1.75, weight w500→w400 (lebih ringan, editorial)
  Widget _fadingBody() {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.black,
                 Color(0xA6000000), Color(0x1A000000)],
        stops: [0.0, 0.45, 0.75, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Text(post.content, maxLines: 4,
          style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400,
            height: 1.75, color: palette.textPrimary, letterSpacing: -0.1,
          )),
    );
  }

  // ── CTA button penuh lebar — editorial ───────────────────
  // V8: ganti text link → black full-width button (macam Image 4)
  Widget _bacaLagiButton() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF15130F),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('BACA LAGI',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  letterSpacing: 1.6, color: Color(0xFFF5F1E6),
                )),
            // Dash + arrow, seperti Image 4
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 28, height: 1,
                  color: const Color(0xFFF5F1E6)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: Color(0xFFF5F1E6)),
            ]),
          ],
        ),
      ),
    );
  }

  // ── CTA text link — untuk dalam panel quote ───────────────
  Widget _bacaLagiLink() {
    return GestureDetector(
      onTap: onTap,
      child: const Text('Baca lagi →',
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 0.8, color: kGoldDeep,
          )),
    );
  }

  // ── Ghost engagement row — sangat senyap ─────────────────
  // V8: opacity 0.20→0.12, icon 12→10, font 9.5→8.5
  Widget _ghostEngageRow() {
    return Opacity(
      opacity: 0.12,
      child: Row(children: [
        Icon(Icons.favorite_rounded, size: 10, color: palette.textPrimary),
        const SizedBox(width: 5),
        Text(post.likes.toString(),
            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600,
                color: palette.textPrimary)),
        const SizedBox(width: 16),
        Icon(Icons.chat_bubble_outline_rounded,
            size: 10, color: palette.textPrimary),
        const SizedBox(width: 5),
        Text(post.commentsCount.toString(),
            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600,
                color: palette.textPrimary)),
        const SizedBox(width: 16),
        Icon(Icons.share_outlined, size: 10, color: palette.textPrimary),
      ]),
    );
  }

  // ── Bar hitam ATAS quote ──────────────────────────────────
  Widget _quoteTopBar() {
    final String cat = (post.category?.isNotEmpty == true
            ? post.category! : _typeLabel(post.type)).toUpperCase();
    return Container(
      color: const Color(0xFF15130F),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.format_quote_rounded,
                size: 16, color: kGoldMid),
            const SizedBox(width: 7),
            Text(cat,
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.6, color: Color(0xCCF5F1E6),
                )),
          ]),
          _quoteAuthorBadge(),
        ],
      ),
    );
  }

  // ── Bar hitam BAWAH quote — engage putih ─────────────────
  Widget _quoteBottomBar() {
    return Container(
      color: const Color(0xFF15130F),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(children: [
        PopLikeButton(
          baseCount: post.likes, iconSize: 13,
          mutedColor: const Color(0xFFF5F1E6),
          likedColor: const Color(0xFFE8433F),
          countStyle: const TextStyle(fontSize: 9.5,
              fontWeight: FontWeight.w600, color: Color(0xFFF5F1E6)),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.chat_bubble_outline_rounded,
            size: 13, color: Color(0xFFF5F1E6)),
        const SizedBox(width: 5),
        Text(post.commentsCount.toString(),
            style: const TextStyle(fontSize: 9.5,
                fontWeight: FontWeight.w600, color: Color(0xFFF5F1E6))),
        const SizedBox(width: 16),
        const Icon(Icons.share_outlined,
            size: 13, color: Color(0xFFF5F1E6)),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  // BUILDERS
  // ════════════════════════════════════════════════════════

  // ── EDITORIAL — VIDEO & ARTIKEL ─────────────────────────
  // V8 layout (mengikut Image 4):
  //  hairline → [pad] meta → hero FULL BLEED →
  //  [pad] headline → body → engage ghost →
  //  CTA button FULL BLEED → whitespace
  Widget _buildEditorial({bool isVideo = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ① Hairline pemisah
        Container(height: 1.5,
            color: palette.textPrimary.withOpacity(0.85)),

        // ② Meta row — padded
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          child: _metaRow(),
        ),

        // ③ Hero image — FULL BLEED, tiada horizontal padding
        _heroImage(isVideo: isVideo),

        // ④ Konten teks — padded, whitespace lebih lega
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _editorialHeadline(),
              const SizedBox(height: 28),
              _fadingBody(),
              const SizedBox(height: 28),
              _ghostEngageRow(),
            ],
          ),
        ),

        // ⑤ CTA button — FULL BLEED hitam
        _bacaLagiButton(),

        // ⑥ Whitespace bawah — ruang nafas sebelum post seterusnya
        const SizedBox(height: 44),
      ],
    );
  }

  // ── KUOTA / HADITH ──────────────────────────────────────
  Widget _buildQuote() {
    final _QuoteTone tone =
        _quoteTones[post.id.hashCode.abs() % _quoteTones.length];
    final Color bg   = Color.lerp(tone.nightBg, tone.dayBg, palette.t)!;
    final Color text = Color.lerp(tone.nightText, tone.dayText, palette.t)!;
    final Color quoteMarkColor = Color.lerp(
      kPrimaryGold.withOpacity(0.22),
      kGoldLight.withOpacity(0.14),
      palette.t,
    )!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: palette.divider),
        _quoteTopBar(),
        Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\u201C',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 60, color: quoteMarkColor,
                    fontWeight: FontWeight.w900, height: 0.7,
                  )),
              const SizedBox(height: 12),
              Text(post.content,
                  maxLines: 8, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17, fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600, color: text,
                    height: 1.55, letterSpacing: -0.1,
                  )),
              const SizedBox(height: 22),
              Row(children: [
                Container(width: 22, height: 1.5,
                    color: text.withOpacity(0.35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(post.author,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w700,
                        color: text.withOpacity(0.65), letterSpacing: 0.2,
                      )),
                ),
              ]),
              const SizedBox(height: 20),
              _bacaLagiLink(),
              const SizedBox(height: 26),
            ],
          ),
        ),
        _quoteBottomBar(),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── ACARA: TIKET ────────────────────────────────────────
  Widget _buildTicket() {
    final int h = post.id.hashCode.abs();
    final String day = (1 + h % 28).toString().padLeft(2, '0');
    final String month = _months[h % 12];
    const LinearGradient dateGradient = LinearGradient(
        colors: [Color(0xFF3E8EF0), Color(0xFF2563C9)],
        begin: Alignment.topLeft, end: Alignment.bottomRight);
    const Color dateAccent = Color(0xFF2563C9);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: palette.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: dateGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(day, style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, height: 1.1)),
                Text(month, style: const TextStyle(fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70, letterSpacing: 1.2)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary, height: 1.3)),
                const SizedBox(height: 5),
                Row(children: [
                  Icon(Icons.access_time_rounded,
                      size: 10, color: palette.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text('8:00 pagi',
                      style: TextStyle(fontSize: 9.5,
                          color: palette.textMuted,
                          fontWeight: FontWeight.w600))),
                ]),
              ],
            )),
            _floatingBookmark(palette, onImage: false),
          ]),
        ),
        LayoutBuilder(builder: (c, cons) => CustomPaint(
              size: Size(cons.maxWidth, 2),
              painter: _DashLinePainter(palette.divider))),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          child: Row(children: [
            _authorAvatar(post.author, dateAccent, size: 16),
            const SizedBox(width: 6),
            Expanded(child: Text(post.author, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5,
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: dateAccent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DAFTAR',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800,
                      color: dateAccent, letterSpacing: 0.8)),
            ),
            const SizedBox(width: 6),
            PopLikeButton(
              baseCount: post.likes, iconSize: 11.5,
              mutedColor: palette.textMuted,
              likedColor: const Color(0xFFE8433F),
              countStyle: TextStyle(fontSize: 9.5, color: palette.textMuted),
            ),
          ]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _gradBg(List<Color> colors, String type) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Stack(: [
          Positioned(right: -12, bottom: -12,
            : Icon(
                type == 'video' ? Icons.videocam_rounded : _typeIcon(type),
                size: 90, color: Colors.white.withOpacity(0.05))),
        ]),
      );
}
