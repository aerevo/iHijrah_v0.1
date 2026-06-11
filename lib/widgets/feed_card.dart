// lib/widgets/feed_card.dart
// Gaya screenshot — gambar atas, info bawah, rounded besar

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── FRASA ISLAMIK ─────────────────────────────────────────────
const List<_Phrase> _phrases = [
  _Phrase('بِسْمِ اللَّهِ',     'Bismillah',     kPrimaryGold,            Color(0x22C9A84C)),
  _Phrase('الْحَمْدُ لِلَّهِ',  'Alhamdulillah', Color(0xFF22C55E),       Color(0x2222C55E)),
  _Phrase('سُبْحَانَ اللَّهِ',  'Subhanallah',   Color(0xFF38BDF8),       Color(0x2238BDF8)),
  _Phrase('إِنْ شَاءَ اللَّهُ','InsyaAllah',    Color(0xFFA78BFA),       Color(0x22A78BFA)),
  _Phrase('اللَّهُ أَكْبَرُ',  'Allahuakbar',  Color(0xFFEF4444),       Color(0x22EF4444)),
  _Phrase('مَا شَاءَ اللَّهُ', 'MashaAllah',   Color(0xFF0EA5E9),       Color(0x220EA5E9)),
];

class _Phrase {
  final String arabic, latin;
  final Color  color, bg;
  const _Phrase(this.arabic, this.latin, this.color, this.bg);
}

// ── TYPE ──────────────────────────────────────────────────────
Color _typeColor(String t) {
  switch (t) {
    case 'video':   return kTypeVideo;
    case 'article': return kTypeArticle;
    case 'event':   return kTypeEvent;
    case 'quote':   return kTypeQuote;
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

// ── GRADIENT PALETTES ─────────────────────────────────────────
const List<List<Color>> _palettes = [
  [Color(0xFF0A0E1A), Color(0xFF1B3060)],
  [Color(0xFF1A0800), Color(0xFF4A1800)],
  [Color(0xFF001A0A), Color(0xFF005028)],
  [Color(0xFF100018), Color(0xFF3A0868)],
  [Color(0xFF001520), Color(0xFF00456A)],
  [Color(0xFF1A0010), Color(0xFF5A0038)],
];

// ── FEED CARD ─────────────────────────────────────────────────
class FeedCard extends StatefulWidget {
  final PostModel post;
  final bool isCenter;

  const FeedCard({Key? key, required this.post, required this.isCenter})
      : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _liked = false;

  String _fmt(int n) =>
      n >= 1000 ? '\${(n / 1000).toStringAsFixed(1)}k' : '\$n';

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
    final Color  accent  = _typeColor(widget.post.type);
    final int    pi      = widget.post.id.hashCode.abs() % _palettes.length;
    final int    phi     = widget.post.id.hashCode.abs() % _phrases.length;
    final _Phrase phrase = _phrases[phi];
    final bool   hasImg  = widget.post.assetPath != null &&
        widget.post.assetPath!.isNotEmpty;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: kCardDark,
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [

            // ── BAHAGIAN ATAS — Gambar (55%) ───────────────
            Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  // Gambar atau gradient
                  hasImg
                      ? Image.asset(
                          widget.post.assetPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _gradBg(_palettes[pi]),
                        )
                      : _gradBg(_palettes[pi]),

                  // Gradient fade bawah
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kCardDark.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Frasa Islamik — kanan atas
                  Positioned(
                    top: 14, right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          phrase.arabic,
                          style: GoogleFonts.amiri(
                            fontSize: 17,
                            color: phrase.color,
                            shadows: kTextShadow,
                          ),
                        ),
                        Text(
                          phrase.latin,
                          style: TextStyle(
                            fontSize: 8,
                            color: phrase.color.withOpacity(0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Type badge — kiri atas
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: accent.withOpacity(0.45), width: 0.8),
                      ),
                      child: Text(
                        _typeLabel(widget.post.type),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── GARIS PEMISAH ──────────────────────────────
            Container(
              height: 0.5,
              color: kBorderSubtle,
            ),

            // ── BAHAGIAN BAWAH — Info (45%) ────────────────
            Expanded(
              flex: 45,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: kCardDark,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Tajuk
                    Text(
                      widget.post.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: widget.isCenter ? 18 : 15,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Kandungan ringkas
                    Text(
                      widget.post.content,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: kTextSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // ── FOOTER ─────────────────────────────
                    Row(
                      children: [

                        // Avatar
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.15),
                            border: Border.all(
                                color: accent.withOpacity(0.4),
                                width: 1.2),
                          ),
                          child: Center(
                            child: Text(
                              widget.post.author.isNotEmpty
                                  ? widget.post.author[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.author,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.post.time,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Like
                        _ActionBtn(
                          icon: _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: _fmt(widget.post.likes + (_liked ? 1 : 0)),
                          color: _liked ? kWarningRed : kTextSecondary,
                          onTap: () => setState(() => _liked = !_liked),
                        ),
                        const SizedBox(width: 14),
                        // Comment
                        _ActionBtn(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: _fmt(widget.post.likes ~/ 8),
                          color: kTextSecondary,
                        ),
                        const SizedBox(width: 14),
                        // Share
                        _ActionBtn(
                          icon: Icons.share_rounded,
                          label: '',
                          color: kTextSecondary,
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
}

// ── ACTION BUTTON ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    ),
  );
}
