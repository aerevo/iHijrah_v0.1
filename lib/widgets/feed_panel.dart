// lib/widgets/feed_panel.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'feed_card.dart';

class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  int _currentIndex = 0;

  // DATA DUMMY (Sengaja aku tambah 4 supaya kau nampak roda tu penuh)
  final List<PostModel> _posts = const [
    PostModel(
      id: '101', type: 'video', title: 'Kisah Gua Thur',
      content: 'Bagaimana laba-laba menyelamatkan baginda dari kaum Musyrikin.',
      author: 'Ustaz Don', authorAge: '40', likes: 1240, time: '2j',
      assetPath: 'assets/images/dummy_post1.jpg',
    ),
    PostModel(
      id: '102', type: 'quote', title: 'Mutiara Syafi\'i',
      content: 'Jangan bersedih, sesungguhnya Allah sentiasa bersama kita.',
      author: 'Zyamina', authorAge: 'Admin', likes: 850, time: '5j',
    ),
    PostModel(
      id: '103', type: 'article', title: 'Fadhilat Selawat',
      content: 'Satu selawat dibalas sepuluh rahmat. Mari kita basahkan lidah.',
      author: 'Habib Ali', authorAge: '52', likes: 2100, time: '1h',
      assetPath: 'assets/images/dummy_post2.jpg',
    ),
    PostModel(
      id: '104', type: 'event', title: 'Majlis Sirah',
      content: 'Kupasan mendalam tentang peristiwa Hijrah di Masjid Negeri.',
      author: 'AJK Masjid', authorAge: '', likes: 300, time: '10j',
      assetPath: 'assets/images/langit.png', // Guna je gambar sedia ada utk test
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'JENDELA ILMU',
                style: TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                child: const Icon(Icons.tune, color: kTextSecondary, size: 16),
              ),
            ],
          ),
        ),

        // ENJIN RODA EKSTREM
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 165, // ⬅️ KAD LEPER: Ketinggian ditetapkan 165px supaya muat 4 post
            perspective: 0.007, // ⬅️ 3D EKSTREM: Makin tinggi (max 0.01), makin bengkok kad kat atas/bawah
            diameterRatio: 1.4, // ⬅️ SAIZ TONG: Makin kecil nilai, makin tajam lengkungan roda
            squeeze: 1.1, // Bagi kad tu rapat sikit
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => setState(() => _currentIndex = index),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                return FeedCard(
                  post: _posts[index],
                  // Animasi Opacity: Kad kat tengah terang, kat tepi gelap sikit
                  isActive: _currentIndex == index, 
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
