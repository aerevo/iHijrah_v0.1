// lib/widgets/feed_card.dart
// Netflix-style — full width, image cover, frosted caption bottom

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── FRASA ISLAMIK ─────────────────────────────────────────────
const List<_Phrase> _phrases = [
  _Phrase('بِسْمِ اللَّهِ',     'Bismillah',     Color(0xFFD4A017), Color(0x25D4A017)),
  _Phrase('الْحَمْدُ لِلَّهِ',  'Alhamdulillah', Color(0xFF22C55E), Color(0x2522C55E)),
  _Phrase('سُبْحَانَ اللَّهِ',  'Subhanallah',   Color(0xFF38BDF8), Color(0x2538BDF8)),
  _Phrase('إِنْ شَاءَ اللَّهُ','InsyaAllah',    Color(0xFFA78BFA), Color(0x25A78BFA)),
  _Phrase('اللَّهُ أَكْبَرُ',  'Allahuakbar',  Color(0xFFEF4444), Color(0x25EF4444)),
  _Phrase('مَا شَاءَ اللَّهُ', 'MashaAllah',   Color(0xFF0EA5E9), Color(0x250EA5E9)),
];

class _Phrase {
  final String ar, latin;
  final Color color, bg;
  const _Phrase(this.ar, this.latin, this.color, this.bg);
}

// ── TYPE COLOR ────────────────────────────────────────────────
Color _tc(String t) {
  switch (t) {
    case 'video':   return const Color(0xFFEF4444);
    case 'article': return const Color(0xFFF59E0B);
    case 'event':   return const Color(0xFF34D399);
    case 'quote':   return const Color(0xFFA78BFA);
    default:        return kPrimaryGold;
  }
}
String _tl(String t) {
  switch (t) {
    case 'video':   return '▶  VIDEO';
    case 'article': return '📄  ARTIKEL';
    case 'event':   return '📅  ACARA';
    case 'quote':   return '❝  PETIKAN';
    default:        return t.toUpperCase();
  }
}

const List<Shadow> _sh = [
  Shadow(color: Color(0xCC000000), blurRadius: 8,  offset: Offset(0,1)),
  Shadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0,3)),
];

// ── GRADIENT BG PALETTES ──────────────────────────────────────
const List<List<Color>> _palettes = [
  [Color(0xFF0A0E1A), Color(0xFF1B2A4A), Color(0xFF0d1b2e)],
  [Color(0xFF1A0A00), Color(0xFF3D2000), Color(0xFF6B3800)],
  [Color(0xFF001A0A), Color(0xFF003D1A), Color(0xFF005A2E)],
  [Color(0xFF10001A), Color(0xFF2D1060), Color(0xFF4A1890)],
  [Color(0xFF001520), Color(0xFF003355), Color(0xFF005A8A)],
  [Color(0xFF1A0010), Color(0xFF3D0030), Color(0xFF6B0050)],
];

// ── FEED CARD ─────────────────────────────────────────────────
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
    final int pi = post.id.hashCode.abs() % _palettes.length;
    final int phi = post.id.hashCode.abs() % _phrases.length;
    final _Phrase phrase = _phrases[phi];
    final List<Color> pal = _palettes[pi];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── BG ───────────────────────────────────────
              post.assetPath != null
                  ? Image.asset(
                      post.assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(pal),
                    )
                  : _gradBg(pal),

              // ── DARK OVERLAY — top subtle, heavy at bottom ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.38, 0.62, 0.82, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.60),
                      Colors.black.withOpacity(0.88),
                    ],
                  ),
                ),
              ),

              // ── TYPE BADGE — top left ─────────────────────
              Positioned(
                top: 18, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: accent.withOpacity(0.5), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    _tl(post.type),
                    style: TextStyle(
                      color: accent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      shadows: _sh,
                    ),
                  ),
                ),
              ),

              // ── ISLAMIC PHRASE — top right ────────────────
              Positioned(
                top: 14, right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      phrase.ar,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: phrase.color,
                        shadows: _sh,
                      ),
                    ),
                    Text(
                      phrase.latin,
                      style: TextStyle(
                        fontSize: 8.5,
                        color: phrase.color.withOpacity(0.75),
                        letterSpacing: 0.4,
                        shadows: _sh,
                      ),
                    ),
                  ],
                ),
              ),

              // ── CAPTION BLOCK — bottom ────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Title — big bold serif
                      Text(
                        post.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.15,
                          shadows: _sh,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 7),

                      // Content snippet
                      Text(
                        post.content,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.78),
                          height: 1.45,
                          shadows: _sh,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 14),

                      // Author row + actions
                      Row(
                        children: [

                          // Avatar circle
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                post.author.isNotEmpty
                                    ? post.author[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Name + time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: _sh,
                                  ),
                                ),
                                Text(
                                  post.time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.5),
                                    shadows: _sh,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Like
                          _Btn(
                            icon: Icons.favorite_border_rounded,
                            label: _fmt(post.likes),
                          ),
                          const SizedBox(width: 18),
                          // Comment
                          _Btn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: _fmt(post.likes ~/ 8),
                          ),
                          const SizedBox(width: 18),
                          // Share
                          _Btn(
                            icon: Icons.share_rounded,
                            label: '',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradBg(List<Color> pal) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: pal,
      ),
    ),
  );

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── ACTION BUTTON ─────────────────────────────────────────────
class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Btn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 22, color: Colors.white.withOpacity(0.85),
          shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 8)]),
      if (label.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withOpacity(0.75),
              shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 6)],
            ),
          ),
        ),
    ],
  );
}
