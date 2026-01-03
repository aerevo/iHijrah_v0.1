import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Fail emas (Simpan untuk rujukan masa depan)
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // DATA MASTER (Mixed Types: Image, Video, Quote)
  // Saya perbanyakkan item untuk uji "Smooth Scroll"
  final List<Map<String, dynamic>> items = [
    // 1. VIDEO (tree_v1.mp4)
    {
      'type': 'video',
      'name': 'ALAM SEMESTA',
      'role': 'Tadabbur',
      'title': 'Pokok Berzikir',
      'description': 'Lihatlah bagaimana alam sujud kepada Pencipta.',
      'asset': 'assets/videos/tree_v1.mp4', // Fail Video Tuanku
      'views': '5.2M',
      'badge': 'VIDEO',
      'duration': '0:45',
    },
    // 2. QUOTE (Tanpa Gambar)
    {
      'type': 'quote',
      'name': 'IMAM GHAZALI',
      'role': 'Hujjatul Islam',
      'title': 'Nasihat Jiwa',
      'description': 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',
      'asset': '', 
      'views': '900K',
      'badge': 'NASIHAT',
      'color': Color(0xFF1E88E5), // Biru
    },
    // 3. IMAGE (Standard)
    {
      'type': 'image',
      'name': 'USTAZ AZHAR',
      'role': 'Mufti',
      'title': 'Sunat Ab\'ad',
      'description': 'Sunat yang ditinggalkan tidak berdosa.',
      'asset': 'assets/images/dummy_post1.jpg',
      'views': '1.2M',
      'badge': 'FIQH'
    },
    // 4. QUOTE LAIN
    {
      'type': 'quote',
      'name': 'IBNU QAYYIM',
      'role': 'Ahli Hati',
      'title': 'Ubat Hati',
      'description': 'Dunia ini ibarat bayang-bayang, kejar dia lari, lari dia kejar.',
      'asset': '',
      'views': '1.5M',
      'badge': 'TAZKIRAH',
      'color': Color(0xFFD81B60), // Pink Gelap
    },
    // 5. IMAGE
    {
      'type': 'image',
      'name': 'DR. MAZA',
      'role': 'Pendakwah',
      'title': 'Salon Muslimah',
      'description': 'Hukum dan panduan salon patuh syariah.',
      'image': 'assets/images/dummy_post2.jpg', // Support key lama 'image' juga
      'asset': 'assets/images/dummy_post2.jpg',
      'views': '890K',
      'badge': 'GUIDE'
    },
    // 6. VIDEO LAGI
    {
      'type': 'video',
      'name': 'HIJRAH 1446',
      'role': 'Dokumentari',
      'title': 'Perjalanan Agung',
      'description': 'Visualisasi perjalanan dari Mekah ke Madinah.',
      'asset': 'assets/videos/tree_v1.mp4',
      'views': '3.1M',
      'badge': 'DOCU',
      'duration': '2:30',
    },
    // --- REPEAT ITEMS UNTUK UJI SCROLLING ---
    {
      'type': 'image',
      'name': 'USTAZ DON',
      'role': 'Motivator',
      'title': 'Gua Thur',
      'description': 'Strategi labah-labah menyelamatkan Nabi.',
      'asset': 'assets/images/dummy_post2.jpg',
      'views': '1.8M',
      'badge': 'SIRAH'
    },
    {
      'type': 'quote',
      'name': 'RUMI',
      'role': 'Sufi',
      'title': 'Cinta Ilahi',
      'description': 'Apa yang kau cari, sedang mencarimu.',
      'asset': '',
      'views': '5M+',
      'badge': 'SUFI',
      'color': Color(0xFF43A047), // Hijau
    },
    {
      'type': 'image',
      'name': 'MUALLAF UK',
      'role': 'Inspirasi',
      'title': 'London Story',
      'description': 'Mencari Tuhan di tengah kota metropolitan.',
      'asset': 'assets/images/dummy_post1.jpg',
      'views': '2.5M',
      'badge': 'STORY'
    },
    {
      'type': 'video',
      'name': 'ZIKIR PAGI',
      'role': 'Amalan',
      'title': 'Tenang Jiwa',
      'description': 'Video loop pokok hijau untuk ketenangan.',
      'asset': 'assets/videos/tree_v1.mp4',
      'views': '8.8M',
      'badge': 'AMALAN',
      'duration': '10:00',
    },
     {
      'type': 'quote',
      'name': 'BUYA HAMKA',
      'role': 'Pemikir',
      'title': 'Erti Hidup',
      'description': 'Jangan takut jatuh, kerana yang tidak pernah memanjatlah yang tidak pernah jatuh.',
      'asset': '',
      'views': '700K',
      'badge': 'MOTIVASI',
      'color': Color(0xFF6D4C41), // Coklat
    },
    {
      'type': 'image',
      'name': 'USTAZAH SITI',
      'role': 'Fiqh Wanita',
      'title': 'Hukum Haid',
      'description': 'Soal jawab darah wanita dan ibadah.',
      'asset': 'assets/images/dummy_post2.jpg',
      'views': '450K',
      'badge': 'FIQH'
    },
  ];

  String selectedFilter = 'For you';
  final List<String> filters = ['Following', 'For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar Belakang Transparent (Nampak Langit Assets)
      backgroundColor: Colors.transparent, 
      
      body: Stack(
        children: [
          // 1. LATAR BELAKANG LANGIT
          Positioned.fill(
            child: Image.asset(
              'assets/images/langit.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF87CEEB), Color(0xFFE0F7FA)],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. KONTEN (SafeArea)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // FILTER TABS (Kekal sebagai navigasi tunggal)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      bool isSelected = filters[index] == selectedFilter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = filters[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            // Glass Effect Tab
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // GRID KONTEN (Mixed: Image, Video, Quote)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65, // Ratio menegak (Shorts style)
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // SWITCH LOGIC IKUT JENIS KONTEN
                      if (item['type'] == 'video') {
                        return _buildVideoCard(item);
                      } else if (item['type'] == 'quote') {
                        return _buildQuoteCard(item);
                      } else {
                        return _buildImageCard(item);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // BOTTOM NAV (Glass)
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5))),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey[700],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: 0,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 32), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 1. KAD GAMBAR (Standard)
  // ══════════════════════════════════════════════════════════════
  Widget _buildImageCard(Map<String, dynamic> item) {
    return _BaseCard(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item['asset'], fit: BoxFit.cover),
          _GradientOverlay(),
          _TopBadge(text: item['badge'], views: item['views']),
          _BottomInfo(item: item),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 2. KAD VIDEO (Ada Play Button)
  // ══════════════════════════════════════════════════════════════
  Widget _buildVideoCard(Map<String, dynamic> item) {
    return _BaseCard(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gelap sikit untuk Video
          Container(color: Colors.black87),
          
          // Center Play Icon
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ),

          // Duration Badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['duration'] ?? '0:00',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          _GradientOverlay(),
          
          // Badge Kiri Atas
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent, // Merah untuk Video
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['badge'],
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          _BottomInfo(item: item),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 3. KAD KUOTO (Teks Sahaja, Tanpa Gambar)
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuoteCard(Map<String, dynamic> item) {
    return _BaseCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item['color'] ?? Colors.blueAccent,
              (item['color'] as Color).withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.format_quote, color: Colors.white54, size: 24),
            const SizedBox(height: 8),
            Text(
              item['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              "- ${item['name']} -",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET KECIL (HELPER)
// ══════════════════════════════════════════════════════════════

class _BaseCard extends StatelessWidget {
  final Widget child;
  const _BaseCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  final String text;
  final String views;
  const _TopBadge({required this.text, required this.views});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, left: 8, right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
            child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          Row(children: [
            const Icon(Icons.visibility, color: Colors.white, size: 10),
            const SizedBox(width: 3),
            Text(views, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  final Map<String, dynamic> item;
  const _BottomInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'],
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item['description'],
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  // Fallback jika asset video tiada gambar
                  backgroundColor: Colors.grey,
                  backgroundImage: item['type'] == 'video' ? null : AssetImage(item['asset']),
                  child: item['type'] == 'video' ? const Icon(Icons.play_arrow, size: 10, color: Colors.white) : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetallicSilver(
                        child: Text(
                          item['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetallicSilver extends StatelessWidget {
  final Widget child;
  const _MetallicSilver({required this.child});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFBDBDBD), Color(0xFFE0E0E0)],
        stops: [0.0, 0.4, 0.6, 1.0],
      ).createShader(bounds),
      child: child,
    );
  }
}
