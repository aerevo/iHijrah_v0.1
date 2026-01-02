import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy (Nama, Umur, Caption)
    final List<Map<String, dynamic>> items = [
      {
        'name': 'AISYAH',
        'age': '24',
        'caption': 'Pejuang Subuh',
        'image': 'assets/images/mosque_bg.jpg', 
        'height': 280.0,
      },
      {
        'name': 'FATIMAH',
        'age': '21',
        'caption': 'Cinta Al-Quran',
        'image': 'assets/images/quran_bg.jpg', 
        'height': 220.0,
      },
      {
        'name': 'ADAM',
        'age': '28',
        'caption': 'Musafir Ilmu',
        'image': 'assets/images/nature_bg.jpg', 
        'height': 240.0,
      },
      {
        'name': 'YUSOF',
        'age': '30',
        'caption': 'Hijrah Hati',
        'image': 'assets/images/kaaba_bg.jpg', 
        'height': 260.0,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildRawPoster(
              name: item['name'],
              age: item['age'],
              caption: item['caption'],
              height: item['height'],
              imagePath: item['image'], 
            );
          },
        ),
      ),
    );
  }

  // WIDGET CAPCUT RAW (TANPA KAD)
  Widget _buildRawPoster({
    required String name,
    required String age,
    required String caption,
    required double height,
    required String imagePath,
  }) {
    return Container(
      height: height,
      // HANYA ClipRRect, TIADA DECORATION/SHADOW KOTAK
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. GAMBAR PENUH (Background)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(color: Colors.grey.shade900),
            ),

            // 2. GRADIENT HALUS (Supaya tulisan Emas nampak, tapi bukan kotak)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100, // Gradient hanya di bahagian bawah
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3), // Sangat nipis
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // 3. TEXT CONTENT (EMAS & SILVER)
            Positioned(
              bottom: 15,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA (GOLD GRADIENT TEXT)
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFFFFF176), // Emas Muda (Kuning Cerah)
                          Color(0xFFFFD700), // Emas Tulen
                          Color(0xFFFFB300), // Emas Gelap (Amber)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900, // Tebal macam CapCut
                        fontFamily: 'Poppins', 
                        color: Colors.white, // Warna asas (akan ditutup shader)
                        height: 1.0,
                        shadows: [
                          // BAYANG SILVER (GLOW)
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 10.0,
                            color: Colors.white60, // Silver Glow
                          ),
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2.0,
                            color: Colors.black45, // Bayang Hitam sikit utk readability
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // UMUR & CAPTION (PUTIH BERSIH)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Glass nipis
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white30, width: 0.5),
                        ),
                        child: Text(
                          "$age THN",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            shadows: const [
                              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
