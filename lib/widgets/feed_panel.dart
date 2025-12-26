// lib/widgets/feed_panel.dart (BRICK BOND LAYOUT: OFFSET STAGGER)

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'metallic_gold.dart';
import 'post_detail_page.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  // DATA DUMMY (BRICK PATTERN)
  // Kita letak 'spacer' di index 1 supaya column kanan jatuh sikit.
  final List<Map<String, dynamic>> posts = const [
    // ITEM 0 (COL KIRI - MULA DULU)
    {
      'id': '101',
      'type': 'video',
      'title': 'Kisah Hijrah Rasulullah',
      'content': 'Detik cemas di Gua Thur.',
      'author': 'Ustaz Don',
      'authorAge': '40 thn',
      'likes': 1240,
      'time': '2j',
      'assetPath': 'assets/images/dummy_post1.jpg',
    },
    // ITEM 1 (COL KANAN - SPACER HALIMUNAN - UTK EFEK BERSILANG)
    {
      'id': 'spacer_1',
      'type': 'spacer', // Ini akan jadi kotak kosong separuh tinggi
    },
    // ITEM 2 (COL KANAN - SAMBUNG BAWAH SPACER)
    {
      'id': '102',
      'type': 'quote',
      'title': 'Pesan Hati',
      'content': '"Allah tidak membebani seseorang melainkan sesuai kesanggupannya."',
      'author': 'Umu Kaisara',
      'authorAge': '38 thn',
      'likes': 850,
      'time': '5j',
      'assetPath': null, 
    },
    // ITEM 3 (COL KIRI - SAMBUNG)
    {
      'id': '103',
      'type': 'article',
      'title': 'Tips Qiamullail',
      'content': 'Cara mudah bangun malam.',
      'author': 'Admin',
      'authorAge': '',
      'likes': 445,
      'time': '1h',
      'assetPath': 'assets/images/dummy_post2.jpg',
    },
    // SETERUSNYA...
    {
      'id': '104',
      'type': 'event',
      'title': 'Kuliah Subuh',
      'content': 'Masjid Negeri.',
      'author': 'AJK Masjid',
      'authorAge': '',
      'likes': 200,
      'time': '30m',
      'assetPath': 'assets/images/dummy_post1.jpg',
    },
     {
      'id': '105',
      'type': 'quote',
      'title': 'Zikir',
      'content': 'Subhanallah.',
      'author': 'Imam Muda',
      'authorAge': '32 thn',
      'likes': 99,
      'time': '10m',
      'assetPath': null,
    },
    {
      'id': '106',
      'type': 'video',
      'title': 'Al-Mulk',
      'content': 'Tenangkan jiwa.',
      'author': 'Qari Muzammil',
      'authorAge': '27 thn',
      'likes': 3300,
      'time': '15m',
      'assetPath': 'assets/images/dummy_post2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const MetallicGold(child: Icon(Icons.dashboard_customize_rounded, size: 20)),
                    const SizedBox(width: 10),
                    Text(
                      "EXPLORE", 
                      style: TextStyle(
                        color: kPrimaryGold.withOpacity(0.9), 
                        fontSize: 14, 
                        letterSpacing: 2.5, 
                        fontWeight: FontWeight.w800
                      )
                    ),
                  ],
                ),
                Icon(Icons.filter_list, color: kTextSecondary, size: 20),
              ],
            ),
          ),

          // MASONRY GRID (BRICK BOND)
          MasonryGridView.count(
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
                // SIZE TAK PERLU HANTAR, KITA CONTROL DALAM CARD
                onTap: () {
                  if (post['type'] == 'spacer') return; // Spacer tak boleh klik
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
