// lib/widgets/feed_panel.dart (BERSIH: HANYA FEED KOMUNITI)

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'post_detail_page.dart';

// Kita tak import HijrahTree, SirahCard, atau AmalanList di sini
// Sebab mereka dah pindah ke Sidebar

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  // DATA DUMMY (Kekal sebagai hiasan utama)
  final List<Map<String, dynamic>> posts = const [
    {
      'id': '101', 'type': 'video', 'title': 'Kisah Hijrah Rasulullah',
      'content': 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.', 
      'author': 'Ustaz Don',
      'authorAge': '40 thn', 'likes': 1240, 'time': '2j',
      'assetPath': 'assets/images/dummy_post1.jpg',
    },
    { 
      'id': 'spacer_1', 'type': 'spacer' 
    },
    {
      'id': '102', 'type': 'quote', 'title': 'Kata Hikmah',
      'content': 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)', 
      'author': 'Imam Syafi\'i',
      'authorAge': '', 'likes': 850, 'time': '5j', 'assetPath': '',
    },
     {
      'id': '103', 'type': 'article', 'title': 'Tips Murah Rezeki',
      'content': 'Amalkan Solat Dhuha dan sedekah subuh secara konsisten setiap hari.', 
      'author': 'Prof Muhaya',
      'authorAge': '60 thn', 'likes': 3000, 'time': '1h',
      'assetPath': 'assets/images/dummy_post2.jpg',
    },
    {
      'id': '104', 'type': 'video', 'title': 'Tadabbur Al-Mulk',
      'content': 'Kelebihan membaca surah Al-Mulk sebelum tidur.', 
      'author': 'Ustaz Wadi',
      'authorAge': '38 thn', 'likes': 5200, 'time': '3j',
      'assetPath': 'assets/images/dummy_post1.jpg', // Guna aset sama utk jimat
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER FEED
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.explore, color: kPrimaryGold, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "JELAJAH KOMUNITI", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5,
                        fontSize: 14,
                      )
                    ),
                  ],
                ),
                // Filter Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune, color: kTextSecondary, size: 18),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // MASONRY GRID (FEED UTAMA)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return FeedCard(
                  id: post['id'] ?? 'uniq_$index',
                  type: post['type'] ?? 'article',
                  title: post['title'] ?? '',
                  subtitle: post['content'] ?? '',
                  author: post['author'] ?? '',
                  authorAge: post['authorAge'] ?? '',
                  time: post['time'] ?? '',
                  likes: post['likes'] ?? 0,
                  assetPath: post['assetPath'],
                  onTap: () {
                    if (post['type'] == 'spacer') return;
                    Navigator.push(context, MaterialPageRoute(builder: (c) => PostDetailPage(post: post)));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
