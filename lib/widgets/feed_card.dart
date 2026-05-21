// lib/widgets/feed_card.dart
// HIERARKI BETUL: Tajuk atas → Badge+Author → Content → Footer
// Tema cerah sesuai dengan latar putih/kelabu/biru muda

import 'dart:ui';
import 'package:flutter/material.dart';
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
const Color _cardCenter   = Color(0xFFFFFFFF);       // putih bersih
const Color _cardDim      = Color(0xFFF0F4F8);       // putih kebiruan
const Color _borderCenter = Color(0xFF93C5FD);       // biru muda
const Color _borderDim    = Color(0xFFCDD9E8);       // kelabu biru
const Color _titleCenter  = Color(0xFF0F172A);       // hampir hitam
const Color _titleDim     = Color(0xFF334155);       // slate gelap
const Color _bodyCenter   = Color(0xFF475569);       // slate
const Color _bodyDim      = Color(0xFF94A3B8);       // slate pudar
const Color _metaColor    = Color(0xFF94A3B8);       // kelabu
const Color _glowBlue     = Color(0xFF3B82F6);       // biru fokus

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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.isCenter ? _cardCenter : _cardDim,
            border: Border.all(
              color: widget.isCenter
                  ? _borderCenter
                  : _borderDim,
              width: widget.isCenter ? 1.5 : 0.8,
            ),
            boxShadow: widget.isCenter
                ? [
                    BoxShadow(
                      color: _glowBlue.withOpacity(0.14),
                      blurRadius: 18,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ─── ACCENT LINE KIRI ─────────────────────
                Container(
                  width: 3.5,
                  color: widget.isCenter
                      ? _typeColor
                      : Color.fromARGB(102, _typeColor.red, _typeColor.green, _typeColor.blue),
                ),

                // ─── KONTEN UTAMA ──────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // ══ [1] TAJUK — paling atas, paling besar ══
                        Text(
                          widget.post.title,
                          style: TextStyle(
                            color: widget.isCenter ? _titleCenter : _titleDim,
                            fontSize: widget.isCenter ? 15 : 13,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.normal,
                            letterSpacing: -0.4,
                            height: 1.2,
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
                          ),
                          maxLines: widget.isCenter ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // ══ [4] FOOTER — action buttons ══
                        Row(
                          children: [
                            _ActionBtn(
                              icon: _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              label: _fmt(widget.post.likes),
                              color: _liked
                                  ? const Color(0xFFEF4444)
                                  : _metaColor,
                              onTap: () =>
                                  setState(() => _liked = !_liked),
                            ),
                            const SizedBox(width: 14),
                            _ActionBtn(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: _fmt((widget.post.likes / 12).floor()),
                              color: _metaColor,
                            ),
                            const SizedBox(width: 14),
                            _ActionBtn(
                              icon: Icons.share_rounded,
                              label: 'Kongsi',
                              color: _metaColor,
                            ),
                            if (widget.isCenter) ...[
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  // TODO: PostDetailPage
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _glowBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: _glowBlue.withOpacity(0.35),
                                      width: 0.9,
                                    ),
                                  ),
                                  child: Text(
                                    'Lihat',
                                    style: TextStyle(
                                      color: _glowBlue.withOpacity(0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
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

                // ─── THUMBNAIL — flush tepi kanan ─────────
                if (hasImage)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: SizedBox(
                      width: 88,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.post.assetPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _typeColor.withOpacity(0.08),
                              child: Icon(_typeIcon,
                                  color: _typeColor.withOpacity(0.35),
                                  size: 24),
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
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                        ],
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 3),
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
