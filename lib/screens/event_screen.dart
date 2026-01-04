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
    Colors.deepPurple[600]!, // 1. Deep Purple
    Colors.orange[800]!,     // 2. Vibrant Orange
    Colors.teal[600]!,       // 3. Electric Teal
    Colors.redAccent[700]!,  // 4. Hot Red
    Colors.indigo[600]!,     // 5. Indigo
    Colors.pink[600]!,       // 6. Pink
    Colors.blue[700]!,       // 7. Royal Blue
  ];

  @override
  void initState() {
    super.initState();
    items = _generateXYZGrid();
  }

  // ══════════════════════════════════════════════════════════════
  // 🧠 GENERATOR GRID X-Y-Z (KEKAL 3 LAJUR)
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateXYZGrid() {
    // SUMBER QUOTE (X & Y)
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'GHAZALI', 'desc': 'Ilmu tanpa amal itu gila.', 'badge': 'ILMU'},
      {'name': 'RUMI', 'desc': 'Luka adalah tempat cahaya masuk.', 'badge': 'SUFI'},
      {'name': 'HIKMAH', 'desc': 'Sabar itu separuh iman.', 'badge': 'ADAB'},
      {'name': 'BUYA', 'desc': 'Takutlah mati sebelum hidup.', 'badge': 'JIWA'},
      {'name': 'IBNU SINA', 'desc': 'Tenang adalah ubat.', 'badge': 'MEDIK'},
      {'name': 'SYAFIE', 'desc': 'Masa ibarat pedang.', 'badge': 'MASA'},
      {'name': 'HAMKA', 'desc': 'Kecantikan ada pada adab.', 'badge': 'ADAB'},
      {'name': 'TARIM', 'desc': 'Adab dulu baru ilmu.', 'badge': 'YAMAN'},
      {'name': 'NABI', 'desc': 'Berkata baik atau diam.', 'badge': 'HADIS'},
      {'name': 'ALI', 'desc': 'Lidahmu adalah singamu.', 'badge': 'AKHLAK'},
    ];

    // SUMBER MEDIA (Z) - RANDOM
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
                          setState(() { selectedFilter = filters[index]; });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
                      childAspectRatio: 0.65, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      // PILIH BUILDER IKUT STYLE
                      if (item['style'] == 'Z') {
                        return _buildTileZ(item); // Media (Kekal)
                      } 
                      else if (item['style'] == 'X') {
                        // ✅ TILE X: WARNA FUNKY (70% Opacity)
                        final Color myColor = funkyColors[index % funkyColors.length];
                        return _buildTileX(item, myColor); 
                      }
                      else {
                        // ✅ TILE Y: GLASS TRANSPAREN (Kekal)
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
  // ✅ TILE X: FUNKY COLORS (70% OPACITY) | TEKS ITALIK | BAYANG
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileX(Map<String, dynamic> item, Color bgColor) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // ✅ UBAH DI SINI: OPACITY 70% (0.7)
              color: bgColor.withOpacity(0.7), 
              borderRadius: BorderRadius.circular(12),
              // Shadow lembut pada kad
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: Offset(2, 2))
              ], 
            ),
            padding: const EdgeInsets.all(6),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Petik
                const Icon(Icons.format_quote, color: Colors.white54, size: 16),
                const SizedBox(height: 2),
                
                // Teks Utama (Italik + Bayang)
                Text(
                  item['desc'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white, // Putih
                    fontSize: 10, 
                    fontWeight: FontWeight.w700, 
                    fontStyle: FontStyle.italic, // ✅ ITALIK
                    // Bayang Gelap
                    shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(1, 1))],
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildBottomCaption(item),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ TILE Y: GLASS TRANSPAREN (ASAL) + TULISAN SILVER
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileY(Map<String, dynamic> item) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // Glass Transparen 5%
              color: Colors.white.withOpacity(0.05), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              item['desc'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE0E0E0), // Silver
                fontSize: 10,
                fontWeight: FontWeight.w600, 
                shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildBottomCaption(item),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TILE Z: MEDIA (VIDEO/GAMBAR) - KEKAL (JGN USIK)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileZ(Map<String, dynamic> item) {
    final String heroTag = 'hero_z_${item['name']}_${Random().nextInt(1000)}';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FeedDetailScreen(item: item, heroTag: heroTag)));
      },
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // GAMBAR / VIDEO THUMBNAIL
                        Image.asset(
                          item['asset'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                        ),
                        
                        // GRADIENT BAWAH
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                          ),
                        ),

                        // CAPTION PUTIH HALUS
                        Positioned(
                          bottom: 6, left: 6, right: 6,
                          child: Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 9, 
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // VIDEO ICON
                        if (item['type'] == 'video')
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle
                              ),
                              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Caption User Luar
              _buildBottomCaption(item),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPER CAPTION LUAR
  // ══════════════════════════════════════════════════════════════
  Widget _buildBottomCaption(Map<String, dynamic> item) {
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
            ),
            child: CircleAvatar(
              radius: 10, backgroundColor: Colors.white.withOpacity(0.2),
              // Z guna asset, X & Y guna icon
              backgroundImage: (item['style'] == 'Z' && item['asset'] != '') ? AssetImage(item['asset']) : null,
              child: (item['style'] != 'Z') ? const Icon(Icons.person, size: 12, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, shadows: textShadows),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if(item['style'] != 'Z') 
                Text(
                  item['badge'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 7, fontWeight: FontWeight.w400, shadows: textShadows),
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

// ══════════════════════════════════════════════════════════════
// DETAIL SCREEN (UNTUK Z - MEDIA)
// ══════════════════════════════════════════════════════════════
class FeedDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String heroTag;

  const FeedDetailScreen({Key? key, required this.item, required this.heroTag}) : super(key: key);

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: AspectRatio(
                aspectRatio: 9/16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(widget.item['asset'], fit: BoxFit.cover),
                    if (widget.item['type'] == 'video')
                      GestureDetector(
                        onTap: () => setState(() => isPlaying = !isPlaying),
                        child: Center(
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow, 
                            color: Colors.white, size: 60
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 16, child: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white))),
        ],
      ),
    );
  }
}
