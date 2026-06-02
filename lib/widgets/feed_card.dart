// lib/widgets/feed_card.dart
// APPLE VISION PRO STYLE — Dark Glassmorphism Theme
// HIERARKI: Tajuk atas → Badge+Author → Content → Footer

import 'package:flutter/material.dart';
import 'dart:ui';
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
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     color: Color(0xFF60A5FA), bg: Color(0x3360A5FA)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', color: Color(0xFF34D399), bg: Color(0x3334D399)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   color: Color(0xFF60A5FA), bg: Color(0x3360A5FA)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    color: Color(0xFFA78BFA), bg: Color(0x33A78BFA)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  color: Color(0xFFF87171), bg: Color(0x33F87171)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   color: Color(0xFF22D3EE), bg: Color(0x3322D3EE)),
];

// ── WARNA TEMA GELAP (APPLE VISION PRO) ──────────────────────
const Color _cardBg        = Color(0xFF1E293B);      // slate-800
const Color _cardBgGlass   = Color(0x661E293B);      // semi-transparent
const Color _titleCenter   = Color(0xFFFFFFFF);
const Color _titleDim      = Color(0xFF94A3B8);
const Color _bodyCenter    = Color(0xFFE2E8F0);
const Color _bodyDim       = Color(0xFF64748B);
const Color _metaColor     = Color(0xFF94A3B8);
const Color _glowBlue      = Color(0xFF3B82F6);
const Color _borderColor   = Color(0x33FFFFFF);

// ── FEED CARD ─────────────────────────────────────────────────
class FeedCard extends StatefulWidget {
  final PostModel post;
  final bool isCenter;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    this.isCenter = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _liked = false;

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.title.hashCode.abs() % kIslamicPhrases.length];

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':  return const Color(0xFFEF4444);
      case 'quote':  return const Color(0xFFA78BFA);
      case 'event':  return const Color(0xFF34D399);
      default:       return const Color(0xFFF59E0B);
    }
  }

  IconData get _typeIcon {
    switch (widget.post.type) {
      case 'video':  return Icons.play_arrow_rounded;
      case 'quote':  return Icons.format_quote_rounded;
      case 'event':  return Icons.event_rounded;
      default:       return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.post.assetPath != null &&
        widget.post.assetPath!.isNotEmpty;
    final phrase = _phrase;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _cardBgGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (widget.isCenter)
                BoxShadow(
                  color: _glowBlue.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _cardBg.withOpacity(0.9),
                      _cardBg.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ══ [1] BADGE + TYPE + AUTHOR (Top Bar) ══
                      Row(
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _typeColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_typeIcon, size: 12, color: _typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  widget.post.type.toUpperCase(),
                                  style: TextStyle(
                                    color: _typeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Islamic phrase badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: phrase.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: phrase.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              phrase.latin,
                              style: TextStyle(
                                color: phrase.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ══ [2] TAJUK — besar & bold ══
                      Text(
                        widget.post.title,
                        style: TextStyle(
                          color: widget.isCenter ? _titleCenter : _titleDim,
                          fontSize: widget.isCenter ? 18 : 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        maxLines: widget.isCenter ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // ══ [3] AUTHOR + TIME ══
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _typeColor.withOpacity(0.2),
                            child: Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: _typeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.post.author} • ${widget.post.time}',
                              style: const TextStyle(
                                color: _metaColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ══ [4] CONTENT ══
                      Text(
                        widget.post.content,
                        style: TextStyle(
                          color: widget.isCenter ? _bodyCenter : _bodyDim,
                          fontSize: widget.isCenter ? 13 : 12,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: widget.isCenter ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // ══ [5] THUMBNAIL (if has image) ══
                      if (hasImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  widget.post.assetPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _typeColor.withOpacity(0.1),
                                    child: Icon(
                                      _typeIcon,
                                      color: _typeColor.withOpacity(0.5),
                                      size: 40,
                                    ),
                                  ),
                                ),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                // Play button for video
                                if (widget.post.type == 'video')
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: _cardBg,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ══ [6] ACTION BUTTONS ══
                      Row(
                        children: [
                          _ActionBtn(
                            icon: _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: _fmt(_liked ? widget.post.likes + 1 : widget.post.likes),
                            color: _liked
                                ? const Color(0xFFEF4444)
                                : _metaColor,
                            onTap: () => setState(() => _liked = !_liked),
                          ),
                          const SizedBox(width: 16),
                          _ActionBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: _fmt((widget.post.likes / 12).floor()),
                            color: _metaColor,
                          ),
                          const SizedBox(width: 16),
                          _ActionBtn(
                            icon: Icons.share_rounded,
                            label: 'Kongsi',
                            color: _metaColor,
                          ),
                          if (widget.isCenter) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_glowBlue, _glowBlue.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _glowBlue.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Lihat Penuh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
