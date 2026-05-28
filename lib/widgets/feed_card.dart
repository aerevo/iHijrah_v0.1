// lib/widgets/feed_card.dart
// NETFLIX-STYLE FEED CARD
// Layout: full-bleed image/gradient → bottom gradient overlay
//         → title + meta + description overlaid → circular action button

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

// ── HELPERS ───────────────────────────────────────────────────

const List<Shadow> _sh = [
  Shadow(color: Color(0xDD000000), blurRadius: 8,  offset: Offset(0, 1)),
  Shadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 3)),
];

Color _typeColor(String t) {
  switch (t) {
    case 'video':   return const Color(0xFFEF4444);
    case 'article': return const Color(0xFFF59E0B);
    case 'event':   return const Color(0xFF34D399);
    case 'quote':   return const Color(0xFFA78BFA);
    default:        return kPrimaryGold;
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'video':   return '▶  VIDEO';
    case 'article': return '📄  ARTIKEL';
    case 'event':   return '📅  ACARA';
    case 'quote':   return '❝  PETIKAN';
    default:        return t.toUpperCase();
  }
}

// Background gradient palettes (used when no image)
const List<List<Color>> _pals = [
  [Color(0xFF0A1628), Color(0xFF1B3A6B), Color(0xFF0d1b2e)],
  [Color(0xFF1A0A00), Color(0xFF4A2800), Color(0xFF1a0e00)],
  [Color(0xFF001A0A), Color(0xFF004D1A), Color(0xFF001a0a)],
  [Color(0xFF10001A), Color(0xFF3D0D7A), Color(0xFF1a0030)],
  [Color(0xFF001520), Color(0xFF004466), Color(0xFF001020)],
];

// Islamic phrases
const List<_Phrase> _phrases = [
  _Phrase('بِسْمِ اللَّهِ',   'Bismillah',    Color(0xFFD4A017)),
  _Phrase('الْحَمْدُ لِلَّهِ','Alhamdulillah', Color(0xFF22C55E)),
  _Phrase('سُبْحَانَ اللَّهِ','Subhanallah',   Color(0xFF38BDF8)),
  _Phrase('إِنْ شَاءَ اللَّهُ','InsyaAllah',   Color(0xFFA78BFA)),
  _Phrase('اللَّهُ أَكْبَرُ', 'Allahuakbar',  Color(0xFFEF4444)),
  _Phrase('مَا شَاءَ اللَّهُ','MashaAllah',    Color(0xFF0EA5E9)),
];

class _Phrase {
  final String ar, latin;
  final Color color;
  const _Phrase(this.ar, this.latin, this.color);
}

// ── CARD ──────────────────────────────────────────────────────

class FeedCard extends StatelessWidget {
  final PostModel   post;
  final bool        isCenter;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    required this.isCenter,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color  accent = _typeColor(post.type);
    final int    pi     = post.id.hashCode.abs() % _pals.length;
    final int    phi    = post.id.hashCode.abs() % _phrases.length;
    final phrase        = _phrases[phi];
    final pal           = _pals[pi];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── 1. FULL-BLEED BACKGROUND ──────────────────
              post.assetPath != null
                  ? Image.asset(
                      post.assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(pal),
                    )
                  : _gradBg(pal),

              // ── 2. BOTTOM GRADIENT OVERLAY ────────────────
              // Strong dark gradient from bottom ~65% — same feel
              // as Mandalorian card, text readable without separate box
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.30, 0.55, 0.78, 1.0],
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x88000000),
                      Color(0xCC000000),
                      Color(0xF2000000),
                    ],
                  ),
                ),
              ),

              // ── 3. PHRASE (top-right) ─────────────────────
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      phrase.ar,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: phrase.color.withOpacity(0.85),
                        shadows: _sh,
                      ),
                    ),
                    Text(
                      phrase.latin,
                      style: TextStyle(
                        fontSize: 7,
                        color: phrase.color.withOpacity(0.60),
                        letterSpacing: 0.3,
                        shadows: _sh,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. BOTTOM INFO (overlaid, no box) ─────────
              Positioned(
                left: 12,
                right: 52, // leave space for the circular button
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Title
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        shadows: _sh,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Meta row: type · likes · time
                    Row(
                      children: [
                        Text(
                          _typeLabel(post.type),
                          style: TextStyle(
                            fontSize: 8,
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            shadows: _sh,
                          ),
                        ),
                        Text(
                          '  ·  ${_fmt(post.likes)} suka  ·  ${post.time}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white.withOpacity(0.55),
                            shadows: _sh,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Description
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.68),
                        height: 1.4,
                        shadows: _sh,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 5. CIRCULAR ACTION BUTTON (bottom-right) ──
              // Matches the play button position in the reference
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.92),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    post.type == 'video'
                        ? Icons.play_arrow_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: accent,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _gradBg(List<Color> pal) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: pal,
      ),
    ),
  );

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}
