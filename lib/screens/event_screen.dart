import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Panggil fail emas original (Kita simpan import ini jika perlu)
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // Data Bersepadu - Islamic Content dengan Aset Original
  final List<Map<String, dynamic>> items = [
    {
      'name': 'USTAZ AZHAR',
      'role': 'Mufti',
      'title': 'Sunat Ab\'ad',
      'description': 'Sunat yang ditinggalkan tidak berdosa, diamalkan dapat pahala.',
      'image': 'assets/images/dummy_post1.jpg',
      'views': '1.2M',
      'badge': 'FIQH'
    },
    {
      'name': 'DR. MAZA',
      'role': 'Pendakwah',
      'title': 'Salon Muslimah',
      'description': 'Salon wanita di Wisma Yakin, The Curve, SOGO - ada private section.',
      'image': 'assets/images/dummy_post2.jpg',
      'views': '890K',
      'badge': 'GUIDE'
    },
    {
      'name': 'IMAM NAWAWI',
      'role': 'Ulama',
      'title': 'Hikmah Sunat',
      'description': 'Tinggal sunat ab\'ad tidak berdosa tapi hilang keutamaan.',
      'image': 'assets/images/dummy_post1.jpg',
      'views': '2.1M',
      'badge': 'CLASSIC'
    },
    {
      'name': 'USTAZAH SITI',
      'role': 'Pakar Wanita',
      'title': 'Panduan Hijab',
      'description': 'Cara memilih salon yang patuh syariah untuk muslimah.',
      'image': 'assets/images/dummy_post2.jpg',
      'views': '450K',
      'badge': 'STYLE'
    },
    {
      'name': 'SYEIKH AHMAD',
      'role': 'Mufassir',
      'title': 'Sunat Muakkad',
      'description': 'Sunat muakkad wajib dijaga, ghair muakkad ringan dituntut.',
      'image': 'assets/images/dummy_post1.jpg',
      'views': '3.1M',
      'badge': 'USUL'
    },
    {
      'name': 'USTAZ DON',
      'role': 'Motivator',
      'title': 'Hijrah Journey',
      'description': 'Kisah Gua Thur dan strategi Rasulullah SAW semasa hijrah.',
      'image': 'assets/images/dummy_post2.jpg',
      'views': '1.8M',
      'badge': 'SIRAH'
    },
    {
      'name': 'PROF. HAMKA',
      'role': 'Pemikir',
      'title': 'Tasawuf Moden',
      'description': 'Jaga hati dari penyakit yang membinasakan amalan ibadah.',
      'image': 'assets/images/dummy_post1.jpg',
      'views': '950K',
      'badge': 'TASAWUF'
    },
    {
      'name': 'MUALLAF UK',
      'role': 'Inspirasi',
      'title': 'London Story',
      'description': 'Perjalanan mencari Tuhan di kota London yang penuh cabaran.',
      'image': 'assets/images/dummy_post2.jpg',
      'views': '2.5M',
      'badge': 'STORY'
    },
  ];

  String selectedFilter = 'For you';
  final List<String> filters = ['Following', 'For you', 'Fiqh', 'Sirah', 'Tasawuf'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) LATAR BELAKANG TRANSPARENT SUPAYA GAMBAR LANGIT NAMPAK
      backgroundColor: Colors.transparent, 
      
      body: Stack(
        children: [
          // ══════════════════════════════════════════════════════════════
          // 1. LATAR BELAKANG LANGIT (ASSETS)
          // ══════════════════════════════════════════════════════════════
          Positioned.fill(
            child: Image.asset(
              'assets/images/langit.png', // Pastikan fail ini wujud di assets
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback kalau gambar tak jumpa: Gradient Langit
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

          // 2. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                // ══════════════════════════════════════════════════════════════
                // HEADER - Search Bar + AutoCut
                // ══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            // Putih dengan opacity rendah supaya nampak langit sikit
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Search Islamic Content',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.search, color: Colors.grey[700]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Icon(Icons.auto_awesome, size: 24, color: Colors.white), // Icon Putih/Contrast
                          const SizedBox(height: 2),
                          Text(
                            'AutoCut',
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Teks Putih atas Langit
                              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // "All" HEADER
                // ══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.video_library, size: 28, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'All',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Teks Putih
                          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // FILTER TABS (Following, For you, etc)
                // ══════════════════════════════════════════════════════════════
                SizedBox(
                  height: 50,
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            // Kaca (Glassmorphism) untuk Tab
                            color: isSelected 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.3), 
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ❌ 2) MENU STATIK (Standard/Clips/Duration) TELAH DIPADAM DI SINI
                // Francois dah buang seperti titah Tuanku.

                // ══════════════════════════════════════════════════════════════
                // GRID CONTENT
                // ══════════════════════════════════════════════════════════════
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildVideoCard(items[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ══════════════════════════════════════════════════════════════
      // BOTTOM NAV BAR (Semi-Transparent Glass)
      // ══════════════════════════════════════════════════════════════
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Glass Effect
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5))),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Transparent supaya glass nampak
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey[700],
              selectedFontSize: 11,
              unselectedFontSize: 11,
              currentIndex: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cut),
                  label: 'Edit',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'Templates',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.folder_open),
                  label: 'Projects',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.person),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  label: 'Me',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // VIDEO CARD
  // ══════════════════════════════════════════════════════════════
  Widget _buildVideoCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            // Background Image
            Image.asset(
              item['image'],
              fit: BoxFit.cover,
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Top Badge + Views
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['badge'],
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          item['views'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // 3) SILVER KILAU PROFILE ROW
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: AssetImage(item['image']),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NAMA (SILVER)
                              _MetallicSilver(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // ROLE (SILVER PUDAR)
                              _MetallicSilver(
                                child: Text(
                                  item['role'],
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.verified,
                          color: Colors.blue[400],
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HELPER: METALLIC SILVER (KILAUAN PERAK)
// ══════════════════════════════════════════════════════════════
class _MetallicSilver extends StatelessWidget {
  final Widget child;
  const _MetallicSilver({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0E0E0), // Perak Terang
            Color(0xFFFFFFFF), // Putih Kilau
            Color(0xFFBDBDBD), // Perak Gelap
            Color(0xFFE0E0E0), // Perak Terang
          ],
          stops: [0.0, 0.4, 0.6, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
