// lib/widgets/post_detail_page.dart (UPGRADED: IMMERSIVE VIEW)

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String type = post['type'] ?? 'article';
    final String id = post['id'] ?? '0';

    return Scaffold(
      backgroundColor: Colors.black, // Pure Black Background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. APP BAR BOLEH EXPAND
          SliverAppBar(
            expandedHeight: 350, // Lebih tinggi untuk impak visual
            pinned: true,
            backgroundColor: kCardDark,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border, color: kPrimaryGold),
                    onPressed: () {
                      // Logic bookmark
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disimpan!"), duration: Duration(seconds: 1)));
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post_$id', // ID SAMA DENGAN CARD = SMOOTH ANIMATION
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         _getTypeColor(type),
                         Colors.black,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getIcon(type),
                      size: 100,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. KANDUNGAN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Row
                  Row(
                    children: [
                      _buildTag(type.toUpperCase(), kPrimaryGold),
                      const Spacer(),
                      Icon(Icons.access_time, size: 14, color: kTextSecondary),
                      const SizedBox(width: 4),
                      Text(post['time'] ?? '', style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Tajuk Besar
                  Text(
                    post['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontFamily: 'Playfair', // Font Premium
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Author
                  if (post['author'] != null && post['author'].isNotEmpty)
                  Row(
                    children: [
                      const Text("Oleh ", style: TextStyle(color: kTextSecondary, fontSize: 13)),
                      Text(post['author'], style: const TextStyle(color: kAccentOlive, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 30),

                  // Content Body
                  Text(
                    post['content'],
                    style: TextStyle(
                      color: kTextPrimary.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.8, // Jarak baris selesa dibaca
                    ),
                  ),

                  const SizedBox(height: 50),
                  
                  // Footer Action
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share, color: Colors.black),
                        label: const Text("KONGSI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'video': return const Color(0xFF1A237E);
      case 'quote': return const Color(0xFF4A148C);
      case 'event': return const Color(0xFF004D40);
      default: return const Color(0xFF37474F);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'video': return Icons.play_circle_fill;
      case 'quote': return Icons.format_quote;
      case 'event': return Icons.calendar_today;
      default: return Icons.article;
    }
  }
}
