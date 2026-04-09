// lib/widgets/feed_panel.dart
// Vertical Wheel Carousel — 5 slot visible
// center(3 flat) + near-top + near-bottom melengkung ke belakang

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

  // ── DATA ───────────────────────────────────────────────────
  final List<PostModel> _posts = const [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',      content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',          author: 'Ustaz Don',    authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                     content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                       author: "Imam Syafi'i", authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Berselawat',             content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',               author: 'Habib Ali',    authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu: Sirah Nabawiyah',    content: 'Jom hadir ke Masjid Negeri untuk kupasan kitab Sirah bersama para ulama terkemuka.',                      author: 'Admin iHijrah',authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Imam Malik',                content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',                  author: 'Imam Malik',   authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas: Al-Fatihah',         content: 'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',                      author: 'Ustaz Azhar',  authorAge: '60', likes: 890,  time: '1h',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '107', type: 'article', title: 'Rahsia Dhuha & Pintu Rezeki',     content: 'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka oleh manusia biasa.',             author: 'Ustaz Wadi',   authorAge: '45', likes: 4500, time: '30m', assetPath: 'assets/images/dummy_post2.jpg'),
  ];

  // Tinggi setiap item dalam wheel
  // Kena consistent supaya snap betul
  static const double _itemExtent = 290.0;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        // ── WHEEL ENGINE ──────────────────────────────────────
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _controller,

            // Tinggi setiap kad
            itemExtent: _itemExtent,

            // ── Cylinder params ──
            // diameterRatio: 3.5 → roda besar, center hampir flat,
            // tepi atas/bawah melengkung dramatik ke belakang
            diameterRatio: 3.5,

            // perspective: 0.009 → kedalaman 3D maksimum
            // nilai ini yang buat kad tepi nampak "tersedut" masuk
            perspective: 0.009,

            // squeeze < 1.0 → pack lebih rapat
            // supaya kad atas/bawah masih visible dalam viewport
            squeeze: 0.88,

            // Snap — berhenti tepat di setiap kad
            physics: const FixedExtentScrollPhysics(),

            onSelectedItemChanged: (index) {
              setState(() => _currentIndex = index);
            },

            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                final double distance = (_currentIndex - index).abs().toDouble();
                final bool isCenter  = distance == 0;

                // ── Scale micro-interaction ──
                // center=1.0, near=0.94, far=0.88
                // easeOutCubic → rasa elastic masa snap
                final double scale = isCenter
                    ? 1.0
                    : (1.0 - distance * 0.06).clamp(0.88, 1.0);

                // ── Opacity falloff ──
                // center=1.0, near=0.65, far=0.25
                final double opacity = (1.0 - distance * 0.35).clamp(0.25, 1.0);

                return AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: FeedCard(
                      post: _posts[index],
                      isCenter: isCenter,
                      onTap: () {
                        if (!isCenter) {
                          // Tap kad tepi → scroll ke situ
                          _controller.animateToItem(
                            index,
                            duration: const Duration(milliseconds: 420),
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

        _buildDotIndicator(),
      ],
    );
  }

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
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
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tune_rounded, color: Colors.white.withOpacity(0.4), size: 15),
          ),
        ],
      ),
    );
  }

  // ── DOT INDICATOR ─────────────────────────────────────────
  Widget _buildDotIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}
