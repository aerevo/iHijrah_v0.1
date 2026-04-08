// lib/widgets/feed_panel.dart (RODA CAROUSEL EDITION)

import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'post_detail_page.dart';

class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  // Data Dummy untuk testing (Format FB Style)
  final List<Map<String, dynamic>> posts = const [
    {
      'id': '101', 
      'type': 'video', 
      'title': 'Kisah Hijrah Rasulullah',
      'content': 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda Rasulullah SAW daripada kaum Musyrikin.', 
      'author': 'Ustaz Don',
      'authorAge': '40 thn', 'likes': 1240, 'time': '2j',
      'assetPath': 'assets/images/dummy_post1.jpg',
    },
    {
      'id': '102', 
      'type': 'quote', 
      'title': 'Mutiara Kata Imam Syafi\'i',
      'content': 'Jangan bersedih, sesungguhnya Allah bersama kita. Setiap kesulitan pasti ada kemudahan yang menyertainya.', 
      'author': 'Zyamina Studio',
      'authorAge': 'Admin', 'likes': 850, 'time': '5j',
      'assetPath': '', 
    },
    {
      'id': '103', 
      'type': 'article', 
      'title': 'Kelebihan Selawat Harian',
      'content': 'Barangsiapa yang berselawat ke atasku sekali, Allah akan berselawat ke atasnya sepuluh kali. Mari suburkan pokok kita.', 
      'author': 'Habib Ali',
      'authorAge': '52 thn', 'likes': 2100, 'time': '1h',
      'assetPath': 'assets/images/dummy_post2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(
            "FEED KOMUNITI",
            style: TextStyle(
              color: kPrimaryGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),

        // EFEK RODA (ListWheelScrollView / Carousel)
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 280, // Tinggi setiap kad
            perspective: 0.003, // Efek melengkung roda
            diameterRatio: 1.8, // Saiz roda
            physics: const FixedExtentScrollPhysics(), // Berhenti tepat pada kad (Snap)
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: posts.length,
              builder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildGlassCard(context, post),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // BINA KAD JERNIH (GLASS) - FB STYLE
  Widget _buildGlassCard(BuildContext context, Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PostDetailPage(post: post))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kad (Author)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kPrimaryGold.withOpacity(0.2),
                      child: const Icon(Icons.person, color: kPrimaryGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("${post['time']} lepas • ${post['authorAge']}", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, color: Colors.white38),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Tajuk & Isi
                Text(
                  post['title'],
                  style: const TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    post['content'],
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Footer (Likes)
                const Divider(color: Colors.white10),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 5),
                    Text("${post['likes']}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    const Spacer(),
                    const Text("Sentuh untuk baca lanjut", style: TextStyle(color: kPrimaryGold, fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
