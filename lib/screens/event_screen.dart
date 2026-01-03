import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math'; // Perlu untuk Shuffle

// ✅ INTEGRASI: Fail emas
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // PALET WARNA KUOTA (Pink, Biru, Hijau)
  final List<Color> quoteColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Biru
    const Color(0xFF00E676), // Hijau
  ];

  late final List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    items = _generateCheckerboardData();
  }

  // ══════════════════════════════════════════════════════════════
  // 🧠 LOGIK PENYUSUNAN PINTAR (SHUFFLE & SORT)
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateCheckerboardData() {
    // 1. BEKAS SUMBER: QUOTES (Tetap)
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'GHAZALI', 'title': 'Nasihat', 'description': 'Ilmu tanpa amal itu gila.', 'badge': 'ILMU'},
      {'name': 'RUMI', 'title': 'Cinta', 'description': 'Apa yang kau cari, sedang mencarimu.', 'badge': 'SUFI'},
      {'name': 'HIKMAH', 'title': 'Sabar', 'description': 'Sabar itu separuh iman.', 'badge': 'ADAB'},
      {'name': 'BUYA', 'title': 'Hidup', 'description': 'Takutlah mati sebelum hidup.', 'badge': 'JIWA'},
      {'name': 'IBNU SINA', 'title': 'Sihat', 'description': 'Tenang adalah ubat.', 'badge': 'MEDIK'},
      {'name': 'SYAFIE', 'title': 'Masa', 'description': 'Masa ibarat pedang.', 'badge': 'MASA'},
      {'name': 'HAMKA', 'title': 'Jiwaku', 'description': 'Kecantikan abadi ada pada adab.', 'badge': 'ADAB'},
      {'name': 'TARIM', 'title': 'Ilmu', 'description': 'Adab dulu baru ilmu.', 'badge': 'YAMAN'},
    ];

    // 2. BEKAS SUMBER: MEDIA (Gambar & Video bercampur)
    final List<Map<String, dynamic>> sourceMedia = [
      {'type': 'video', 'name': 'TADABBUR', 'title': 'Zikir', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'VIDEO', 'duration': '0:45'},
      {'type': 'image', 'name': 'ALAM FANA', 'title': 'Puncak', 'asset': 'assets/images/pokok_level5.png', 'badge': 'LVL 5'},
      {'type': 'image', 'name': 'USTAZ DON', 'title': 'Ranting', 'asset': 'assets/images/pokok_level3.png', 'badge': 'LVL 3'},
      {'type': 'video', 'name': 'HIJRAH', 'title': 'Agung', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'DOCU', 'duration': '2:30'},
      {'type': 'image', 'name': 'HAMKA', 'title': 'Mula', 'asset': 'assets/images/pokok_level2.png', 'badge': 'LVL 2'},
      {'type': 'image', 'name': 'DR. MAZA', 'title': 'Syariah', 'asset': 'assets/images/pokok_level4.png', 'badge': 'LVL 4'},
      {'type': 'image', 'name': 'UK STORY', 'title': 'London', 'asset': 'assets/images/dummy_post1.jpg', 'badge': 'STORY'},
      {'type': 'image', 'name': 'SITI', 'title': 'Fiqh', 'asset': 'assets/images/dummy_post2.jpg', 'badge': 'FIQH'},
    ];

    // 3. KOCOK (SHUFFLE) MEDIA SUPAYA POSISI RANDOM
    // Video dan gambar akan bertukar tempat setiap kali app buka
    sourceMedia.shuffle(Random());

    List<Map<String, dynamic>> finalGrid = [];
    int quoteIndex = 0;
    int mediaIndex = 0;

    // 4. SUSUN KE DALAM GRID 3 LAJUR (PATTERN: X O X, O X O)
    // Total item = 15 (contoh)
    for (int i = 0; i < 15; i++) {
      if (i % 2 == 0) {
        // 🟥 POSISI X (GENAP) -> WAJIB QUOTE (BERWARNA)
        // Kitar semula quote jika habis
        var quote = Map<String, dynamic>.from(sourceQuotes[quoteIndex % sourceQuotes.length]);
        
        // Tetapkan jenis & warna ikut urutan (Pink->Biru->Hijau)
        quote['type'] = 'quote';
        quote['color'] = quoteColors[quoteIndex % quoteColors.length];
        
        finalGrid.add(quote);
        quoteIndex++;
      } else {
        // ⭕ POSISI O (GANJIL) -> WAJIB MEDIA (RANDOM)
        // Ambil dari senarai media yang dah dikocok tadi
        var media = Map<String, dynamic>.from(sourceMedia[mediaIndex % sourceMedia.length]);
        
        // Pastikan tiada warna tint (biar original)
        media['color'] = Colors.transparent; 
        
        finalGrid.add(media);
        mediaIndex++;
      }
    }

    return finalGrid;
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

          // 2. KONTEN
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // FILTER TABS
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

                // GRID UTAMA
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.58, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // PANGGIL BUILDER YANG SESUAI
                      if (item['type'] == 'quote') {
                        return _buildQuoteTile(item); // X (Berwarna)
                      } else {
                        return _buildMediaTile(item); // O (Media Random)
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
  // TILE X: KUOTA (TRANSPARENT + WARNA CAIR)
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuoteTile(Map<String, dynamic> item) {
    Color baseColor = item['color']; // Pink/Biru/Hijau

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // Kaca berwarna (Opacity rendah supaya nampak langit)
              color: baseColor.withOpacity(0.25), 
              borderRadius: BorderRadius.circular(12),
              // Border sedikit terang ikut warna tema
              border: Border.all(color: baseColor.withOpacity(0.6), width: 1.2),
              boxShadow: [
                BoxShadow(color: baseColor.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ISI TEKS
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    item['description'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      // Shadow supaya boleh baca atas warna
                      shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // BADGE KECIL
                Positioned(
                  top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.9), // Warna solid
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
        
        // CAPTION BAWAH
        _buildBottomCaption(item, isQuote: true),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TILE O: MEDIA (GAMBAR/VIDEO - RANDOM POSITION)
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
                  
                  // BADGE HITAM
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

                  // VIDEO ICON (JIKA VIDEO)
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

        // CAPTION BAWAH
        _buildBottomCaption(item, isQuote: false),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPER CAPTION
  // ══════════════════════════════════════════════════════════════
  Widget _buildBottomCaption(Map<String, dynamic> item, {required bool isQuote}) {
    // Shadow teks sentiasa ada untuk konsistensi
    const textShadows = [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))];

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
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 9, 
                    fontWeight: FontWeight.w900,
                    shadows: textShadows,
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
                    shadows: textShadows,
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
