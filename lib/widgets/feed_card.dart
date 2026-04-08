// lib/widgets/feed_card.dart (FB STYLE - GLASS EDITION)

import 'dart:ui'; 
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FeedCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String author;
  final String authorAge;
  final String time;
  final String type;
  final int likes;
  final String? assetPath; 
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.id, 
    required this.title,
    required this.subtitle,
    this.author = 'Hamba Allah',
    this.authorAge = '',
    this.time = 'Baru tadi',
    this.type = 'article',
    this.likes = 0,
    this.assetPath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = assetPath != null && assetPath!.isNotEmpty;
    
    return Hero(
      tag: 'post_$id',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER: Author Info (FB Style)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _getTypeColor().withOpacity(0.2),
                          child: Icon(_getIcon(), color: _getTypeColor(), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                            Text(
                              "$time • $authorAge", 
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.3)),
                      ],
                    ),
                    
                    const SizedBox(height: 15),

                    // BODY: Gambar (Jika ada)
                    if (hasImage)
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage(assetPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // BODY: Tajuk & Kandungan
                    Text(
                      title,
                      style: const TextStyle(
                        color: kPrimaryGold, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        fontFamily: 'Playfair'
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), 
                          fontSize: 13, 
                          height: 1.4
                        ),
                        maxLines: hasImage ? 2 : 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Divider(color: Colors.white10, height: 20),

                    // FOOTER: Interaction
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.redAccent.withOpacity(0.8), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "$likes", 
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)
                        ),
                        const Spacer(),
                        const Text(
                          "BACA LANJUT", 
                          style: TextStyle(color: kPrimaryGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, color: kPrimaryGold, size: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case 'video': return const Color(0xFFC62828); 
      case 'quote': return const Color(0xFF6A1B9A); 
      case 'event': return const Color(0xFF2E7D32); 
      default: return kPrimaryGold;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case 'video': return Icons.play_circle_fill;
      case 'quote': return Icons.format_quote;
      case 'event': return Icons.event_available;
      default: return Icons.article;
    }
  }
}
