// lib/widgets/feed_panel.dart
// Vertical Wheel Carousel — EKSTREM 3D CURVATURE

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

  // ═══════════════════════════════════════════════════════════
  // DATA DUMMY DIPERBANYAKKAN UNTUK TEST RODA PUSING
  // ═══════════════════════════════════════════════════════════
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
      author: 'Imam Syafi\\'i', authorAge: '', likes: 850, time: '5j',
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
        
        // ─── ENJIN RODA 3D EKSTREM ──────────────────────────────────
        Expanded(
          child: ListWheelScrollView.useDelegate(
            // TINGGI KAD: 300px. Sesuai untuk nampak 1 atas (bengkok), 1-2 tengah (rata), 1 bawah (bengkok)
            itemExtent: 300, 
            
            // PERSPECTIVE: 0.009 (Hampir nilai maksimum 0.01). Sangat melengkung ke belakang!
            perspective: 0.009, 
            
            // DIAMETER RODA: 1.2 (Roda kecil). Kad akan lebih cepat 'jatuh' dari pandangan.
            diameterRatio: 1.2, 
            
            squeeze: 1.05, // Jarak kepadatan antara kad
            physics: const FixedExtentScrollPhysics(), // Wajib ada supaya dia 'snap' berhenti
            onSelectedItemChanged: (index) {
              setState(() => _currentIndex = index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _posts.length,
              builder: (context, index) {
                // Opacity Effect: Kad yang tengah aktif paling terang.
                // Kad yang melengkung atas/bawah akan jadi makin gelap.
                final double distance = (_currentIndex - index).abs().toDouble();
                final double opacity = (1.0 - (distance * 0.3)).clamp(0.2, 1.0);

                return Opacity(
                  opacity: opacity,
                  child: FeedCard(
                    post: _posts[index],
                    onTap: () {
                      // Boleh buat pop-up atau navigation nanti
                    },
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

  // ─── HEADER ────────────────────────────────────────────────
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
