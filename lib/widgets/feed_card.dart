// lib/widgets/feed_card.dart
// FIX: (1) badge bulat penuh (2) avatar rapat nama (3) buang gender (4) action btn dalam kad

import 'dart:ui';
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
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽', color: Color(0xFFFFC107), bg: Color(0x22FFC107)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: '﷽', color: Color(0xFF26D0A0), bg: Color(0x2226D0A0)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: '﷽', color: Color(0xFF40C4FF), bg: Color(0x2240C4FF)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: '﷽', color: Color(0xFFCE93D8), bg: Color(0x22CE93D8)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  symbol: '﷽', color: Color(0xFFFF7043), bg: Color(0x22FF7043)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   symbol: '﷽', color: Color(0xFF80DEEA), bg: Color(0x2280DEEA)),
];

// ── WARNA TEMA ────────────────────────────────────────────────
const Color _borderCenter = Color(0xFF40C4FF);
const Color _borderDim    = Color(0x30FFFFFF);
const Color _textTitle    = Color(0xFFF0F8FF);
const Color _textTitleDim = Color(0xFFB0C4DE);
const Color _textBody     = Color(0xFFCDD5E0);
const Color _textBodyDim  = Color(0xFF7A8FA6);
const Color _textMeta     = Color(0xFF6A85A0);
const Color _glowCyan     = Color(0xFF00B4D8);
const Color _glowAmber    = Color(0xFFFFC107);

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
      case 'video':  return const Color(0xFFFF7043);
      case 'quote':  return const Color(0xFFCE93D8);
      case 'event':  return const Color(0xFF26D0A0);
      default:       return const Color(0xFFFFC107);
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isCenter
                ? [
                    BoxShadow(
                      color: _glowCyan.withOpacity(0.22),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: _glowAmber.withOpacity(0.10),
                      blurRadius: 30,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 8,
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
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: widget.isCenter
                  ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.isCenter
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.06),
                            const Color(0xFF0D1B2A).withOpacity(0.40),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                  border: Border.all(
                    color: widget.isCenter
                        ? _borderCenter.withOpacity(0.55)
                        : _borderDim,
                    width: widget.isCenter ? 1.2 : 0.7,
                  ),
                ),
                // ── LAYOUT UTAMA: accent line + content + image ──
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ─── ACCENT LINE KIRI ─────────────────
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: widget.isCenter
                              ? [_typeColor, _typeColor.withOpacity(0.3)]
                              : [_typeColor.withOpacity(0.4), _typeColor.withOpacity(0.1)],
                        ),
                      ),
                    ),

                    // ─── KONTEN (phrase + title + body + footer) ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // [1] BADGE ISLAMIK — bulat cukup besar, symbol penuh
                            Row(
                              children: [
                                Container(
                                  width: 36,   // FIX (1): besarkan dari 24 → 36
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: phrase.bg,
                                    border: Border.all(
                                      color: phrase.color.withOpacity(0.30),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      phrase.symbol,
                                      style: TextStyle(
                                        // ﷽ satu char → 16px, Arab ringkas → 12px
                                        fontSize: phrase.symbol.length <= 2 ? 16 : 12,
                                        color: phrase.color,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                        color: phrase.color.withOpacity(0.60),
                                        fontWeight: FontWeight.w400,
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
                                color: widget.isCenter ? _textTitle : _textTitleDim,
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
                                color: widget.isCenter ? _textBody : _textBodyDim,
                                fontSize: widget.isCenter ? 11 : 10,
                                height: 1.4,
                                fontWeight: FontWeight.w300,
                              ),
                              maxLines: widget.isCenter ? 3 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // [2][3][4] FOOTER — avatar rapat nama, buang gender,
                            //            action btn dalam kad (bukan luar)
                            Row(
                              children: [

                                // [2] Avatar rapat sebelah nama
                                CircleAvatar(
                                  radius: 9,
                                  backgroundColor: _typeColor.withOpacity(0.18),
                                  child: Icon(_typeIcon, color: _typeColor, size: 10),
                                ),
                                const SizedBox(width: 5),

                                // Nama + masa — [3] tiada gender icon
                                Expanded(
                                  child: Text(
                                    // [3] buang authorAge / gender sepenuhnya
                                    '${widget.post.author} • ${widget.post.time}',
                                    style: const TextStyle(
                                      color: _textMeta,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // [4] Action buttons DALAM kad — inline horizontal
                                const SizedBox(width: 6),
                                _InlineActionBtn(
                                  icon: _liked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  label: _formatCount(widget.post.likes),
                                  color: _liked
                                      ? const Color(0xFFFF5252)
                                      : _textMeta,
                                  onTap: () => setState(() => _liked = !_liked),
                                ),
                                const SizedBox(width: 10),
                                _InlineActionBtn(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: _formatCount(
                                      (widget.post.likes / 12).floor()),
                                  color: _textMeta,
                                ),
                                const SizedBox(width: 10),
                                _InlineActionBtn(
                                  icon: Icons.share_rounded,
                                  label: 'Kongsi',
                                  color: _textMeta,
                                ),

                                // Butang Lihat — hanya center card
                                if (widget.isCenter) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: buka PostDetailPage
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _glowCyan.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _glowCyan.withOpacity(0.45),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'Lihat',
                                        style: TextStyle(
                                          color: _glowCyan.withOpacity(0.9),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
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

                    // ─── GAMBAR — lebih lebar sebab btn dah masuk dalam ──
                    if (hasImage) ...[
                      Padding(
                        padding: const EdgeInsets.all(7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            // [4] image lebar — ruang btn dah kosong di kanan
                            width: 90,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  widget.post.assetPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _typeColor.withOpacity(0.10),
                                    child: Icon(_typeIcon,
                                        color: _typeColor.withOpacity(0.4),
                                        size: 24),
                                  ),
                                ),
                                // Gradient bawah gambar
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  height: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.45),
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
                                            color: Colors.white60, width: 1),
                                      ),
                                      child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

// ── ACTION BUTTON INLINE (dalam footer row) ───────────────────
class _InlineActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _InlineActionBtn({
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
