// lib/widgets/feed_card.dart (CLEAN VERSION: NO FONT ERROR)

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
  final String size;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.id, 
    required this.title,
    required this.subtitle,
    this.author = '',
    this.authorAge = '',
    this.time = '',
    this.type = 'article',
    this.likes = 0,
    this.assetPath,
    this.size = 'medium',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardHeight = _getCardHeight();
    final bool hasImage = assetPath != null && assetPath!.isNotEmpty;
    
    return Hero(
      tag: 'post_$id',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: cardHeight,
              child: Stack(
                children: [
                  if (hasImage)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage(assetPath!), fit: BoxFit.cover),
                      ),
                    )
                  else
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(height: cardHeight, color: Colors.black.withOpacity(0.3)),
                    ),

                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: hasImage 
                            ? [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)] 
                            : [Colors.white.withOpacity(0.05), Colors.black.withOpacity(0.5)],
                        stops: const [0.3, 1.0],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  if (type == 'video' && hasImage)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0, left: 0, right: 0,
                          bottom: 40, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor().withOpacity(0.9), 
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      type.toUpperCase(), 
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)
                                    ),
                                  ),
                                  Text(time, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                title,
                                maxLines: size == 'small' ? 4 : 3, 
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: size == 'small' ? 14 : 16,
                                  height: 1.2,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: const Offset(0, 1))],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (author.isNotEmpty) ...[
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: kPrimaryGold,
                                        child: const Icon(Icons.person, size: 10, color: Colors.black),
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            author,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                          if (authorAge.isNotEmpty)
                                            Text("$authorAge (H)", style: const TextStyle(color: kPrimaryGold, fontSize: 7)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.favorite, size: 10, color: kWarningRed),
                                  const SizedBox(width: 3),
                                  Text("$likes", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
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

  double _getCardHeight() {
    switch (size) {
      case 'small': return 180;
      case 'large': return 320;
      case 'medium': default: return 240;
    }
  }

  Color _getTypeColor() {
     switch (type) {
      case 'video': return const Color(0xFFC62828); 
      case 'quote': return const Color(0xFF6A1B9A); 
      case 'event': return const Color(0xFF2E7D32); 
      default: return Colors.blueGrey;
    }
  }
}
