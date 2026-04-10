// lib/widgets/feed_card.dart

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
      case 'video':  return const Color(0xFFE53935);
      case 'quote':  return const Color(0xFF8E24AA);
      case 'event':  return const Color(0xFF43A047);
      default:       return kPrimaryGold;
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

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        // margin vertical = 0, horizontal sahaja
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _typeColor.withOpacity(widget.isCenter ? 0.1 : 0.03),
              blurRadius: widget.isCenter ? 16 : 6,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.13),
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.04),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.20), width: 1),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.03), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ─── KIRI: KONTEN ────────────────────────
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // ISLAMIC PHRASE BADGE
                          Row(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: phrase.bg,
                                ),
                                child: Center(
                                  child: Text(
                                    phrase.symbol,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: phrase.color,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    phrase.arabic,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: phrase.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    phrase.latin,
                                    style: TextStyle(
                                      fontSize: 6.5,
                                      color: phrase.color.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // TAJUK — center tunjuk 2 baris, lain 1 baris
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              color: kPrimaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair',
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: widget.isCenter ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // KANDUNGAN — dinamik: center card tunjuk lebih baris
                          Text(
                            widget.post.content,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: widget.isCenter ? 9.0 : 8.5,
                              height: 1.3,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: widget.isCenter ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // FOOTER ROW: author + [FIX 3] SEE MORE
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: _typeColor.withOpacity(0.2),
                                child: Icon(_typeIcon, color: _typeColor, size: 6),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.post.author} • ${widget.post.time}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // [FIX 3] BUTANG SEE MORE — hanya center card
                              if (widget.isCenter)
                                GestureDetector(
                                  onTap: () {
                                    // TODO: buka PostDetailPage
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: kPrimaryGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kPrimaryGold.withOpacity(0.4),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Text(
                                      'Lihat Lebih',
                                      style: TextStyle(
                                        color: kPrimaryGold,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
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

                  // ─── TENGAH: GAMBAR ───────────────────────
                  if (hasImage) ...[
                    const SizedBox(width: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 62,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                widget.post.assetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: _typeColor.withOpacity(0.15),
                                  child: Icon(_typeIcon, color: _typeColor.withOpacity(0.4), size: 18),
                                ),
                              ),
                              if (widget.post.type == 'video')
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white54, width: 1),
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ─── KANAN: ACTION BUTTONS ────────────────
                  const SizedBox(width: 5),
                  Container(width: 0.5, color: Colors.white.withOpacity(0.07)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionBtn(
                          icon: _liked ? Icons.favorite : Icons.favorite_border,
                          label: _formatCount(widget.post.likes),
                          color: _liked ? kWarningRed : Colors.white.withOpacity(0.30),
                          onTap: () => setState(() => _liked = !_liked),
                        ),
                        _ActionBtn(
                          icon: Icons.chat_bubble_outline,
                          label: _formatCount((widget.post.likes / 12).floor()),
                          color: Colors.white.withOpacity(0.30),
                        ),
                        _ActionBtn(
                          icon: Icons.share_outlined,
                          label: 'Kongsi',
                          color: Colors.white.withOpacity(0.30),
                        ),
                      ],
                    ),
                  ),
                ],
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
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 7, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
