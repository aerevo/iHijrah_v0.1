import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

// ✅ CODE STANDARD: AAA (CLEAN, CONSISTENT, PERFORMANCE OPTIMIZED)

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final List<Map<String, dynamic>> items;

  // 🎨 PALET WARNA "JEWEL TONES" (AAA STANDARD)
  // Warna yang lebih matang, dalam, dan eksklusif. Bukan warna marker pen.
  final List<Color> jewelColors = [
    Color(0xFF0F4C75), // Deep Sapphire
    Color(0xFF3282B8), // Frost Blue
    Color(0xFF5B4B8A), // Royal Amethyst
    Color(0xFF1B262C), // Midnight Slate
    Color(0xFF006A71), // Dark Teal
    Color(0xFFC70039), // Deep Ruby (Accent)
  ];

  @override
  void initState() {
    super.initState();
    items = _generateXYZGrid();
  }

  // ══════════════════════════════════════════════════════════════
  // 🧠 DATA GENERATOR
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateXYZGrid() {
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'GHAZALI', 'desc': 'Ilmu tanpa amal itu gila.', 'badge': 'ILMU'},
      {'name': 'RUMI', 'desc': 'Luka adalah tempat cahaya masuk.', 'badge': 'SUFI'},
      {'name': 'HIKMAH', 'desc': 'Sabar itu separuh iman.', 'badge': 'ADAB'},
      {'name': 'BUYA', 'desc': 'Takutlah mati sebelum hidup.', 'badge': 'JIWA'},
      {'name': 'IBNU SINA', 'desc': 'Tenang adalah ubat.', 'badge': 'MEDIK'},
      {'name': 'SYAFIE', 'desc': 'Masa ibarat pedang.', 'badge': 'MASA'},
      {'name': 'HAMKA', 'desc': 'Kecantikan ada pada adab.', 'badge': 'ADAB'},
      {'name': 'TARIM', 'desc': 'Adab dulu baru ilmu.', 'badge': 'YAMAN'},
    ];

    final List<Map<String, dynamic>> sourceMedia = [
      {'type': 'video', 'name': 'TADABBUR', 'title': 'Zikir', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'VIDEO'},
      {'type': 'image', 'name': 'ALAM FANA', 'title': 'Puncak', 'asset': 'assets/images/pokok_level5.png', 'badge': 'LVL 5'},
      {'type': 'image', 'name': 'USTAZ DON', 'title': 'Ranting', 'asset': 'assets/images/pokok_level3.png', 'badge': 'LVL 3'},
      {'type': 'video', 'name': 'HIJRAH', 'title': 'Agung', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'DOCU'},
    ];

    sourceMedia.shuffle(Random());

    List<Map<String, dynamic>> finalGrid = [];
    int quoteIndex = 0;
    int mediaIndex = 0;

    for (int i = 0; i < 18; i++) {
      int row = i ~/ 3;
      int col = i % 3;

      if (col == 2) {
        var item = Map<String, dynamic>.from(sourceMedia[mediaIndex % sourceMedia.length]);
        item['style'] = 'Z';
        finalGrid.add(item);
        mediaIndex++;
      } else {
        // Corak Selang-seli X/Y yang kemas
        bool isRowEven = (row % 2 == 0);
        String styleType = isRowEven ? (col == 0 ? 'X' : 'Y') : (col == 0 ? 'Y' : 'X');
        
        var item = Map<String, dynamic>.from(sourceQuotes[quoteIndex % sourceQuotes.length]);
        item['style'] = styleType;
        finalGrid.add(item);
        quoteIndex++;
      }
    }
    return finalGrid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dasar gelap untuk kontras maksimum
      body: Stack(
        children: [
          // 1. LATAR BELAKANG (Blurry & Darkened)
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              child: Image.asset(
                'assets/images/langit.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. KONTEN
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildModernFilterBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10, // Spacing konsisten
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7, // Ratio tinggi sikit untuk nampak elegan
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Panggil Tile yang betul
                      if (item['style'] == 'Z') return _buildTileMedia(item);
                      if (item['style'] == 'X') return _buildTileJewel(item, jewelColors[index % jewelColors.length]);
                      return _buildTileFrost(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🧊 TILE X: "JEWEL GLASS" (Warna Deep + Font Klasik)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileJewel(Map<String, dynamic> item, Color baseColor) {
    return Container(
      decoration: BoxDecoration(
        // Gradient Halus: Dari warna base ke warna sikit cerah
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.85),
            baseColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16), // Rounded Corner Moden
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1), // Border halus
        boxShadow: [
          // Shadow lembut gila (AAA Standard)
          BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.format_quote_rounded, color: Colors.white60, size: 16),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                item['desc'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Serif', // Klasik
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.3, // Jarak baris yang selesa dibaca
                  fontWeight: FontWeight.w500,
                  shadows: [
                    // Glow effect, bukan hard shadow
                    Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['name'].toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 7,
              letterSpacing: 1.0, // Luxury touch: Jarak huruf luas sikit
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ❄️ TILE Y: "ARCTIC FROST" (Ais Sebenar - Clean & Premium)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileFrost(Map<String, dynamic> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur belakang (Real Glass Effect)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Transparen sangat tinggi
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), // Border ais
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  // TULISAN SILVER "METALLIC LOOK" TANPA STACKING KASAR
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE0E0E0), Colors.white, Color(0xFFB0B0B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      item['desc'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, // Fallback
                        fontSize: 10,
                        fontWeight: FontWeight.w700, // Tebal utk nampak chrome
                        fontFamily: 'Sans', // Moden kontras dgn Tile X
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Container(
                width: 20, height: 1, color: Colors.white30, // Garisan hiasan minimalis
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              Text(
                item['name'],
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 7, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🎥 TILE Z: MEDIA (Clean & Immersive)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileMedia(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item['asset'],
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
            ),
            // Gradient Overlay supaya tulisan nampak
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.transparent, Colors.black87],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            if (item['type'] == 'video')
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 32)),
            
            Positioned(
              bottom: 8, left: 8, right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text(item['name'], style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UI COMPONENTS (FILTER & NAV) - GLASS STYLE
  // ══════════════════════════════════════════════════════════════
  Widget _buildModernFilterBar() {
    final filters = ['For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];
    String selected = 'For you'; // (State dummy utk UI shj)

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0; // Contoh
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: Text(
              filters[index],
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home_filled, color: Colors.white),
              Icon(Icons.explore_outlined, color: Colors.white54),
              Icon(Icons.add_circle_outline, color: Colors.white, size: 40),
              Icon(Icons.favorite_border, color: Colors.white54),
              Icon(Icons.person_outline, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
