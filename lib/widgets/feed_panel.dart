// lib/widgets/feed_panel.dart
// Vertical Wheel Carousel — ListWheelScrollView.useDelegate
// Snap physics + 3D curvature (perspective: 0.003, diameterRatio: 1.8)

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'feed_card.dart';

class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  late final FixedExtentScrollController _scrollController;
  int _currentIndex = 0;

  // ═══════════════════════════════════════════════════════════
  // DATA DUMMY — ganti dengan API/provider bila dah ready
  // ═══════════════════════════════════════════════════════════
  final List<PostModel> _posts = const [
    PostModel(
      id: '101',
      type: 'video',
      title: 'Kisah Hijrah Rasulullah',
      content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',
      author: 'Ustaz Don',
      authorAge: '40',
      likes: 1240,
      time: '2j',
      assetPath: 'assets/images/dummy_post1.jpg',
    ),
    PostModel(
      id: '102',
      type: 'quote',
      title: 'Kata Hikmah',
      content: 'Jangan bersedih, sesungguhnya Allah bersama kita.\n\n— At-Taubah: 40',
      author: 'Imam Syafi\'i',
      authorAge: '',
      likes: 850,
      time: '5j',
    ),
    PostModel(
      id: '103',
      type: 'article',
      title: 'Tips Murah Rezeki',
      content: 'Amalkan Solat Dhuha dan sedekah subuh secara konsisten setiap hari. Lihat perubahan dalam 40 hari.',
      author: 'Prof Muhaya',
      authorAge: '60',
      likes: 3000,
      time: '1h',
      assetPath: 'assets/images/dummy_post2.jpg',
    ),
    PostModel(
      id: '104',
      type: 'video',
      title: 'Tadabbur Al-Mulk',
      content: 'Kelebihan membaca surah Al-Mulk sebelum tidur. Perlindungan dari azab kubur.',
      author: 'Ustaz Wadi',
      authorAge: '38',
      likes: 5200,
      time: '3j',
      assetPath: 'assets/images/dummy_post1.jpg',
    ),
    PostModel(
      id: '105',
      type: 'article',
      title: 'Kekuatan Istighfar',
      content: 'Barangsiapa yang membiasakan istighfar, Allah akan memberinya jalan keluar dari setiap kesempitan.',
      author: 'Ustazah Norhafizah',
      authorAge: '45',
      likes: 2100,
      time: '6j',
    ),
    PostModel(
      id: '106',
      type: 'event',
      title: 'Majlis Ilmu: Tazkiyatun Nafs',
      content: 'Hadir dan dapatkan ilmu pembersih jiwa. Sabtu ini, 8.00 malam di Masjid Al-Falah.',
      author: 'Pertubuhan MAPIM',
      authorAge: '',
      likes: 420,
      time: '12j',
      assetPath: 'assets/images/dummy_post2.jpg',
    ),
  ];

  // Tinggi setiap kad dalam wheel — kena konsisten untuk snap betul
  static const double _itemExtent = 340.0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── HEADER ─────────────────────────────────────────
        _buildHeader(),

        // ── WHEEL CAROUSEL ──────────────────────────────────
        Expanded(
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              // Update current index untuk dot indicator
              final idx = _scrollController.selectedItem;
              if (idx != _currentIndex) {
                setState(() => _currentIndex = idx);
              }
              return false;
            },
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,

              // ── 3D WHEEL PARAMS ─────────────────────────
              itemExtent: _itemExtent,
              diameterRatio: 1.8,      // Kelengkungan silinder
              perspective: 0.003,       // Kedalaman 3D
              squeeze: 1.0,            // Jarak antara item (1.0 = normal)
              offAxisFraction: 0.0,    // Sejajar tengah

              // ── SNAP PHYSICS ────────────────────────────
              physics: const FixedExtentScrollPhysics(),

              // ── RENDER DELEGATE ─────────────────────────
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _posts.length,
                builder: (context, index) {
                  return AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      // Opacity: kad yang jauh dari tengah jadi lebih gelap
                      double opacity = 1.0;
                      if (_scrollController.hasClients) {
                        final double selected = _scrollController.selectedItem.toDouble();
                        final double diff = (index - selected).abs();
                        // Kad tengah: 1.0, satu atas/bawah: 0.6, lagi jauh: 0.3
                        opacity = (1.0 - (diff * 0.4)).clamp(0.3, 1.0);
                      }
                      return Opacity(
                        opacity: opacity,
                        child: FeedCard(
                          post: _posts[index],
                          onTap: () {
                            // Scroll ke kad yang ditap dulu, baru buka detail
                            _scrollController.animateToItem(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // ── DOT INDICATOR ───────────────────────────────────
        _buildDotIndicator(),
      ],
    );
  }

  // ─── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.explore, color: kPrimaryGold, size: 20),
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

  // ─── DOT INDICATOR ─────────────────────────────────────────
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
