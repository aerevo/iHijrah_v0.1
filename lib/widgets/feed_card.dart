// lib/widgets/feed_card.dart
// HIERARKI BETUL: Tajuk atas → Badge+Author → Content → Footer
// Tema cerah sesuai dengan latar putih/kelabu/biru muda

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

// ── WARNA TEMA CERAH ──────────────────────────────────────────
// Floating mode — no card background
const Color _titleCenter  = Color(0xFFFFFFFF);
const Color _titleDim     = Color(0xFFE2E8F0);
const Color _bodyCenter   = Color(0xFFE2E8F0);
const Color _bodyDim      = Color(0xFFCBD5E1);
const Color _metaColor    = Color(0xFF94A3B8);


// Text shadow untuk keterbacaan atas latar apapun
const List<Shadow> kTextShadow = [
  Shadow(color: Color(0xB3000000), blurRadius: 4, offset: Offset(0, 1)),
];

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
  bool _bookmarked = false;

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.title.hashCode.abs() % kIslamicPhrases.length];

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':  return const Color(0xFFDC2626);
      case 'quote':  return const Color(0xFF7C3AED);
      case 'event':  return const Color(0xFF059669);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(widget.isCenter ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _typeColor.withOpacity(widget.isCenter ? 0.22 : 0.08),
                width: 0.8,
              ),
              boxShadow: widget.isCenter
                  ? [
                      BoxShadow(
                        color: _typeColor.withOpacity(0.12),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

// ─── KONTEN UTAMA ──────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // ══ [1] TAJUK ══
                        Text(
                          widget.post.title,
                          style: GoogleFonts.amiri(
                            color: widget.isCenter ? _titleCenter : _titleDim,
                            fontSize: widget.isCenter ? 17 : 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            height: 1.25,
                            shadows: kTextShadow,
                          ),
                          maxLines: widget.isCenter ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // ══ [2] BADGE + AUTHOR ══
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ﷽ bulatan
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phrase.bg,
                                border: Border.all(
                                  color: phrase.color.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '﷽',
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: phrase.color,
                                    height: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Frasa arab + author
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    phrase.arabic,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: phrase.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    phrase.latin,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      color: phrase.color.withOpacity(0.55),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 7,
                                        backgroundColor:
                                            _typeColor.withOpacity(0.12),
                                        child: Icon(_typeIcon,
                                            color: _typeColor, size: 8),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${widget.post.author} • ${widget.post.time}',
                                          style: const TextStyle(
                                            color: _metaColor,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ══ [3] KANDUNGAN ══
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            color: widget.isCenter ? _bodyCenter : _bodyDim,
                            fontSize: widget.isCenter ? 11.5 : 10.5,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                            shadows: kTextShadow,
                          ),
                          maxLines: widget.isCenter ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // ══ [4] FOOTER ══
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _typeColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _typeColor.withOpacity(0.25),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_typeIcon,
                                      size: 9,
                                      color: _typeColor.withOpacity(0.8)),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.post.type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: _typeColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _bookmarked = !_bookmarked),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _bookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 16,
                                  color: _bookmarked
                                      ? kPrimaryGold
                                      : Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── THUMBNAIL — float dalam kad, ada ruang sekeliling ─
                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              widget.post.assetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  color: _typeColor.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_typeIcon,
                                    color: _typeColor.withOpacity(0.35),
                                    size: 22),
                              ),
                            ),
                            // Subtle gradient overlay bawah image
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (widget.post.type == 'video')
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.50),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white60, width: 0.8),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                          ],
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

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
