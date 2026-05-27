// lib/widgets/feed_card.dart
// PREMIUM CINEMATIC FEED CARD

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// PHRASES
// ─────────────────────────────────────────────────────────────

const List<_Phrase> _phrases = [

  _Phrase(
    'بِسْمِ اللَّهِ',
    'Bismillah',
    Color(0xFFD4A017),
    Color(0x25D4A017),
  ),

  _Phrase(
    'الْحَمْدُ لِلَّهِ',
    'Alhamdulillah',
    Color(0xFF22C55E),
    Color(0x2522C55E),
  ),

  _Phrase(
    'سُبْحَانَ اللَّهِ',
    'Subhanallah',
    Color(0xFF38BDF8),
    Color(0x2538BDF8),
  ),

  _Phrase(
    'إِنْ شَاءَ اللَّهُ',
    'InsyaAllah',
    Color(0xFFA78BFA),
    Color(0x25A78BFA),
  ),

  _Phrase(
    'اللَّهُ أَكْبَرُ',
    'Allahuakbar',
    Color(0xFFEF4444),
    Color(0x25EF4444),
  ),

  _Phrase(
    'مَا شَاءَ اللَّهُ',
    'MashaAllah',
    Color(0xFF0EA5E9),
    Color(0x250EA5E9),
  ),
];

class _Phrase {

  final String ar;

  final String latin;

  final Color color;

  final Color bg;

  const _Phrase(
    this.ar,
    this.latin,
    this.color,
    this.bg,
  );
}

// ─────────────────────────────────────────────────────────────

Color _tc(String t) {

  switch (t) {

    case 'video':
      return const Color(0xFFEF4444);

    case 'article':
      return const Color(0xFFF59E0B);

    case 'event':
      return const Color(0xFF34D399);

    case 'quote':
      return const Color(0xFFA78BFA);

    default:
      return kPrimaryGold;
  }
}

String _tl(String t) {

  switch (t) {

    case 'video':
      return '▶ VIDEO';

    case 'article':
      return '📄 ARTIKEL';

    case 'event':
      return '📅 ACARA';

    case 'quote':
      return '❝ PETIKAN';

    default:
      return t.toUpperCase();
  }
}

const List<Shadow> _sh = [

  Shadow(
    color: Color(0xCC000000),
    blurRadius: 8,
    offset: Offset(0, 1),
  ),

  Shadow(
    color: Color(0x88000000),
    blurRadius: 18,
    offset: Offset(0, 3),
  ),
];

// ─────────────────────────────────────────────────────────────

const List<List<Color>> _palettes = [

  [
    Color(0xFF0A0E1A),
    Color(0xFF1B2A4A),
    Color(0xFF0d1b2e),
  ],

  [
    Color(0xFF1A0A00),
    Color(0xFF3D2000),
    Color(0xFF6B3800),
  ],

  [
    Color(0xFF001A0A),
    Color(0xFF003D1A),
    Color(0xFF005A2E),
  ],

  [
    Color(0xFF10001A),
    Color(0xFF2D1060),
    Color(0xFF4A1890),
  ],

  [
    Color(0xFF001520),
    Color(0xFF003355),
    Color(0xFF005A8A),
  ],
];

// ─────────────────────────────────────────────────────────────
// FEED CARD
// ─────────────────────────────────────────────────────────────

class FeedCard extends StatelessWidget {

  final PostModel post;

  final bool isCenter;

  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    required this.isCenter,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final Color accent = _tc(post.type);

    final int pi =
        post.id.hashCode.abs() % _palettes.length;

    final int phi =
        post.id.hashCode.abs() % _phrases.length;

    final _Phrase phrase = _phrases[phi];

    final List<Color> pal = _palettes[pi];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.15),
                blurRadius: 55,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              fit: StackFit.expand,
              children: [

                // BG

                post.assetPath != null
                    ? Image.asset(
                        post.assetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _gradBg(pal),
                      )
                    : _gradBg(pal),

                // DARK OVERLAY

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [
                        0.0,
                        0.32,
                        0.60,
                        0.82,
                        1.0,
                      ],
                      colors: [
                        Colors.black.withOpacity(0.18),
                        Colors.transparent,
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.44),
                        Colors.black.withOpacity(0.70),
                      ],
                    ),
                  ),
                ),

                // TOP BADGES

                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: accent.withOpacity(0.45),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _tl(post.type),
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        shadows: _sh,
                      ),
                    ),
                  ),
                ),

                // PHRASE

                Positioned(
                  top: 14,
                  right: 16,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [

                      Text(
                        phrase.ar,
                        style: GoogleFonts.amiri(
                          fontSize: 13,
                          color: phrase.color,
                          shadows: _sh,
                        ),
                      ),

                      Text(
                        phrase.latin,
                        style: TextStyle(
                          fontSize: 8,
                          color: phrase.color.withOpacity(0.72),
                          letterSpacing: 0.3,
                          shadows: _sh,
                        ),
                      ),
                    ],
                  ),
                ),

                // BOTTOM CAPTION

                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 18,
                        sigmaY: 18,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.15,
                                shadows: _sh,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              post.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.76),
                                height: 1.45,
                                shadows: _sh,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [

                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(0.20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1.3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      post.author.isNotEmpty
                                          ? post.author[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        post.author,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          shadows: _sh,
                                        ),
                                      ),

                                      Text(
                                        post.time,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white.withOpacity(0.55),
                                          shadows: _sh,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                _Btn(
                                  icon: Icons.favorite_border_rounded,
                                  label: _fmt(post.likes),
                                ),

                                const SizedBox(width: 18),

                                _Btn(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: _fmt(post.likes ~/ 8),
                                ),

                                const SizedBox(width: 18),

                                const _Btn(
                                  icon: Icons.share_rounded,
                                  label: '',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradBg(List<Color> pal) {

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pal,
        ),
      ),
    );
  }

  static String _fmt(int n) {

    return n >= 1000
        ? '${(n / 1000).toStringAsFixed(1)}k'
        : '$n';
  }
}

// ─────────────────────────────────────────────────────────────
// BUTTON
// ─────────────────────────────────────────────────────────────

class _Btn extends StatelessWidget {

  final IconData icon;

  final String label;

  const _Btn({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          size: 21,
          color: Colors.white.withOpacity(0.85),
          shadows: const [
            Shadow(
              color: Color(0xCC000000),
              blurRadius: 8,
            ),
          ],
        ),

        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.72),
                shadows: const [
                  Shadow(
                    color: Color(0xCC000000),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
