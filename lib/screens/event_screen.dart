import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy (DENGAN PENANDA ARAS "HANTU")
    final List<Map<String, dynamic>> items = [
      {
        'name': 'STATUS',  // <--- PENANDA 1
        'age': '100%',
        'caption': 'HANTU DAH HILANG 👻', // <--- PENANDA 2 (Kalau nampak ni, APK baru berjaya)
        'image': 'assets/images/mosque_bg.jpg', 
        'height': 300.0
      },
      {
        'name': 'FATIMAH', 
        'age': '21', 
        'caption': 'Cinta Al-Quran', 
        'image': 'assets/images/quran_bg.jpg', 
        'height': 240.0
      },
      {
        'name': 'ADAM', 
        'age': '28', 
        'caption': 'Musafir Ilmu', 
        'image': 'assets/images/nature_bg.jpg', 
        'height': 260.0
      },
      {
        'name': 'YUSOF', 
        'age': '30', 
        'caption': 'Hijrah Hati', 
        'image': 'assets/images/kaaba_bg.jpg', 
        'height': 280.0
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Latar Gelap
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2, 
        crossAxisSpacing: 2,
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
    );
  }

  Widget _buildRawPoster({
    required String name,
    required String age,
    required String caption,
    required double height,
    required String imagePath,
  }) {
    return Container(
      height: height,
      color: Colors.grey.shade900,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. GAMBAR (PENUH SKRIN)
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (c, o, s) => Container(color: Colors.grey.shade800),
          ),

          // 2. GRADIENT BAWAH (Wajib ada supaya tulisan nampak)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),

          // 3. TULISAN CAPCUT (EMAS BERKILAU)
          Positioned(
            bottom: 12,
            left: 10,
            right: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA EMAS
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFF59D), Color(0xFFFFD54F), Color(0xFFFF6F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26, // Besar
                      fontWeight: FontWeight.w900, // Tebal Giler
                      fontFamily: 'Roboto', 
                      color: Colors.white,
                      height: 0.9,
                      shadows: [
                         Shadow(offset: Offset(0,0), blurRadius: 15, color: Colors.white54) // Glow Silver
                      ]
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),

                // CAPTION PUTIH
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24, 
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        "$age", 
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded( // Tambah Expanded elak tulisan panjang terpotong
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
