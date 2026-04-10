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
  late final FixedExtentScrollController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<PostModel> _posts = const [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',   content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',    author: 'Ustaz Don',     authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                  content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                  author: "Imam Syafi'i",  authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',            content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali.',                                   author: 'Habib Ali',     authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',          content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',                               author: 'Admin iHijrah', authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Ulama',                  content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat.',                          author: 'Imam Malik',    authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas',                  content: 'Mari perbaiki bacaan Al-Fatihah kita bersama-sama.',                                                   author: 'Ustaz Azhar',   authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Amalan Rezeki',                content: 'Rahsia Dhuha dan istighfar dalam membuka pintu rezeki yang tidak disangka-sangka.',                    author: 'Ustaz Wadi',    authorAge: '45', likes: 4500, time: '30m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.explore_rounded, color: kPrimaryGold, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'JELAJAH KOMUNITI',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tune_rounded, color: Colors.white.withOpacity(0.4), size: 15),
              ),
            ],
          ),
        ),

        // ── RODA 3D ─────────────────────────────────────────
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _controller,

            // [FIX 1 & 2] itemExtent kecil + diameterRatio besar =
            // 5 kad nampak serentak, roda isi penuh ruang
            itemExtent: 125,
            diameterRatio: 3.5,   // silinder besar → center flat, tepi melengkung
            perspective: 0.009,   // kedalaman 3D
            squeeze: 0.80,        // pack rapat → 5 kad muat dalam viewport

            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _currentIndex = index);
            },

            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                final int distance = (_currentIndex - index).abs();
                final bool isCenter = distance == 0;

                // Scale: center=1.0, near=0.95, far=0.89
                final double scale = isCenter ? 1.0
                    : distance == 1 ? 0.95
                    : 0.89;

                // Opacity: center=1.0, near=0.70, far=0.35
                final double opacity = isCenter ? 1.0
                    : distance == 1 ? 0.70
                    : 0.35;

                return AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    child: FeedCard(
                      post: _posts[index],
                      isCenter: isCenter,
                      onTap: () {
                        if (!isCenter) {
                          _controller.animateToItem(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── DOT INDICATOR ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_posts.length, (index) {
              final bool isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryGold : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
