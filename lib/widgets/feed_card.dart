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
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _typeColor.withOpacity(widget.isCenter ? 0.12 : 0.04),
              blurRadius: widget.isCenter ? 20 : 8,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
              decoration: BoxDecoration(
                // [FIX 3] Jernihkan kad — kurangkan opacity gelap
                // Dulu: black 0.35 atas/bawah → sekarang 0.08 sahaja
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.13),  // atas — cahaya masuk
                    Colors.white.withOpacity(0.07),  // tengah
                    Colors.white.withOpacity(0.04),  // bawah
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                // Top highlight — simulate glass rim light
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.22), width: 1),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── KIRI: KONTEN ────────────────────────
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // [FIX 5] ISLAMIC PHRASE BADGE — pulihkan logo bulat + arabic
                          Row(
                            children: [
                              // Simbol bulat berwarna
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
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontSize: 7,
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
                            style: const TextStyle(
                              color: kPrimaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair',
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // KANDUNGAN
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                widget.post.content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 9,
                                  height: 1.35,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: hasImage ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // AUTHOR
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 7,
                                backgroundColor: _typeColor.withOpacity(0.22),
                                child: Icon(_typeIcon, color: _typeColor, size: 7),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${widget.post.author} • ${widget.post.time}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 8,
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
                  ),

                  // ─── TENGAH: GAMBAR ───────────────────────
                  if (hasImage) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 70,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                widget.post.assetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: _typeColor.withOpacity(0.15),
                                  child: Icon(_typeIcon, color: _typeColor.withOpacity(0.4), size: 20),
                                ),
                              ),
                              if (widget.post.type == 'video')
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white54, width: 1),
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ─── KANAN: ACTION BUTTONS ────────────────
                  const SizedBox(width: 6),
                  Container(width: 1, color: Colors.white.withOpacity(0.07)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionBtn(
                          icon: _liked ? Icons.favorite : Icons.favorite_border,
                          label: '${widget.post.likes}',
                          color: _liked
                              ? kWarningRed
                              : Colors.white.withOpacity(0.32),
                          onTap: () => setState(() => _liked = !_liked),
                        ),
                        _ActionBtn(
                          icon: Icons.chat_bubble_outline,
                          label: '${(widget.post.likes / 12).floor()}',
                          color: Colors.white.withOpacity(0.32),
                        ),
                        _ActionBtn(
                          icon: Icons.share_outlined,
                          label: 'Kongsi',
                          color: Colors.white.withOpacity(0.32),
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
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
