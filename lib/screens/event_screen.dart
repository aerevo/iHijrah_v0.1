import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// Pastikan package ini ada dalam pubspec.yaml. Jika tiada, boleh tukar ke GridView.count biasa.

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy ala Majalah (Kapten boleh ganti imej nanti)
    final List<Map<String, dynamic>> magazineItems = [
      {
        'title': 'USERS',
        'subtitle': 'COMMUNITY',
        'image': 'assets/images/mosque_bg.jpg', 
        'height': 280.0,
      },
      {
        'title': 'SIRAH',
        'subtitle': 'HISTORY',
        'image': 'assets/images/quran_bg.jpg', 
        'height': 220.0,
      },
      {
        'title': 'VIBE',
        'subtitle': 'AESTHETIC',
        'image': 'assets/images/nature_bg.jpg', 
        'height': 240.0,
      },
      {
        'title': 'ISLAM',
        'subtitle': 'LIFESTYLE',
        'image': 'assets/images/kaaba_bg.jpg', 
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
              imagePath: item['image'], 
            );
          },
        ),
      ),
    );
  }

  // WIDGET KAD ALA CAPCUT (UPGRADED)
  Widget _buildMagazineCard({
    required String title,
    required String subtitle,
    required double height,
    required String imagePath,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. GAMBAR PENUH (Full Brightness)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(color: Colors.grey.shade900),
            ),

            // 2. GRADIENT LANTAI (Rahsia Teks Jelas tapi Gambar Terang)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 0.8, 1.0], // Mula gelap di bawah saja
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // 3. TAG KATEGORI (Kecil di atas kiri - Macam 'Autocut' badge)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Glass effect
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white30, width: 0.5),
                ),
                child: Text(
                  subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            // 4. TEXT CONTENT (Tanam di Bawah Kiri)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Kunci: Letak bawah
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Besar!
                      fontFamily: 'Poppins', 
                      fontWeight: FontWeight.w900, // Paling Tebal
                      height: 1.0, // Rapatkan baris
                      shadows: [
                        Shadow(offset: Offset(0, 1), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // User Info (Kecil di bawah tajuk)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 10, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "iHijrah Official", 
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
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
