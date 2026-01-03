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
      'asset': 'assets/videos/tree_v1.mp4', 
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
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
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
                // GRID KONTEN (AAA GRADE - CAPCUT STYLE)
                // ═══════════════════════════════════════════════════
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.68, // Optimized untuk caption luar
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCapCutStyleCard(item);
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
  // 🎯 CAPCUT STYLE CARD (AAA GRADE)
  // Caption LUAR card, Media BERSIH dalam card
  // ══════════════════════════════════════════════════════════════
  Widget _buildCapCutStyleCard(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════════════
        // 1. MEDIA CARD (Clean, Badge & Views sahaja)
        // ═══════════════════════════════════════════════════════
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
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
                  // Background berdasarkan jenis
                  if (item['type'] == 'video')
                    _buildVideoBackground(item)
                  else if (item['type'] == 'quote')
                    _buildQuoteBackground(item)
                  else
                    _buildImageBackground(item),

                  // Gradient Overlay (lebih subtle)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Badge & Views (Top)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(item['type']),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            item['badge'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Views
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Duration (jika video)
                  if (item['type'] == 'video')
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['duration'] ?? '0:00',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Play Icon (jika video) - Centered
                  if (item['type'] == 'video')
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ═══════════════════════════════════════════════════════
        // 2. CAPTION AREA (LUAR CARD - CapCut Style)
        // ═══════════════════════════════════════════════════════
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: item['type'] != 'video' && item['asset'].isNotEmpty
                      ? AssetImage(item['asset'])
                      : null,
                  child: item['type'] == 'video' || item['asset'].isEmpty
                      ? const Icon(Icons.person, size: 14, color: Colors.white70)
                      : null,
                ),
              ),

              const SizedBox(width: 8),

              // Username & Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username (Metallic Silver Effect)
                    _MetallicSilver(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Title
                    Text(
                      item['title'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
  // BACKGROUND BUILDERS (Cleaner)
  // ══════════════════════════════════════════════════════════════

  Widget _buildVideoBackground(Map<String, dynamic> item) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(
          Icons.videocam_rounded,
          color: Colors.white.withOpacity(0.2),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildQuoteBackground(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item['color'] ?? Colors.blueAccent,
            (item['color'] as Color).withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.format_quote, color: Colors.white60, size: 28),
          const SizedBox(height: 12),
          Text(
            item['description'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: 0.2,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImageBackground(Map<String, dynamic> item) {
    return Image.asset(
      item['asset'],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPER: Badge Color berdasarkan type
  // ══════════════════════════════════════════════════════════════
  Color _getBadgeColor(String type) {
    switch (type) {
      case 'video':
        return Colors.redAccent;
      case 'quote':
        return Colors.deepPurpleAccent;
      default:
        return Colors.black87;
    }
  }
}

// ══════════════════════════════════════════════════════════════
// METALLIC SILVER EFFECT (Kekalkan)
// ══════════════════════════════════════════════════════════════
class _MetallicSilver extends StatelessWidget {
  final Widget child;
  const _MetallicSilver({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0E0E0),
          Color(0xFFFFFFFF),
          Color(0xFFBDBDBD),
          Color(0xFFE0E0E0)
        ],
        stops: [0.0, 0.4, 0.6, 1.0],
      ).createShader(bounds),
      child: child,
    );
  }
}
