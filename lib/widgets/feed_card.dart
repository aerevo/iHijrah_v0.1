// lib/widgets/feed_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FeedCard extends StatelessWidget {
  final PostModel post;
  final bool isActive;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    this.isActive = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = post.assetPath != null && post.assetPath!.isNotEmpty;
    final Color typeColor = _typeColor();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.4, // Kad kat atas/bawah jadi malap sikit (Realistik)
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? typeColor.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
            boxShadow: [
              if (isActive)
                BoxShadow(color: typeColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.05),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // ─── KIRI: TEKS & PROFIL ───
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Author
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: typeColor.withOpacity(0.2),
                                child: Icon(_typeIcon(), color: typeColor, size: 12),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${post.author} • ${post.time}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          // Tajuk & Kandungan
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(color: kPrimaryGold, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Playfair'),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.content,
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.3),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Footer (Likes & See More)
                          Row(
                            children: [
                              Icon(Icons.favorite, color: kWarningRed.withOpacity(0.8), size: 12),
                              const SizedBox(width: 4),
                              Text("${post.likes}", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              const Text("BACA LANJUT", style: TextStyle(color: kPrimaryGold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const Icon(Icons.chevron_right, color: kPrimaryGold, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ─── KANAN: GAMBAR / VIDEO ───
                    if (hasImage) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3, // Kiri lebih besar (6), kanan lebih kecil (3)
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(post.assetPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: post.type == 'video'
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                  ),
                                )
                              : null,
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

  // ─── HELPERS ───
  Color _typeColor() {
    switch (post.type) {
      case 'video': return const Color(0xFFE53935);
      case 'quote': return const Color(0xFF8E24AA);
      case 'event': return const Color(0xFF43A047);
      default: return kPrimaryGold;
    }
  }

  IconData _typeIcon() {
    switch (post.type) {
      case 'video': return Icons.play_arrow;
      case 'quote': return Icons.format_quote;
      case 'event': return Icons.calendar_month;
      default: return Icons.article;
    }
  }
}
