import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

// ✅ INTEGRASI: Fail emas (Simpan untuk rujukan masa depan)
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // PALET WARNA KACA (Pink, Biru, Hijau)
  final List<Color> glassColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00E676), // Green
  ];

  late final List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // DATA DUMMY (POKOK & KONTEN)
    items = [
      {
        'type': 'image',
        'name': 'ALAM FANA',
        'title': 'Puncak',
        'asset': 'assets/images/pokok_level5.png',
        'views': '1.2M',
        'badge': 'LVL 5',
        'color': glassColors[2],
      },
      {
        'type': 'video',
        'name': 'TADABBUR',
        'title': 'Zikir',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '5.2M',
        'badge': 'VIDEO',
        'duration': '0:45',
        'color': glassColors[1],
      },
      {
        'type': 'image',
        'name': 'USTAZ DON',
        'title': 'Ranting',
        'asset': 'assets/images/pokok_level3.png',
        'views': '890K',
        'badge': 'LVL 3',
        'color': glassColors[0],
      },
      {
        'type': 'quote',
        'name': 'GHAZALI',
        'title': 'Nasihat',
        'description': 'Ilmu tanpa amal itu gila.',
        'asset': '', 
        'views': '900K',
        'badge': 'ILMU',
        'color': glassColors[1],
      },
      {
        'type': 'image',
        'name': 'HAMKA',
        'title': 'Mula',
        'asset': 'assets/images/pokok_level2.png',
        'views': '450K',
        'badge': 'LVL 2',
        'color': glassColors[2],
      },
      {
        'type': 'image',
        'name': 'DR. MAZA',
        'title': 'Syariah',
        'asset': 'assets/images/pokok_level4.png',
        'views': '1.5M',
        'badge': 'LVL 4',
        'color': glassColors[0],
      },
      {
        'type': 'video',
        'name': 'HIJRAH',
        'title': 'Agung',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '3.1M',
        'badge': 'DOCU',
        'duration': '2:30',
        'color': glassColors[1],
      },
      {
        'type': 'quote',
        'name': 'RUMI',
        'title': 'Cinta',
        'description': 'Apa yang kau cari, sedang mencarimu.',
        'asset': '',
        'views': '5M+',
        'badge': 'SUFI',
        'color': glassColors[2],
      },
      {
        'type': 'image',
        'name': 'UK STORY',
        'title': 'London',
        'asset': 'assets/images/dummy_post1.jpg',
        'views': '2.5M',
        'badge': 'STORY',
        'color': glassColors[0],
      },
      {
        'type': 'image',
        'name': 'SITI',
        'title': 'Fiqh',
        'asset': 'assets/images/dummy_post2.jpg',
        'views': '450K',
        'badge': 'FIQH',
        'color': glassColors[1],
      },
       {
        'type': 'image',
        'name': 'NABI',
        'title': 'Sirah',
        'asset': 'assets/images/dummy_post1.jpg',
        'views': '9M',
        'badge': 'SIRAH',
        'color': glassColors[2],
      },
      {
        'type': 'quote',
        'name': 'HIKMAH',
        'title': 'Sabar',
        'description': 'Sabar itu separuh daripada iman.',
        'asset': '',
        'views': '100K',
        'badge': 'ADAB',
        'color': glassColors[0],
      },
    ];
  }

  String selectedFilter = 'For you';
  final List<String> filters = ['For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                // FILTER TABS (Lebih Compact untuk 3 Column)
                SizedBox(
                  height: 38,
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
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black87 : Colors.white,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ═══════════════════════════════════════════════════
                // GRID KONTEN (3 LAJUR - CHECKERBOARD)
                // ═══════════════════════════════════════════════════
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // ✅ 3 LAJUR
                      crossAxisSpacing: 8, // Rapat sikit
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.58, // Lebih tinggi sebab caption di luar
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      // LOGIK PAPAN CATUR (CHECKERBOARD) UNTUK 3 LAJUR
                      // Dalam grid 3 lajur (ganjil), % 2 cukup untuk buat corak selang-seli berterusan
                      // 0: O, 1: X, 2: O
                      // 3: X, 4: O, 5: X
                      bool isTransparentTile = (index % 2 == 0); 

                      final item = items[index];
                      return _buildGlassTileCard(item, isTransparentTile);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // BOTTOM NAV
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
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 30), label: ''),
                const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black)),
                    child: const CircleAvatar(radius: 11, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 14, color: Colors.white)),
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
  // 🎯 GLASS TILE CARD (3 LAJUR)
  // ══════════════════════════════════════════════════════════════
  Widget _buildGlassTileCard(Map<String, dynamic> item, bool isTransparent) {
    // TENTUKAN WARNA:
    // Jika Transparent (O) -> Putih Nipis 10%
    // Jika Random (X) -> Warna Item 20%
    Color tileColor = isTransparent 
        ? Colors.white.withOpacity(0.1) 
        : (item['color'] as Color).withOpacity(0.2);

    Color borderColor = isTransparent
        ? Colors.white.withOpacity(0.2)
        : (item['color'] as Color).withOpacity(0.5);

    // LOGIK SHADOW TEKS: Hanya jika tile transparent
    List<Shadow> textShadows = isTransparent 
        ? [const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))]
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TILE KACA (MEDIA)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: tileColor, 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // KONTEN
                  if (item['type'] == 'quote')
                     _buildQuoteContent(item, isTransparent)
                  else
                     _buildImageContent(item),

                  // BADGE (KECILKAN UNTUK 3 LAJUR)
                  Positioned(
                    top: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['badge'],
                        style: const TextStyle(
                          color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // VIDEO ICON
                  if (item['type'] == 'video')
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 2. CAPTION AREA (LUAR & COMPACT)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Kecil
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: (item['type'] != 'quote' && item['asset'] != '') 
                      ? AssetImage(item['asset']) 
                      : null,
                  child: (item['type'] == 'quote' || item['asset'] == '')
                      ? const Icon(Icons.person, size: 12, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(width: 5),

              // Teks (Nama & Tajuk)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 9, 
                        fontWeight: FontWeight.w800,
                        shadows: textShadows, // ✅ SHADOW JIKA TRANSPARENT
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['title'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 8, 
                        fontWeight: FontWeight.w400,
                        shadows: textShadows, // ✅ SHADOW JIKA TRANSPARENT
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPER CONTENT
  // ══════════════════════════════════════════════════════════════

  Widget _buildQuoteContent(Map<String, dynamic> item, bool isTransparent) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        item['description'] ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10, // Kecilkan sikit untuk 3 lajur
          fontStyle: FontStyle.italic,
          shadows: isTransparent ? [const Shadow(color: Colors.black, blurRadius: 4)] : [],
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageContent(Map<String, dynamic> item) {
    // Tiada padding supaya nampak macam tiles penuh
    return Image.asset(
      item['asset'],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(Icons.image, color: Colors.white.withOpacity(0.3), size: 20),
        );
      },
    );
  }
}

// Helper Class untuk Nama Kilat (Optional - kalau nak guna)
class _MetallicSilver extends StatelessWidget {
  final Widget child;
  const _MetallicSilver({required this.child});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFBDBDBD)],
      ).createShader(bounds),
      child: child,
    );
  }
}
