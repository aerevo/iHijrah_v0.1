// lib/widgets/feed_panel.dart (FULL OVERWRITE: WHEEL ENGINE)

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
  // Data Testing (Abaikan dummy, kita fokus UI dulu)
  final List<Map<String, dynamic>> posts = const [
    {
      'id': '101', 'type': 'video', 'title': 'Kisah Hijrah Rasulullah',
      'content': 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.', 
      'author': 'Ustaz Don', 'authorAge': '40 thn', 'likes': 1240, 'time': '2j',
    },
    {
      'id': '102', 'type': 'quote', 'title': 'Mutiara Kata',
      'content': 'Jangan bersedih, sesungguhnya Allah bersama kita.', 
      'author': 'Zyamina Studio', 'authorAge': 'Admin', 'likes': 850, 'time': '5j',
    },
    {
      'id': '103', 'type': 'article', 'title': 'Kelebihan Selawat',
      'content': 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali.', 
      'author': 'Habib Ali', 'authorAge': '52 thn', 'likes': 2100, 'time': '1h',
    },
    {
      'id': '104', 'type': 'event', 'title': 'Majlis Ilmu Perdana',
      'content': 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.', 
      'author': 'Admin iHijrah', 'authorAge': '', 'likes': 500, 'time': '10j',
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
            "JENDELA ILMU", 
            style: TextStyle(
              color: kPrimaryGold, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 2, 
              fontSize: 11
            )
          ),
        ),

        // === ENJIN RODA (WHEEL SCROLL) ===
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 280, // Tinggi satu kad. Adjust ikut keselesaan mata.
            perspective: 0.003, // Tahap kelengkungan roda (Sangat penting untuk vibe iOS)
            diameterRatio: 1.8, // Saiz bulatan roda
            physics: const FixedExtentScrollPhysics(), // Buat dia "Snap" (melekat) pada kad
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: posts.length,
              builder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FeedCard(
                    id: post['id'],
                    title: post['title'],
                    subtitle: post['content'],
                    author: post['author'],
                    authorAge: post['authorAge'],
                    time: post['time'],
                    type: post['type'],
                    likes: post['likes'],
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (c) => PostDetailPage(post: post))
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
