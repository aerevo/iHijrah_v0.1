to// lib/widgets/feed_panel.dart
// ═══════════════════════════════════════════════════════════════
// PREMIUM UPGRADES APPLIED:
//   [U1] AnimatedScale snap micro-interaction
//   [U4] isCenter flag → FeedCard colored shadow glow
// ═══════════════════════════════════════════════════════════════

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

  final List<PostModel> _posts = const [
    PostModel(
      id: '101', type: 'video', title: 'Kisah Hijrah Rasulullah',
      content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',
      author: 'Ustaz Don', authorAge: '40', likes: 1240, time: '2j',
      assetPath: 'assets/images/dummy_post1.jpg',
    ),
    PostModel(
      id: '102', type: 'quote', title: 'Kata Hikmah',
      content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',
      author: "Imam Syafi'i", authorAge: '', likes: 850, time: '5j',
    ),
    PostModel(
      id: '103', type: 'article', title: 'Kelebihan Selawat',
      content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali.',
      author: 'Habib Ali', authorAge: '52', likes: 2100, time: '1h',
      assetPath: 'assets/images/dummy_post2.jpg',
    ),
    PostModel(
      id: '104', type: 'event', title: 'Majlis Ilmu Perdana',
      content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',
      author: 'Admin iHijrah', authorAge: '', likes: 500, time: '10j',
    ),
    PostModel(
      id: '105', type: 'quote', title: 'Pesan Ulama',
      content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat.',
      author: 'Imam Malik', authorAge: '', likes: 3200, time: '12j',
    ),
    PostModel(
      id: '106', type: 'video', title: 'Tajwid Asas',
      content: 'Mari perbaiki bacaan Al-Fatihah kita bersama-sama.',
      author: 'Ustaz Azhar', authorAge: '60', likes: 890, time: '1h',
    ),
    PostModel(
      id: '107', type: 'article', title: 'Amalan Rezeki',
      content: 'Rahsia Dhuha dan istighfar dalam membuka pintu rezeki yang tidak disangka-sangka.',
      author: 'Ustaz Wadi', authorAge: '45', likes: 4500, time: '30m',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 280,
            perspective: 0.009,
            diameterRatio: 3.5,
            squeeze: 0.88,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _currentIndex = index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                final double distance = (_currentIndex - index).abs().toDouble();
                final double opacity = (1.0 - (distance * 0.3)).clamp(0.2, 1.0);
                final bool isCenter = distance == 0;

                // ╔══════════════════════════════════════════════╗
                // ║  [U1] SNAP SCALE MICRO-INTERACTION           ║
                // ║  center=1.0, satu atas/bawah=0.94, lebih=0.88║
                // ║  easeOutCubic bagi rasa elastic, bukan linear║
                // ╚══════════════════════════════════════════════╝
                final double scale = isCenter
                    ? 1.0
                    : (1.0 - (distance * 0.06)).clamp(0.88, 1.0);

                return AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: Opacity(
                    opacity: opacity,
                    child: FeedCard(
                      post: _posts[index],
                      isCenter: isCenter, // [U4] untuk glow dalam FeedCard
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        _buildDotIndicator(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.explore_rounded, color: kPrimaryGold, size: 20),
              SizedBox(width: 8),
              Text(
                'JELAJAH KOMUNITI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.tune, color: kTextSecondary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_posts.length, (index) {
          final bool isActive = index == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? kPrimaryGold : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
