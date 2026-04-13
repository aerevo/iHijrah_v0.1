// lib/widgets/feed_card.dart
// Redesign: layout vertikal, action buttons bawah center card
// Non-center: minimal — phrase + tajuk + meta sahaja

import 'package:flutter/material.dart';
import '../models/user_model.dart';

// ── FRASA ISLAMIK ──────────────────────────────────────────────
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

// ── WARNA ──────────────────────────────────────────────────────
const Color _cardBg       = Color(0xFFFAF7F0);
const Color _cardBgDim    = Color(0xFFF4F0E8);
const Color _textTitle    = Color(0xFF1A1208);
const Color _textBody     = Color(0xFF4A3F2F);
const Color _textMeta     = Color(0xFF9E8E6E);
const Color _gold         = Color(0xFFC9A84C);
const Color _goldDeep     = Color(0xFFA07820);
const Color _borderDim    = Color(0xFFDED5C0);
const Color _divider      = Color(0xFFEAE2D0);

// ── FEED CARD ──────────────────────────────────────────────────
class FeedCard extends StatefulWidget {
  final PostModel post;
  final bool isCenter;

  const FeedCard({
    Key? key,
    required this.post,
    this.isCenter = false,
  }) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _liked = false;

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':   return const Color(0xFFC62828);
      case 'quote':   return const Color(0xFF6A1B9A);
      case 'event':   return const Color(0xFF2E7D32);
      default:        return const Color(0xFFA07820);
    }
  }

  IconData get _typeIcon {
    switch (widget.post.type) {
      case 'video':   return Icons.play_circle_outline_rounded;
      case 'quote':   return Icons.format_quote_rounded;
      case 'event':   return Icons.calendar_month_outlined;
      default:        return Icons.article_outlined;
    }
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCenter ? _buildCenter() : _buildDim();
  }

  // ── KAD CENTER (penuh) ─────────────────────────────────────
  Widget _buildCenter() {
    final phrase   = _phrase;
    final hasImage = (widget.post.assetPath ?? '').isNotEmpty;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── GAMBAR (jika ada) ──────────────────────
              if (hasImage)
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.post.assetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _typeColor.withOpacity(0.08),
                          child: Icon(_typeIcon,
                              color: _typeColor.withOpacity(0.3), size: 40),
                        ),
                      ),
                      // Gradient fade ke bawah
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.55, 1.0],
                              colors: [
                                Colors.transparent,
                                _cardBg,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Play button untuk video
                      if (widget.post.type == 'video')
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.42),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70, width: 1.2),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ),
                    ],
                  ),
                ),

              // ── KONTEN ────────────────────────────────
              Expanded(
                flex: hasImage ? 4 : 6,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, hasImage ? 4 : 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // PHRASE BADGE
                      _PhraseBadge(phrase: phrase),
                      const SizedBox(height: 10),

                      // TAJUK
                      Text(
                        widget.post.title,
                        style: const TextStyle(
                          color: _textTitle,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // KANDUNGAN
                      Expanded(
                        child: Text(
                          widget.post.content,
                          style: const TextStyle(
                            color: _textBody,
                            fontSize: 12.5,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // META: author + type icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(_typeIcon, color: _typeColor, size: 12),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              '${widget.post.author}  •  ${widget.post.time}',
                              style: const TextStyle(
                                color: _textMeta,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── DIVIDER ───────────────────────────────
              Container(height: 0.7, color: _divider),

              // ── ACTION ROW (bawah, horizontal) ────────
              _ActionRow(
                liked: _liked,
                likes: widget.post.likes,
                onLike: () => setState(() => _liked = !_liked),
                fmt: _fmt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── KAD BUKAN CENTER (minimal) ─────────────────────────────
  Widget _buildDim() {
    final phrase = _phrase;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _cardBgDim,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderDim, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Phrase badge kecil
            _PhraseBadge(phrase: phrase, compact: true),
            const SizedBox(height: 8),

            // Tajuk
            Text(
              widget.post.title,
              style: TextStyle(
                color: _textTitle.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Meta
            Text(
              '${widget.post.author}  •  ${widget.post.time}',
              style: TextStyle(
                color: _textMeta.withOpacity(0.8),
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PHRASE BADGE ───────────────────────────────────────────────
class _PhraseBadge extends StatelessWidget {
  final IslamicPhrase phrase;
  final bool compact;
  const _PhraseBadge({required this.phrase, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 20 : 24,
          height: compact ? 20 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: phrase.bg,
            border: Border.all(
              color: phrase.color.withOpacity(0.22),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              phrase.symbol,
              style: TextStyle(
                fontSize: compact ? 9 : 11,
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
                fontSize: compact ? 8.5 : 9.5,
                color: phrase.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              phrase.latin,
              style: TextStyle(
                fontSize: compact ? 7 : 8,
                color: phrase.color.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── ACTION ROW ─────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final bool liked;
  final int likes;
  final VoidCallback onLike;
  final String Function(int) fmt;

  const _ActionRow({
    required this.liked,
    required this.likes,
    required this.onLike,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Btn(
            icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: fmt(likes),
            color: liked ? const Color(0xFFD32F2F) : _textMeta,
            onTap: onLike,
          ),
          _dividerV(),
          _Btn(
            icon: Icons.chat_bubble_outline_rounded,
            label: fmt((likes / 12).floor()),
            color: _textMeta,
          ),
          _dividerV(),
          _Btn(
            icon: Icons.share_outlined,
            label: 'Kongsi',
            color: _textMeta,
          ),
        ],
      ),
    );
  }

  Widget _dividerV() => Container(
        width: 0.7,
        height: 28,
        color: _divider,
      );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _Btn({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
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
