// lib/widgets/feed_panel.dart
// ═══════════════════════════════════════════════════════════════
// KOD LENGKAP: RODA MESIN SLOT (Ketatkan roda, tinggikan perspektif)
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

  // ── DATA ───────────────────────────────────────────────────
  final List<PostModel> _posts = const [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',      content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',          author: 'Ustaz Don',    authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                     content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                       author: "Imam Syafi'i", authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',               content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali.',                                        author: 'Habib Ali',    authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',             content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',                                     author: 'Admin iHijrah',authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Ulama',                     content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat.',                               author: 'Imam Malik',   authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas',                     content: 'Mari perbaiki bacaan Al-Fatihah kita bersama-sama.',                                                        author: 'Ustaz Azhar',  authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Amalan Rezeki',                   content: 'Rahsia Dhuha dan istighfar dalam membuka pintu rezeki yang tidak disangka-sangka.',                         author: 'Ustaz Wadi',   authorAge: '45', likes: 4500, time: '30m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 5),
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
        ),

        // ── RODA SCROLL (Fizik Mesin Slot) ──────────
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 150,       // Ketinggian kad dirapatkan sikit supaya getah nampak bersambung
            perspective: 0.0085,   // PERSPEKTIF EKSTREM: Ini buat dia bengkok macam roda pusing
            diameterRatio: 1.3,    // DIAMETER KETAT: Roda lebih kecil ibarat gear/silinder mesin slot
            squeeze: 1.1,          // Bagi kad sedikit overlap supaya tutup jurang (hilangkan rupa rantai besi)
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _currentIndex = index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                // Opacity Logic
                final int distance = (_currentIndex - index).abs();
                final double opacity = distance == 0 ? 1.0 : (distance == 1 ? 0.8 : 0.3);
                final bool isCenter = index == _currentIndex;

                return Opacity(
                  opacity: opacity,
                  child: FeedCard(
                    post: _posts[index],
                    isCenter: isCenter,
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
