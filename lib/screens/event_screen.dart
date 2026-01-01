import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/constants.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy ala Majalah (Kapten boleh ganti imej nanti)
    final List<Map<String, dynamic>> magazineItems = [
      {
        'title': 'USERS',
        'subtitle': 'COMMUNITY',
        'image': 'assets/images/mosque_bg.jpg', // Ganti dgn gambar user
        'height': 280.0,
      },
      {
        'title': 'SIRAH',
        'subtitle': 'HISTORY',
        'image': 'assets/images/quran_bg.jpg', // Ganti gambar
        'height': 220.0,
      },
      {
        'title': 'VIBE',
        'subtitle': 'AESTHETIC',
        'image': 'assets/images/nature_bg.jpg', // Ganti gambar
        'height': 240.0,
      },
      {
        'title': 'ISLAM',
        'subtitle': 'LIFESTYLE',
        'image': 'assets/images/kaaba_bg.jpg', // Ganti gambar
        'height': 260.0,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        
        // Guna Masonry Grid untuk susunan 'Tidak Sekata' (Pinterest Style)
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: magazineItems.length,
          itemBuilder: (context, index) {
            final item = magazineItems[index];
            return _buildMagazineCard(
              title: item['title'],
              subtitle: item['subtitle'],
              height: item['height'],
              imagePath: item['image'], // Pastikan path ini wujud atau dia jadi kelabu
            );
          },
        ),
      ),
    );
  }

  // WIDGET KAD MAJALAH (RAHSIA TEKS 'TANAM')
  Widget _buildMagazineCard({
    required String title,
    required String subtitle,
    required double height,
    required String imagePath,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. GAMBAR LATAR (BASE)
            Container(
              color: Colors.grey.shade800, // Fallback color kalau gambar takda
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white24, size: 40)
                ),
              ),
            ),

            // 2. GRADIENT BAYANG (INI RAHSIA SUPAYA TEKS 'TANAM')
            // Kita gelapkan bahagian bawah sahaja, supaya teks putih nampak timbul
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6), // Mula gelap sikit
                    Colors.black.withOpacity(0.9), // Gelap pekat di bawah
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),

            // 3. TEKS (TYPOGRAPHY)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle Halus
                  Text(
                    subtitle.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.5, // Jarak huruf jauh (Style Majalah)
                    ),
                  ),
                  
                  const SizedBox(height: 4),

                  // TAJUK UTAMA (YG KAPTEN KATA KAKU TU, KITAU UBAH SINI)
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28, 
                      fontWeight: FontWeight.w900, // W900 = Paling Tebal (Macam Poster)
                      letterSpacing: 1.2, 
                      height: 0.9, // Rapatkan baris kalau teks panjang
                      shadows: [
                        // Shadow lembut supaya tak nampak leper
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 10.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),

                  // Garisan Emas (Pemanis)
                  const SizedBox(height: 8),
                  Container(
                    width: 25,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700), // Emas
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
