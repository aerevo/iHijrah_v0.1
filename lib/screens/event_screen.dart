import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

// NOTA: Fail metallic_gold.dart TIDAK DIPERLUKAN untuk design ini.

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final List<Map<String, dynamic>> items;

  // 🎨 PALET WARNA "FUNKY" (KHAS UNTUK TILE X SAHAJA)
  final List<Color> funkyColors = [
    Colors.deepPurple[600]!, // 1. Deep Purple (Mewah)
    Colors.orange[800]!,     // 2. Vibrant Orange (Tenaga)
    Colors.teal[600]!,       // 3. Electric Teal (Moden)
    Colors.redAccent[700]!,  // 4. Hot Red (Berani)
    Colors.indigo[600]!,     // 5. Indigo (Eksklusif)
    Colors.pink[600]!,       // 6. Pink (Funky)
    Colors.blue[700]!,       // 7. Royal Blue (Asal)
  ];

  @override
  void initState() {
    super.initState();
    items = _generateXYZGrid();
  }

  // ══════════════════════════════════════════════════════════════
  // 🧠 GENERATOR GRID X-Y-Z
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateXYZGrid() {
    // SUMBER QUOTE (X & Y)
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'IMAM GHAZALI', 'desc': 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.', 'badge': 'ILMU'},
      {'name': 'JALALUDDIN RUMI', 'desc': 'Luka adalah tempat di mana cahaya memasukimu.', 'badge': 'SUFI'},
      {'name': 'IBNU QAYYIM', 'desc': 'Dunia ini ibarat bayang-bayang, kejar dia lari, paling dia ikut.', 'badge': 'JIWA'},
      {'name': 'BUYA HAMKA', 'desc': 'Jangan takut jatuh, kerana yang tidak pernah memanjatlah yang tidak pernah jatuh.', 'badge': 'MOTIVASI'},
      {'name': 'IBNU SINA', 'desc': 'Kepanikan adalah separuh penyakit, ketenangan adalah separuh ubat.', 'badge': 'MEDIK'},
      {'name': 'IMAM SYAFIE', 'desc': 'Masa ibarat pedang, jika kau tidak memotongnya, ia memotongmu.', 'badge': 'MASA'},
      {'name': 'SAYIDINA ALI', 'desc': 'Lidahmu adalah singamu, jika kau menjaganya ia menjagamu.', 'badge': 'AKHLAK'},
      {'name': 'TARIM', 'desc': 'Adab itu lebih tinggi daripada ilmu.', 'badge': 'ADAB'},
      {'name': 'HIKMAH', 'desc': 'Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain.', 'badge': 'BAKTI'},
    ];

    // SUMBER MEDIA (Z) - RANDOM
    final List<Map<String, dynamic>> sourceMedia = [
      {'type': 'video', 'name': 'ALAM SEMESTA', 'title': 'Pokok Berzikir', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'VIDEO', 'duration': '0:45'},
      {'type': 'image', 'name': 'USTAZ AZHAR', 'title': 'Sunat Ab\'ad', 'asset': 'assets/images/pokok_level3.png', 'badge': 'FIQH'},
      {'type': 'video', 'name': 'JEJAK RASUL', 'title': 'Gua Hira', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'DOCU', 'duration': '2:30'},
      {'type': 'image', 'name': 'DR. MAZA', 'title': 'Hukum Semasa', 'asset': 'assets/images/pokok_level4.png', 'badge': 'FATWA'},
      {'type': 'image', 'name': 'ALAM FANA', 'title': 'Puncak', 'asset': 'assets/images/pokok_level5.png', 'badge': 'LVL 5'},
    ];

    // Kocok Media supaya Z sentiasa random
    sourceMedia.shuffle(Random());

    List<Map<String, dynamic>> finalGrid = [];
    int quoteIndex = 0;
    int mediaIndex = 0;

    // GENERATE 18 ITEM (6 Baris x 3 Lajur)
    for (int i = 0; i < 18; i++) {
      int row = i ~/ 3; // Baris ke berapa (0, 1, 2...)
      int col = i % 3;  // Lajur ke berapa (0, 1, 2)

      // LOGIK X Y Z
      // COL 2 (Lajur ke-3) SENTIASA Z (Media)
      if (col == 2) {
        var item = Map<String, dynamic>.from(sourceMedia[mediaIndex % sourceMedia.length]);
        item['style'] = 'Z'; // Tagging Style
        finalGrid.add(item);
        mediaIndex++;
      } 
      else {
        // COL 0 & 1 (Lajur 1 & 2) - Bertukar X dan Y
        // Baris Genap (0, 2...): X Y
        // Baris Ganjil (1, 3...): Y X
        
        bool isRowEven = (row % 2 == 0);
        String styleType;

        if (isRowEven) {
          styleType = (col == 0) ? 'X' : 'Y';
        } else {
          styleType = (col == 0) ? 'Y' : 'X';
        }

        var item = Map<String, dynamic>.from(sourceQuotes[quoteIndex % sourceQuotes.length]);
        item['type'] = 'quote';
        item['style'] = styleType; // Tagging Style X atau Y
        finalGrid.add(item);
        quoteIndex++;
      }
    }
    return finalGrid;
  }

  String selectedFilter = 'For you';
  final List<String> filters = ['For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), 
      
      body: Stack(
        children: [
          // 1. LATAR BELAKANG LANGIT
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              child: Image.asset(
                'assets/images/langit.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF141E30), Color(0xFF243B55)],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. KONTEN
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // FILTER TABS
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
                          setState(() { selectedFilter = filters[index]; });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // GRID UTAMA
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 LAJUR
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,   
                      childAspectRatio: 0.7, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      // PILIH BUILDER IKUT STYLE
                      if (item['style'] == 'Z') {
                        return _buildTileZ(item); // Media (Kekal)
                      } 
                      else if (item['style'] == 'X') {
                        // ✅ TILE X: GUNA WARNA FUNKY (Looping)
                        final Color myColor = funkyColors[index % funkyColors.length];
                        return _buildQuoteTileX(item, myColor); 
                      }
                      else {
                        // ✅ TILE Y: GLASS TRANSPAREN + SILVER (Kembali Asal)
                        return _buildTileY(item);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
             BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
             BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
             BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
             BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
             BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ]
      )
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ TILE X: FUNKY COLORS + TEKS PUTIH BERBAYANG
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuoteTileX(Map<String, dynamic> item, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor, // Warna Funky
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // IKON
          const Icon(Icons.format_quote_rounded, color: Colors.white70, size: 40),
          
          // TEKS
          Expanded(
            child: Center(
              child: Text(
                item['desc'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(2, 2)),
                  ],
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          // NAMA
          Text(
            "- ${item['name']} -",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(1, 1))],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ TILE Y: SILVER | GLASS | GAYA ASAL (JGN USIK)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileY(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        // Glass Transparen (Putih 10%)
        color: Colors.white.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                item['desc'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC0C0C0), // Silver
                  fontSize: 14, // Kecil sikit dari X
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3, offset: Offset(1, 1))],
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['name'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TILE Z: MEDIA (VIDEO/GAMBAR) - KEKAL (JGN USIK)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileZ(Map<String, dynamic> item) {
    bool isVideo = item['type'] == 'video';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
              child: Image.asset(
                item['asset'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
              ),
            ),
            
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVideo ? Colors.redAccent : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['badge'] ?? (isVideo ? 'VIDEO' : 'IMG'),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (isVideo && item['duration'] != null)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: Text(item['duration'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),

            if (isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.black87, size: 32),
                ),
              ),
            
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                  ),
                  Text(
                    item['name'],
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, shadows: const [Shadow(blurRadius: 2, color: Colors.black)]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
