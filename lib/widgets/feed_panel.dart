// lib/widgets/feed_panel.dart (HANYA POKOK + FEED DUMMY)

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/constants.dart';
import 'hijrah_tree.dart';
import 'feed_card.dart';
import 'post_detail_page.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  // DATA DUMMY (Kekal)
  final List<Map<String, dynamic>> posts = const [
    {
      'id': '101', 'type': 'video', 'title': 'Kisah Hijrah Rasulullah',
      'content': 'Detik cemas di Gua Thur.', 'author': 'Ustaz Don',
      'authorAge': '40 thn', 'likes': 1240, 'time': '2j',
      'assetPath': 'assets/images/dummy_post1.jpg',
    },
    { 'id': 'spacer_1', 'type': 'spacer' },
    {
      'id': '102', 'type': 'quote', 'title': 'Kata Hikmah',
      'content': 'Jangan bersedih, Allah bersama kita.', 'author': 'Imam Syafi\'i',
      'authorAge': '', 'likes': 850, 'time': '5j', 'assetPath': '',
    },
     {
      'id': '103', 'type': 'article', 'title': 'Tips Murah Rezeki',
      'content': 'Amalkan Dhuha dan sedekah subuh konsisten.', 'author': 'Prof Muhaya',
      'authorAge': '60 thn', 'likes': 3000, 'time': '1h',
      'assetPath': 'assets/images/dummy_post2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 150),
      child: Column(
        children: [
          // 1. POKOK SAHAJA DI ATAS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HijrahTree(),
          ),

          const SizedBox(height: 30),

          // 2. FEED MASONRY (DUMMY) DI BAWAH
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
