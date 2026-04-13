// lib/widgets/feed_card.dart
// TEMA CERAH — warm ivory + gold accent, zero blur, RepaintBoundary

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
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽', color: Color(0xFFA07820), bg: Color(0x22C9A84C)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: '☘', color: Color(0xFF2E7D32), bg: Color(0x2243A047)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: '✦', color: Color(0xFF1565C0), bg: Color(0x221E88E5)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: '◈', color: Color(0xFF6A1B9A), bg: Color(0x228E24AA)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  symbol: '☪', color: Color(0xFFC62828), bg: Color(0x22E53935)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   symbol: '❋', color: Color(0xFF00695C), bg: Color(0x2200897B)),
];

// ── WARNA TEMA CERAH ──────────────────────────────────────────
const Color _cardBg       = Color(0xFFFAF7F0); // ivory hangat
const Color _cardBgDim    = Color(0xFFF2EEE6); // kad bukan center
const Color _textTitle    = Color(0xFF1A1208); // hampir hitam
const Color _textBody     = Color(0xFF4A3F2F); // coklat gelap
const Color _textMeta     = Color(0xFF9E8E6E); // coklat pudar
const Color _borderCenter = Color(0xFFC9A84C); // gold
const Color _borderDim    = Color(0xFFDED5C0); // krim border
const Color _divider      = Color(0xFFE8E0CC);

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
      case 'video':  return const Color(0xFFC62828);
      case 'quote':  return const Color(0xFF6A1B9A);
      case 'event':  return const Color(0xFF2E7D32);
      default:       return const Color(0xFFA07820);
    }
  }

  IconData get _typeIcon {
    switch (widget.post.type) {
      case 'video':  return Icons.play_arrow;
      case 'quote':  return Icons.format_quote;
      case 'event':  return Icons.calendar_month;
      default:       return Icons.article;
    }
  }

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.post.assetPath != null &&
        widget.post.assetPath!.isNotEmpty;
    final phrase = _phrase;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.isCenter ? _cardBg : _cardBgDim,
            border: Border.all(
              color: widget.isCenter ? _borderCenter : _borderDim,
              width: widget.isCenter ? 1.5 : 0.8,
            ),
            boxShadow: widget.isCenter
                ? [
                    BoxShadow(
                      color: const Color(0xFFC9A84C).withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
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
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: widget.isCenter
                          ? [_typeColor, _typeColor.withOpacity(0.45)]
                          : [_typeColor.withOpacity(0.35), _typeColor.withOpacity(0.12)],
                    ),
                  ),
                ),

                // ─── KONTEN UTAMA ─────────────────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // ISLAMIC PHRASE BADGE
                        Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phrase.bg,
                                border: Border.all(
                                  color: phrase.color.withOpacity(0.25),
                                  width: 0.8,
                                ),
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
                            const SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  phrase.arabic,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: phrase.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  phrase.latin,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: phrase.color.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
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
                            color: _textTitle,
                            fontSize: widget.isCenter ? 14 : 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                          maxLines: widget.isCenter ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // KANDUNGAN
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            color: widget.isCenter
                                ? _textBody
                                : _textBody.withOpacity(0.55),
                            fontSize: widget.isCenter ? 11 : 10,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: widget.isCenter ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // FOOTER: author + lihat
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 7,
                              backgroundColor: _typeColor.withOpacity(0.12),
                              child: Icon(_typeIcon, color: _typeColor, size: 8),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${widget.post.author} • ${widget.post.time}',
                                style: TextStyle(
                                  color: _textMeta,
                                  fontSize: 9.5,
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
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9A84C).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFC9A84C).withOpacity(0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Lihat',
                                    style: TextStyle(
                                      color: Color(0xFFA07820),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
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
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 70,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              widget.post.assetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: _typeColor.withOpacity(0.08),
                                child: Icon(_typeIcon,
                                    color: _typeColor.withOpacity(0.4),
                                    size: 22),
                              ),
                            ),
                            if (widget.post.type == 'video')
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white70, width: 1),
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
                Container(width: 0.6, color: _divider),
                const SizedBox(width: 3),

                // ─── ACTION BUTTONS ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionBtn(
                        icon: _liked ? Icons.favorite : Icons.favorite_border,
                        label: _formatCount(widget.post.likes),
                        color: _liked ? const Color(0xFFD32F2F) : _textMeta,
                        onTap: () => setState(() => _liked = !_liked),
                      ),
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline,
                        label: _formatCount((widget.post.likes / 12).floor()),
                        color: _textMeta,
                      ),
                      _ActionBtn(
                        icon: Icons.share_outlined,
                        label: 'Kongsi',
                        color: _textMeta,
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
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
