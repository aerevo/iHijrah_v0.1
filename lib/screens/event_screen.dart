import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Panggil fail emas original (Walaupun tak guna, kita simpan untuk masa depan)
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
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Search Islamic Content',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.search, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Icon(Icons.auto_awesome, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        'AutoCut',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
                  Icon(Icons.video_library, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'All',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
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

            // ══════════════════════════════════════════════════════════════
            // FILTER OPTIONS (Standard, Clips, Duration)
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.tune, color: Colors.grey[700]),
                  const SizedBox(width: 16),
                  _buildFilterChip('💎 Standard', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Clips', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Duration', false),
                ],
              ),
            ),

            // ══════════════════════════════════════════════════════════════
            // GRID CONTENT (2 Columns - CapCut Style)
            // ══════════════════════════════════════════════════════════════
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.62, // Ratio untuk card height
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

      // ══════════════════════════════════════════════════════════════
      // BOTTOM NAV BAR (CapCut Style)
      // ══════════════════════════════════════════════════════════════
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.cut),
              label: 'Edit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Templates',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.person),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
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
    );
  }

  // ══════════════════════════════════════════════════════════════
  // VIDEO CARD (CapCut Grid Style)
  // ══════════════════════════════════════════════════════════════
  Widget _buildVideoCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    Colors.black.withOpacity(0.7),
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
                  // Badge
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
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Views
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 10),
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
                    // Title
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
                    // Description
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
                    // Profile Row
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
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['role'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

  // ══════════════════════════════════════════════════════════════
  // FILTER CHIP BUILDER
  // ══════════════════════════════════════════════════════════════
  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.blue[700] : Colors.grey[700],
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
