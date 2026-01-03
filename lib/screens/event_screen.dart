import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math'; // Untuk random color logic

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

  // DATA MASTER (Dikemaskini dengan Aset Pokok & Warna Random)
  late final List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // Kita initialize data di sini supaya boleh assign warna random sekali sahaja
    items = [
      // 1. POKOK LEVEL 5 (Hijau)
      {
        'type': 'image',
        'name': 'ALAM FANA',
        'title': 'Puncak Makrifat',
        'asset': 'assets/images/pokok_level5.png', // Aset baru
        'views': '1.2M',
        'badge': 'LEVEL 5',
        'color': glassColors[2], // Hijau
      },
      // 2. VIDEO (Tree V1) - (Biru)
      {
        'type': 'video',
        'name': 'TADABBUR',
        'title': 'Zikir Alam',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '5.2M',
        'badge': 'VIDEO',
        'duration': '0:45',
        'color': glassColors[1], // Biru
      },
      // 3. POKOK LEVEL 3 (Pink)
      {
        'type': 'image',
        'name': 'USTAZ DON',
        'title': 'Ranting Iman',
        'asset': 'assets/images/pokok_level3.png', // Aset baru
        'views': '890K',
        'badge': 'LEVEL 3',
        'color': glassColors[0], // Pink
      },
      // 4. QUOTE (Kaca Biru)
      {
        'type': 'quote',
        'name': 'IMAM GHAZALI',
        'title': 'Nasihat Jiwa',
        'description': 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',
        'asset': '', 
        'views': '900K',
        'badge': 'NASIHAT',
        'color': glassColors[1], // Biru
      },
      // 5. POKOK LEVEL 2 (Hijau)
      {
        'type': 'image',
        'name': 'PROF. HAMKA',
        'title': 'Permulaan',
        'asset': 'assets/images/pokok_level2.png', // Aset baru
        'views': '450K',
        'badge': 'LEVEL 2',
        'color': glassColors[2], // Hijau
      },
      // 6. POKOK LEVEL 4 (Pink)
      {
        'type': 'image',
        'name': 'DR. MAZA',
        'title': 'Dahan Syariah',
        'asset': 'assets/images/pokok_level4.png', // Aset baru (assumption)
        'views': '1.5M',
        'badge': 'LEVEL 4',
        'color': glassColors[0], // Pink
      },
      // 7. VIDEO DENGAN GAMBAR (Biru)
      {
        'type': 'video',
        'name': 'HIJRAH 1446',
        'title': 'Perjalanan Agung',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '3.1M',
        'badge': 'DOCU',
        'duration': '2:30',
        'color': glassColors[1], // Biru
      },
      // 8. QUOTE (Kaca Hijau)
      {
        'type': 'quote',
        'name': 'RUMI',
        'title': 'Cinta Ilahi',
        'description': 'Apa yang kau cari, sedang mencarimu.',
        'asset': '',
        'views': '5M+',
        'badge': 'SUFI',
        'color': glassColors[2], // Hijau
      },
      // 9. DUMMY IMAGE (Pink)
      {
        'type': 'image',
        'name': 'MUALLAF UK',
        'title': 'London Story',
        'asset': 'assets/images/dummy_post1.jpg',
        'views': '2.5M',
        'badge': 'STORY',
        'color': glassColors[0], // Pink
      },
      // 10. DUMMY IMAGE (Biru)
      {
        'type': 'image',
        'name': 'USTAZAH SITI',
        'title': 'Fiqh Wanita',
        'asset': 'assets/images/dummy_post2.jpg',
        'views': '450K',
        'badge': 'FIQH',
        'color': glassColors[1], // Biru
      },
    ];
  }

  String selectedFilter = 'For you';
  final List<String> filters = ['Following', 'For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      body: Stack(
        children: [
          // 1. LATAR BELAKANG LANGIT (ASAL)
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

                // FILTER TABS
                SizedBox(
                  height: 44,
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            // Glass Effect Tab
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black87 : Colors.white,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ═══════════════════════════════════════════════════
                // GRID KONTEN (GLASS TILES 20%)
                // ═══════════════════════════════════════════════════
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.68, // Ratio untuk caption luar
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildGlassTileCard(item);
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
  // 🎯 GLASS TILE CARD BUILDER
  // ══════════════════════════════════════════════════════════════
  Widget _buildGlassTileCard(Map<String, dynamic> item) {
    // Ambil warna dari item, atau fallback ke biru jika tiada
    Color glassTint = item['color'] ?? const Color(0xFF2196F3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TILE KACA (MEDIA)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // ✅ EFEK KACA BERWARNA (20% Opacity)
              color: glassTint.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: glassTint.withOpacity(0.5), // Border sedikit terang
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: glassTint.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // CONTENT DALAM KACA
                  if (item['type'] == 'quote')
                     _buildQuoteContent(item, glassTint)
                  else
                     _buildImageContent(item),

                  // Badge & Views (Top Overlay)
                  Positioned(
                    top: 10, left: 10, right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge (Solid Color untuk Contrast)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: glassTint.withOpacity(0.9), // Warna solid
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['badge'],
                            style: const TextStyle(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Views (Hitam Transparan)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.visibility, color: Colors.white, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                item['views'],
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Icon & Duration
                  if (item['type'] == 'video') ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    Positioned(
                      bottom: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['duration'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 2. CAPTION AREA (LUAR)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Border Warna Kaca
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: glassTint, width: 1.5), // Ikut warna tile
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: glassTint.withOpacity(0.2),
                  // Guna aset jika ada, jika tidak guna ikon
                  backgroundImage: (item['type'] != 'quote' && item['asset'] != '') 
                      ? AssetImage(item['asset']) 
                      : null,
                  child: (item['type'] == 'quote' || item['asset'] == '')
                      ? Icon(Icons.person, size: 14, color: Colors.white.withOpacity(0.8))
                      : null,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetallicSilver(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['title'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12, fontWeight: FontWeight.w500, height: 1.2,
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
  // CONTENT BUILDERS
  // ══════════════════════════════════════════════════════════════

  Widget _buildQuoteContent(Map<String, dynamic> item, Color tint) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        item['description'] ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.4,
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageContent(Map<String, dynamic> item) {
    return Padding(
      // Padding sikit supaya nampak efek "Kaca" di sekeliling
      padding: const EdgeInsets.all(0), 
      child: Image.asset(
        item['asset'],
        fit: BoxFit.cover, // Penuhkan ruang
        errorBuilder: (context, error, stackTrace) {
          // Placeholder jika gambar pokok level tak jumpa
          return Center(
            child: Icon(Icons.image_not_supported, color: Colors.white.withOpacity(0.3)),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// METALLIC SILVER EFFECT
// ══════════════════════════════════════════════════════════════
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
