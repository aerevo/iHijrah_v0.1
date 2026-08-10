// lib/widgets/feed_card.dart  (V9 — Manual Precision)
// Salin fail ni → gantikan lib/widgets/feed_card.dart dalam project

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../theme/feed_theme.dart';
import 'anim_helpers.dart';

const Color _kBar   = Color(0xFF1A1410);
const Color _kCream = Color(0xFFF5F1E6);
const Color _kPage  = Color(0xFFEDE9D8);
const Color _kGold  = Color(0xFFC9A84C);
const Color _kGoldD = Color(0xFF7A5C0F);

const List<List<Color>> _grads = [
  [Color(0xFF46301E), Color(0xFF1C0E06)],
  [Color(0xFF182530), Color(0xFF081218)],
  [Color(0xFF1E3228), Color(0xFF0D1A15)],
  [Color(0xFF2A1F2E), Color(0xFF120D18)],
  [Color(0xFF38200E), Color(0xFF180C06)],
  [Color(0xFF1A2838), Color(0xFF0C1420)],
];

const List<String> _months = [
  'JAN','FEB','MAC','APR','MEI','JUN',
  'JUL','OGO','SEP','OKT','NOV','DIS',
];

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter(this.color);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const d = 4.0, g = 4.0;
    for (double x = 0; x < s.width; x += d + g) {
      c.drawLine(Offset(x, s.height / 2),
          Offset(math.min(x + d, s.width), s.height / 2), p);
    }
  }
  @override
  bool shouldRepaint(_DashPainter o) => o.color != color;
}

