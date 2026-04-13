// lib/widgets/feed_card.dart
// PERFORMANCE BUILD — zero BackdropFilter, RepaintBoundary, border accent

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── FRASA ISLAMIK ─────────────────────────────────────────────
class IslamicPhrase {
  final String arabic;
  final String latin;
  final String symbol;
  final Color color;
  final Color bg;
  const IslamicPhrase({
    required this.arabic,
    required this.latin,
    required this.symbol,
    required this.color,
    required this.bg,
  });
}

const List<IslamicPhrase> kIslamicPhrases = [
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽', color: Color(0xFFC9A84C), bg: Color(0x28C9A84C)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: '☘', color: Color(0xFF43A047), bg: Color(0x2843A047)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: '✦', color: Color(0xFF1E88E5), bg: Color(0x281E88E5)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: '◈', color: Color(0xFF8E24AA), bg: Color(0x288E24AA)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  symbol: '☪', color: Color(0xFFE53935), bg: Color(0x28E53935)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   symbol: '❋', color: Color(0xFF00897B), bg: Color(0x2800897B)),
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
  bool _liked = false;

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':   return const Color(0xFFE53935);
      case 'quote':   return const Color(0xFF8E24AA);
      case 'event':   return const Color(0xFF43A047);
      default:        return kPrimaryGold;
    }
  }

  IconData get _typeIcon {
    switch (widget.post.type) {
      case 'video':   return Icons.play_arrow;
      case 'quote':   return Icons.format_quote;
      case 'event':   return Icons.calendar_month;
      default:        return Icons.article;
    }
  }

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.post.assetPath != null &&
        widget.post.assetPath!.isNotEmpty;
    final phrase = _phrase;

    // RepaintBoundary — Flutter isolate repaint setiap kad,
    // scroll tak trigger repaint kad lain
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // SOLID — zero blur cost
            color: widget.isCenter
                ? const Color(0xFF1E1E1E)
                : const Color(0xFF171717),
            // BORDER — center dapat gold accent, lain subtle
            border: Border.all(
              color: widget.isCenter
                  ? kPrimaryGold.withOpacity(0.55)
                  : Colors.white.withOpacity(0.09),
              width: widget.isCenter ? 1.2 : 0.8,
            ),
            // Shadow ringan — cukup depth tanpa blur
            boxShadow: widget.isCenter
                ? [
                    BoxShadow(
                      color: kPrimaryGold.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ─── ACCENT LINE KIRI ────────────────────
                Container(
                  width: 3,
                  color: widget.isCenter
                      ? _typeColor
                      : _typeColor.withOpacity(0.35),
                ),

                // ─── KONTEN UTAMA ─────────────────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // ISLAMIC PHRASE BADGE
                        Row(
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phrase.bg,
                              ),
                              child: Center(
                                child: Text(
                                  phrase.symbol,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: phrase.color,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  phrase.arabic,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: phrase.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  phrase.latin,
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    color: phrase.color.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // TAJUK
                        Text(
                          widget.post.title,
                          style: TextStyle(
                            color: widget.isCenter
                                ? kPrimaryGold
                                : kPrimaryGold.withOpacity(0.85),
                            fontSize: widget.isCenter ? 13 : 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                            height: 1.2,
                          ),
                          maxLines: widget.isCenter ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // KANDUNGAN
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            color: Colors.white.withOpacity(
                                widget.isCenter ? 0.72 : 0.45),
                            fontSize: widget.isCenter ? 10.5 : 9.5,
                            height: 1.35,
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: widget.isCenter ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // FOOTER: author + lihat lebih
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 7,
                              backgroundColor: _typeColor.withOpacity(0.18),
                              child: Icon(_typeIcon,
                                  color: _typeColor, size: 7),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${widget.post.author} • ${widget.post.time}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isCenter)
                              GestureDetector(
                                onTap: () {
                                  // TODO: buka PostDetailPage
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: kPrimaryGold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: kPrimaryGold.withOpacity(0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Lihat',
                                    style: TextStyle(
                                      color: kPrimaryGold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── GAMBAR THUMBNAIL ─────────────────────
                if (hasImage) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 68,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              widget.post.assetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: _typeColor.withOpacity(0.12),
                                child: Icon(_typeIcon,
                                    color: _typeColor.withOpacity(0.4),
                                    size: 20),
                              ),
                            ),
                            if (widget.post.type == 'video')
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white54, width: 1),
                                  ),
                                  child: const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // ─── DIVIDER ──────────────────────────────
                const SizedBox(width: 5),
                Container(
                    width: 0.5,
                    color: Colors.white.withOpacity(0.06)),
                const SizedBox(width: 3),

                // ─── ACTION BUTTONS ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionBtn(
                        icon: _liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: _formatCount(widget.post.likes),
                        color: _liked
                            ? kWarningRed
                            : Colors.white.withOpacity(0.35),
                        onTap: () => setState(() => _liked = !_liked),
                      ),
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline,
                        label: _formatCount(
                            (widget.post.likes / 12).floor()),
                        color: Colors.white.withOpacity(0.35),
                      ),
                      _ActionBtn(
                        icon: Icons.share_outlined,
                        label: 'Kongsi',
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
