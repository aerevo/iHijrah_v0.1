// lib/widgets/feed_card.dart
// ═══════════════════════════════════════════════════════════════
// KOD LENGKAP: TEKS KIRI | GAMBAR TENGAH | BUTANG MENEGAK KANAN
// EFEK BARU: CYLINDRICAL GRADIENT (Bagi kad nampak melengkung macam mesin slot)
// ═══════════════════════════════════════════════════════════════

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
  const IslamicPhrase({required this.arabic, required this.latin, required this.symbol, required this.color, required this.bg});
}

const List<IslamicPhrase> kIslamicPhrases = [
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽', color: Color(0xFFC9A84C), bg: Color(0x22C9A84C)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: '☘', color: Color(0xFF43A047), bg: Color(0x2243A047)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: '✦', color: Color(0xFF1E88E5), bg: Color(0x221E88E5)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: '◈', color: Color(0xFF8E24AA), bg: Color(0x228E24AA)),
];

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

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.post.assetPath != null && widget.post.assetPath!.isNotEmpty;
    final Color typeColor = _typeColor();
    final phrase = kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Margin rapat sikit
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(widget.isCenter ? 0.15 : 0.05),
              blurRadius: widget.isCenter ? 24 : 10,
              offset: Offset(0, widget.isCenter ? 8 : 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ────────────────────────────────────────────────────────────────
                // MAGIS CYLINDER: Gradient Gelap Atas -> Terang Tengah -> Gelap Bawah
                // Ini menipu mata supaya nampak macam kad ni melengkung (bukan flat)
                // ────────────────────────────────────────────────────────────────
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),         // Atas melengkung ke dalam (gelap)
                    Colors.white.withOpacity(0.08),         // Tengah cembung ke depan (terang)
                    Colors.black.withOpacity(0.35),         // Bawah melengkung ke dalam (gelap)
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1), 
                  bottom: BorderSide(color: Colors.white.withOpacity(0.02), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── 1. KIRI: TEKS & PROFIL ───
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: phrase.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: phrase.color.withOpacity(0.3), width: 0.5),
                          ),
                          child: Text(
                            "${phrase.symbol} ${phrase.latin}", 
                            style: TextStyle(color: phrase.color, fontSize: 8, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.post.title,
                          style: const TextStyle(color: kPrimaryGold, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Playfair', letterSpacing: -0.3),
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            widget.post.content,
                            style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.3, fontWeight: FontWeight.w300),
                            maxLines: hasImage ? 2 : 3, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: typeColor.withOpacity(0.2),
                              child: Icon(_typeIcon(), color: typeColor, size: 8),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${widget.post.author} • ${widget.post.time}",
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w500),
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── 2. TENGAH: GAMBAR / VIDEO ───
                  if (hasImage) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(widget.post.assetPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: widget.post.type == 'video'
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white54, width: 1.5),
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],

                  // ─── 3. KANAN: BUTANG MENEGAK ───
                  const SizedBox(width: 10),
                  Container(width: 1, color: Colors.white.withOpacity(0.08)), 
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ActionBtn(
                        icon: _liked ? Icons.favorite : Icons.favorite_border,
                        label: '${widget.post.likes}',
                        color: _liked ? kWarningRed : Colors.white.withOpacity(0.35),
                        onTap: () => setState(() => _liked = !_liked),
                      ),
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline, 
                        label: '${(widget.post.likes / 12).floor()}', 
                        color: Colors.white.withOpacity(0.35)
                      ),
                      _ActionBtn(
                        icon: Icons.share_outlined, 
                        label: 'Kongsi', 
                        color: Colors.white.withOpacity(0.35)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor() {
    switch (widget.post.type) {
      case 'video':   return const Color(0xFFE53935);
      case 'quote':   return const Color(0xFF8E24AA);
      case 'event':   return const Color(0xFF43A047);
      default:        return kPrimaryGold;
    }
  }

  IconData _typeIcon() {
    switch (widget.post.type) {
      case 'video':   return Icons.play_arrow;
      case 'quote':   return Icons.format_quote;
      case 'event':   return Icons.calendar_month;
      default:        return Icons.article;
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
