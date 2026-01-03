import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Fail emas
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // PALET WARNA BADGE (Untuk Kuota)
  final List<Color> badgeColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Biru
    const Color(0xFF00E676), // Hijau
  ];

  late final List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // ⚠️ DATA DISUSUN SECARA 'SELANG-SELI' (MANUAL SORTING)
    // PATTERN: X (Quote), O (Media), X (Quote), O (Media)...
    // Supaya grid 3 lajur jadi:
    // X O X
    // O X O
    
    items = [
      // 0. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'GHAZALI',
        'title': 'Nasihat',
        'description': 'Ilmu tanpa amal itu gila.',
        'asset': '', 
        'views': '900K',
        'badge': 'ILMU',
        'badgeColor': badgeColors[1],
      },
      // 1. O - MEDIA (Video)
      {
        'type': 'video',
        'name': 'TADABBUR',
        'title': 'Zikir',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '5.2M',
        'badge': 'VIDEO',
        'duration': '0:45',
      },
      // 2. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'RUMI',
        'title': 'Cinta',
        'description': 'Apa yang kau cari, sedang mencarimu.',
        'asset': '',
        'views': '5M+',
        'badge': 'SUFI',
        'badgeColor': badgeColors[0],
      },
      // 3. O - MEDIA (Image)
      {
        'type': 'image',
        'name': 'ALAM FANA',
        'title': 'Puncak',
        'asset': 'assets/images/pokok_level5.png',
        'views': '1.2M',
        'badge': 'LVL 5',
      },
      // 4. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'HIKMAH',
        'title': 'Sabar',
        'description': 'Sabar itu separuh daripada iman.',
        'asset': '',
        'views': '100K',
        'badge': 'ADAB',
        'badgeColor': badgeColors[2],
      },
      // 5. O - MEDIA (Image)
      {
        'type': 'image',
        'name': 'USTAZ DON',
        'title': 'Ranting',
        'asset': 'assets/images/pokok_level3.png',
        'views': '890K',
        'badge': 'LVL 3',
      },
      // 6. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'BUYA',
        'title': 'Hidup',
        'description': 'Jangan takut jatuh, takutlah mati sebelum hidup.',
        'asset': '',
        'views': '300K',
        'badge': 'JIWA',
        'badgeColor': badgeColors[1],
      },
      // 7. O - MEDIA (Video)
      {
        'type': 'video',
        'name': 'HIJRAH',
        'title': 'Agung',
        'asset': 'assets/videos/tree_v1.mp4',
        'views': '3.1M',
        'badge': 'DOCU',
        'duration': '2:30',
      },
      // 8. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'IBNU SINA',
        'title': 'Sihat',
        'description': 'Waham adalah penyakit, tenang adalah ubat.',
        'asset': '',
        'views': '750K',
        'badge': 'MEDIK',
        'badgeColor': badgeColors[2],
      },
      // 9. O - MEDIA (Image)
      {
        'type': 'image',
        'name': 'HAMKA',
        'title': 'Mula',
        'asset': 'assets/images/pokok_level2.png',
        'views': '450K',
        'badge': 'LVL 2',
      },
      // 10. X - QUOTE (Transparent)
      {
        'type': 'quote',
        'name': 'SYAFIE',
        'title': 'Masa',
        'description': 'Masa ibarat pedang, jika kau tak potong, ia memotongmu.',
        'asset': '',
        'views': '2M',
        'badge': 'MASA',
        'badgeColor': badgeColors[0],
      },
      // 11. O - MEDIA (Image)
      {
        'type': 'image',
        'name': 'DR. MAZA',
        'title': 'Syariah',
        'asset': 'assets/images/pokok_level4.png',
        'views': '1.5M',
        'badge': 'LVL 4',
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

                // FILTER TABS (Compact)
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
                // GRID KONTEN (3 LAJUR - SUSUNAN TEPAT)
                // ═══════════════════════════════════════════════════
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // ✅ 3 LAJUR
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.58, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // KITA DAH SUSUN DATA SECARA MANUAL (QUOTE, MEDIA, QUOTE, MEDIA)
                      // JADI BUILDER HANYA PERLU RENDER IKUT TYPE SAHAJA
                      
                      if (item['type'] == 'quote') {
                        return _buildTransparentTile(item); // X (Kuota)
                      } else {
                        return _buildMediaTile(item); // O (Gambar/Video)
                      }
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
  // TILE X: KUOTA (TRANSPARENT + SHADOW)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTransparentTile(Map<String, dynamic> item) {
    // Shadow WAJIB untuk tulisan atas transparent
    const textShadows = [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))];

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // Glass Nipis
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // TEKS KUOTA
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    item['description'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(color: Colors.black, blurRadius: 6)], // Shadow Kuat
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // BADGE
                Positioned(
                  top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item['badgeColor'] as Color).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['badge'],
                      style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 6),
        
        // CAPTION BAWAH (Avatar & Nama - Putih + Shadow)
        _buildBottomCaption(item, hasShadow: true),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TILE O: MEDIA (GAMBAR/VIDEO PENUH)
  // ══════════════════════════════════════════════════════════════
  Widget _buildMediaTile(Map<String, dynamic> item) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // GAMBAR PENUH
                  Image.asset(
                    item['asset'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[300]);
                    },
                  ),
                  
                  // BADGE
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
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
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

        // CAPTION BAWAH (Standard)
        _buildBottomCaption(item, hasShadow: true),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPER CAPTION
  // ══════════════════════════════════════════════════════════════
  Widget _buildBottomCaption(Map<String, dynamic> item, {bool hasShadow = false}) {
    List<Shadow> shadows = hasShadow 
      ? [const Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))]
      : [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 9, 
                    fontWeight: FontWeight.w900,
                    shadows: shadows,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['title'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 8, 
                    fontWeight: FontWeight.w500,
                    shadows: shadows,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
