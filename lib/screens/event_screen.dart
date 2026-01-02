import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Panggil fail emas original
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // Data Bersepadu (Menggunakan aset dummy_post1 dan dummy_post2)
  final List<Map<String, dynamic>> items = [
    {
      'name': 'USTAZ DON',
      'role': 'Pendakwah',
      'quote': 'Hijrah itu pengorbanan.',
      'description': 'Kisah detik cemas di Gua Thur dan strategi Rasulullah SAW.',
      'image': 'assets/images/dummy_post1.jpg',
      'stats': '1.2M Views'
    },
    {
      'name': 'IMAM SYAFII',
      'role': 'Ulama',
      'quote': 'Ilmu itu cahaya.',
      'description': 'Nasihat tentang menuntut ilmu di usia muda.',
      'image': 'assets/images/dummy_post2.jpg',
      'stats': '890K Likes'
    },
    {
      'name': 'DR. ZUL',
      'role': 'Ilmuwan',
      'quote': 'Sedekah Subuh.',
      'description': 'Rahsia pintu rezeki yang jarang orang ketahui.',
      'image': 'assets/images/dummy_post1.jpg',
      'stats': '450K Shares'
    },
    {
      'name': 'MUALLAF',
      'role': 'Inspirasi',
      'quote': 'Hidayah Allah.',
      'description': 'Perjalanan mencari Tuhan di kota London.',
      'image': 'assets/images/dummy_post2.jpg',
      'stats': '2.1M Views'
    },
    {
      'name': 'AL-GHAZALI',
      'role': 'Sufi',
      'quote': 'Jaga hatimu.',
      'description': 'Penyakit hati yang membinasakan amalan.',
      'image': 'assets/images/dummy_post1.jpg',
      'stats': 'Vintage'
    },
  ];

  // State untuk Hero Selection (Bahagian Atas)
  int _selectedHeroIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Base
      body: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════════════════════════════════
            // PART 1: WINTER FASHION CATALOG (ATAS - 60%)
            // ══════════════════════════════════════════════════════════════
            Expanded(
              flex: 6,
              child: Container(
                color: const Color(0xFFF1F5F9), // Ice White Background
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER TITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "KATALOG ILMU",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.snowing, color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ),

                    // HERO SECTION (GAMBAR BESAR)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Main Hero Image
                            Expanded(
                              flex: 3,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Container(
                                  key: ValueKey<int>(_selectedHeroIndex),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    image: DecorationImage(
                                      image: AssetImage(items[_selectedHeroIndex]['image']),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(5, 10),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.8),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items[_selectedHeroIndex]['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                            fontFamily: 'Playfair Display', // Elegant font
                                          ),
                                        ),
                                        Text(
                                          items[_selectedHeroIndex]['description'],
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Vertical Side Selection (Grid Kecil)
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(items.length > 4 ? 4 : items.length, (index) {
                                  bool isSelected = index == _selectedHeroIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedHeroIndex = index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: isSelected 
                                            ? Border.all(color: Colors.black, width: 2) 
                                            : null,
                                        image: DecorationImage(
                                          image: AssetImage(items[index]['image']),
                                          fit: BoxFit.cover,
                                          colorFilter: isSelected 
                                              ? null 
                                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // ══════════════════════════════════════════════════════════════
            // PART 2: CYBERPUNK WHEEL SELECTOR (BAWAH - 40%)
            // ══════════════════════════════════════════════════════════════
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F172A), // Deep Navy
                      Color(0xFF020617), // Black
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    )
                  ]
                ),
                child: Stack(
                  children: [
                    // The Wheel
                    ListWheelScrollView.useDelegate(
                      itemExtent: 80, // Tinggi setiap item
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(), // SNAP EFFECT
                      onSelectedItemChanged: (index) {
                        // Optional: Kalau nak sync bawah ke atas, uncomment ni
                        // setState(() { _selectedHeroIndex = index; });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: items.length,
                        builder: (context, index) {
                          final item = items[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // KIRI: KUOTA / QUOTE
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '"${item['quote']}"',
                                    textAlign: TextAlign.end,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Colors.cyanAccent.withOpacity(0.8),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      shadows: [
                                        BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 10)
                                      ]
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // TENGAH: PROFIL GAMBAR (GLOWING)
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.6),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage(item['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // KANAN: BIODATA
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MetallicGold(
                                        child: Text(
                                          item['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item['role'].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Fading Overlay (Atas Bawah Roda) supaya nampak 3D
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0F172A).withOpacity(1.0),
                              const Color(0xFF0F172A).withOpacity(0.0),
                              const Color(0xFF0F172A).withOpacity(0.0),
                              const Color(0xFF020617).withOpacity(1.0),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Center Highlight Indicator (Garis Halus)
                    Center(
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.white.withOpacity(0.1), 
                              width: 1
                            ),
                          ),
                          color: Colors.white.withOpacity(0.02),
                        ),
                      ),
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
