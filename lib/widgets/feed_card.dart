// lib/widgets/feed_card.dart
// Full-screen card — gambar penuh, caption overlay bawah

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── FRASA ISLAMIK ─────────────────────────────────────────────
class IslamicPhrase {
  final String arabic;
  final String latin;
  final Color color;
  final Color bg;
  const IslamicPhrase({
    required this.arabic,
    required this.latin,
    required this.color,
    required this.bg,
  });
}

const List<IslamicPhrase> kIslamicPhrases = [
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     color: Color(0xFFF59E0B), bg: Color(0x1FF59E0B)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', color: Color(0xFF059669), bg: Color(0x1F059669)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   color: Color(0xFF0284C7), bg: Color(0x1F0284C7)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    color: Color(0xFF7C3AED), bg: Color(0x1F7C3AED)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  color: Color(0xFFDC2626), bg: Color(0x1FDC2626)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   color: Color(0xFF0891B2), bg: Color(0x1F0891B2)),
];

// ── WARNA IKUT TYPE ───────────────────────────────────────────
Color _typeColor(String type) {
  switch (type) {
    case 'video':   return const Color(0xFFEF4444);
    case 'article': return const Color(0xFFF59E0B);
    case 'event':   return const Color(0xFF34D399);
    case 'quote':   return const Color(0xFFA78BFA);
    default:        return kPrimaryGold;
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'video':   return '▶  VIDEO';
    case 'article': return '📄  ARTIKEL';
    case 'event':   return '📅  ACARA';
    case 'quote':   return '❝  PETIKAN';
    default:        return type.toUpperCase();
  }
}

// ── SHADOWS ───────────────────────────────────────────────────
const List<Shadow> _kShadow = [
  Shadow(color: Color(0xCC000000), blurRadius: 8,  offset: Offset(0, 1)),
  Shadow(color: Color(0x88000000), blurRadius: 20, offset: Offset(0, 3)),
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
    final Color accent  = _typeColor(post.type);
    final String label  = _typeLabel(post.type);
    final int phraseIdx = post.id.hashCode % kIslamicPhrases.length;
    final IslamicPhrase phrase = kIslamicPhrases[phraseIdx.abs()];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── BG IMAGE / GRADIENT ───────────────────────
              if (post.assetPath != null)
                Image.asset(
                  post.assetPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _gradientBg(accent),
                )
              else
                _gradientBg(accent),

              // ── GRADIENT OVERLAY ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.65, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.88),
                    ],
                  ),
                ),
              ),

              // ── TYPE BADGE — top left ─────────────────────
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: accent.withOpacity(0.5), width: 0.8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      shadows: _kShadow,
                    ),
                  ),
                ),
              ),

              // ── ISLAMIC PHRASE — top right ────────────────
              Positioned(
                top: 12,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      phrase.arabic,
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: phrase.color,
                        shadows: _kShadow,
                      ),
                    ),
                    Text(
                      phrase.latin,
                      style: TextStyle(
                        fontSize: 8,
                        color: phrase.color.withOpacity(0.7),
                        letterSpacing: 0.3,
                        shadows: _kShadow,
                      ),
                    ),
                  ],
                ),
              ),

              // ── CAPTION BLOCK — bottom frosted ────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.78),
                        ],
                      ),
                    ),
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Title
                      Text(
                        post.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isCenter ? 22 : 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                          shadows: _kShadow,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Content snippet
                      Text(
                        post.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.45,
                          shadows: _kShadow,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Footer — author + actions
                      Row(
                        children: [

                          // Avatar
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.2),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                post.author.isNotEmpty
                                    ? post.author[0]
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Name + time
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: _kShadow,
                                  ),
                                ),
                                Text(
                                  post.time,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color:
                                        Colors.white.withOpacity(0.5),
                                    shadows: _kShadow,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          _ActionBtn(
                            icon: Icons.favorite_border_rounded,
                            label: _fmt(post.likes),
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 14),
                          _ActionBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: _fmt(post.likes ~/ 8),
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 14),
                          _ActionBtn(
                            icon: Icons.share_rounded,
                            label: '',
                            color: Colors.white.withOpacity(0.7),
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
    );
  }

  Widget _gradientBg(Color accent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            accent.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ── ACTION BUTTON ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color,
            shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 8)]),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              shadows: const [
                Shadow(color: Color(0xCC000000), blurRadius: 6)
              ],
            ),
          ),
      ],
    );
  }
}