class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final FeedPalette palette;

  const FeedCard({
    Key? key,
    required this.post,
    required this.palette,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: PressableScale(onTap: onTap, child: _layoutFor(post.type)),
  );

  Widget _layoutFor(String t) {
    switch (t) {
      case 'video':     return _buildVideo();
      case 'article':
      case 'sirah':
      case 'amalan':
      case 'tazkirah':  return _buildArticle();
      case 'quote':     return _buildQuote();
      case 'hadith':    return _buildHadith();
      case 'event':     return _buildTicket();
      default:          return _buildArticle();
    }
  }

  Color get _ink   => palette.textPrimary;
  Color get _muted => palette.textMuted;
  Color get _surf  => palette.surface;

  Widget _gradBg(int seed) {
    final g = _grads[seed % _grads.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: g,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.4, -0.45),
              radius: 0.65,
              colors: [
                Colors.amber.withOpacity(0.18),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroWidget({bool hasPlay = false}) {
    final seed   = post.id.hashCode.abs();
    final hasImg = post.assetPath?.isNotEmpty == true;
    return Stack(
      fit: StackFit.expand,
      children: [
        hasImg
            ? Image.asset(
                post.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _gradBg(seed),
              )
            : _gradBg(seed),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0x66000000)],
                stops: [0.48, 1.0],
              ),
            ),
          ),
        ),
        if (hasPlay)
          Center(
            child: ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.60),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _heroBadge() {
    final age  = post.authorAge.isNotEmpty ? ' · ${post.authorAge}' : '';
    final time = post.time.isNotEmpty      ? ' · ${post.time}'      : '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black.withOpacity(0.50),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, size: 9, color: _kBar),
              ),
              const SizedBox(width: 5),
              Text(
                '${post.author}$age$time'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: Color(0xEAFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headline({double lx = 22, double bx = 44}) {
    final w = post.title.trim().split(RegExp(r'\s+'));
    if (w.isEmpty) return const SizedBox.shrink();
    final light = w.first;
    final bold  = w.length > 1 ? w.skip(1).join('\n') : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          light,
          style: GoogleFonts.playfairDisplay(
            fontSize: lx,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            color: _ink,
            height: 1.10,
            letterSpacing: -0.3,
            shadows: const [
              Shadow(
                color: Color(0x121C1611),
                blurRadius: 10,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        if (bold.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: bold,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: bx,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    height: 0.94,
                    letterSpacing: -0.8,
                    shadows: const [
                      Shadow(
                        color: Color(0x1E1C1611),
                        blurRadius: 14,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                TextSpan(
                  text: '_',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: bx,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: _kGold,
                    height: 0.94,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cat(String s) => Text(
    s.toUpperCase(),
    style: const TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: _kGoldD,
    ),
  );

  Widget _bacaLagi({String label = 'Baca lagi →'}) => GestureDetector(
    onTap: onTap,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: GoogleFonts.ebGaramond(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          color: _kGoldD,
          letterSpacing: 0.1,
        ),
      ),
    ),
  );

  Widget _fadeBody({int maxLines = 4}) => ShaderMask(
    shaderCallback: (r) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black,
        Colors.black,
        Color(0x88000000),
        Color(0x00000000),
      ],
      stops: [0.0, 0.42, 0.76, 1.0],
    ).createShader(r),
    blendMode: BlendMode.dstIn,
    child: Text(
      post.content,
      maxLines: maxLines,
      style: GoogleFonts.ebGaramond(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.72,
        color: _ink,
        letterSpacing: 0.05,
      ),
    ),
  );

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  String _catStr(String fb) =>
      post.category?.isNotEmpty == true ? post.category! : fb;

  // ── ARTIKEL ───────────────────────────────────────────────
  Widget _buildArticle() {
    return Container(
      color: _surf,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1.5, color: _ink.withOpacity(0.72)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: _cat(_catStr('Tazkirah')),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14, right: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.68,
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _heroWidget(),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: _heroBadge(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: _headline(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: _fadeBody(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: _bacaLagi(),
          ),
        ],
      ),
    );
  }

  // ── VIDEO ─────────────────────────────────────────────────
  Widget _buildVideo() {
    final dur = post.time.isNotEmpty ? post.time : '12:34';
    return Container(
      color: _surf,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1.5, color: _ink.withOpacity(0.72)),
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 32, right: 32),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _heroWidget(hasPlay: true),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Text(
                      _catStr('Video').toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: _kGold.withOpacity(0.90),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: Colors.black.withOpacity(0.65),
                      child: Text(
                        dur,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: _heroBadge(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _headline(lx: 22, bx: 42),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _fadeBody(maxLines: 3),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: _bacaLagi(label: 'Tonton →'),
          ),
        ],
      ),
    );
  }

  // ── PETIKAN ───────────────────────────────────────────────
  Widget _buildQuote() {
    final time    = post.time.isNotEmpty ? post.time : '1 hari lalu';
    final pageCol = Color.lerp(
      const Color(0xFF0E0C09),
      _kPage,
      palette.t,
    )!;

    return Container(
      color: pageCol,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: _kBar,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 18,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _kCream,
                    letterSpacing: 0.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 11,
                      color: _kCream.withOpacity(0.80),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _fmt(post.likes),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: _kCream,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 11,
                      color: _kCream.withOpacity(0.80),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentsCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: _kCream,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: pageCol,
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\u201C',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _kGold.withOpacity(0.14),
                      height: 0.75,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  post.content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 21,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: _ink,
                    height: 1.52,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '— ${post.author}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _muted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                _bacaLagi(),
              ],
            ),
          ),
          Container(
            color: _kBar,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kCream.withOpacity(0.35),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    post.author.isNotEmpty
                        ? post.author[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kCream,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.authorAge.isNotEmpty
                          ? '${post.author} · ${post.authorAge}'
                          : post.author,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _kCream,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      'Dikongsikan',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w400,
                        color: _kCream.withOpacity(0.42),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── HADITH ────────────────────────────────────────────────
  Widget _buildHadith() {
    final time = post.time.isNotEmpty ? post.time : '3 hari lalu';
    return Container(
      color: _kBar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _catStr('Hadith').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: _kGold,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Color(0x66F5F1E6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            color: Colors.white.withOpacity(0.08),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Text(
              post.content,
              style: GoogleFonts.ebGaramond(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFEDE9DC),
                height: 1.60,
                letterSpacing: -0.1,
              ),
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            color: Colors.white.withOpacity(0.08),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              post.author,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Color(0x5DF5F1E6),
                height: 1.55,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Baca lagi →',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: _kGold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 12,
                      color: _kCream.withOpacity(0.32),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _fmt(post.likes),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: _kCream.withOpacity(0.32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TIKET ─────────────────────────────────────────────────
  Widget _buildTicket() {
    final seed  = post.id.hashCode.abs();
    final day   = (1 + seed % 28).toString().padLeft(2, '0');
    final month = _months[seed % 12];
    const accent = Color(0xFF2563C9);

    return Container(
      color: _surf,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: palette.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3E8EF0), accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        month,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xB3FFFFFF),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '⏰  ${post.time.isNotEmpty ? post.time : "8:00 pagi"}',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: _muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (c, con) => CustomPaint(
              size: Size(con.maxWidth, 2),
              painter: _DashPainter(palette.divider),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Row(
              children: [
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.14),
                    border: Border.all(color: accent.withOpacity(0.28)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    post.author.isNotEmpty
                        ? post.author[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    post.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: _muted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'DAFTAR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PopLikeButton(
                  baseCount: post.likes,
                  iconSize: 11,
                  mutedColor: palette.textMuted,
                  likedColor: const Color(0xFFE8433F),
                  countStyle: TextStyle(
                    fontSize: 9.5,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
