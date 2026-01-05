import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

// ✅ Francois mengekalkan integriti fail. 
// MetallicGold tidak dipakai di sini buat masa ini tetapi import dikekalkan jika Kapten mahu panggil semula.
// import '../widgets/metallic_gold.dart'; 

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final List<Map<String, dynamic>> items;

  // 🎨 PALET WARNA "FUNKY" (KHAS UNTUK TILE X SAHAJA)
  final List<Color> funkyColors = [
    Colors.deepPurple[600]!,
    Colors.orange[800]!,
    Colors.teal[600]!,
    Colors.redAccent[700]!,
    Colors.indigo[600]!,
    Colors.pink[600]!,
    Colors.blue[700]!,
  ];

  @override
  void initState() {
    super.initState();
    items = _generateXYZGrid();
  }

  // ══════════════════════════════════════════════════════════════
  // 🧠 GENERATOR GRID X-Y-Z (3 LAJUR)
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateXYZGrid() {
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'GHAZALI', 'desc': 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.', 'badge': 'ILMU'},
      {'name': 'RUMI', 'desc': 'Luka adalah tempat di mana cahaya memasukimu.', 'badge': 'SUFI'},
      {'name': 'HIKMAH', 'desc': 'Sabar itu separuh daripada iman.', 'badge': 'ADAB'},
      {'name': 'BUYA', 'desc': 'Takutlah mati sebelum hidup.', 'badge': 'JIWA'},
      {'name': 'IBNU SINA', 'desc': 'Kepanikan adalah separuh penyakit.', 'badge': 'MEDIK'},
      {'name': 'SYAFIE', 'desc': 'Masa ibarat pedang.', 'badge': 'MASA'},
      {'name': 'HAMKA', 'desc': 'Kecantikan ada pada adab.', 'badge': 'ADAB'},
      {'name': 'TARIM', 'desc': 'Adab dulu baru ilmu.', 'badge': 'YAMAN'},
      {'name': 'NABI', 'desc': 'Berkata baik atau diam.', 'badge': 'HADIS'},
      {'name': 'ALI', 'desc': 'Lidahmu adalah singamu.', 'badge': 'AKHLAK'},
    ];

    final List<Map<String, dynamic>> sourceMedia = [
      {'type': 'video', 'name': 'TADABBUR', 'title': 'Zikir Alam', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'VIDEO', 'duration': '0:45'},
      {'type': 'image', 'name': 'ALAM FANA', 'title': 'Puncak', 'asset': 'assets/images/pokok_level5.png', 'badge': 'LVL 5'},
      {'type': 'image', 'name': 'USTAZ DON', 'title': 'Ranting', 'asset': 'assets/images/pokok_level3.png', 'badge': 'LVL 3'},
      {'type': 'video', 'name': 'HIJRAH', 'title': 'Agung', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'DOCU', 'duration': '2:30'},
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

  String selectedFilter = 'For you';
  final List<String> filters = ['For you', 'Fiqh', 'Sirah', 'Tasawuf', 'Video', 'Quote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. LATAR BELAKANG
          Positioned.fill(
            child: Image.asset(
              'assets/images/langit.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF87CEEB)),
            ),
          ),

          // 2. KONTEN UTAMA
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
                        onTap: () => setState(() => selectedFilter = filters[index]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                      if (item['style'] == 'Z') return _buildTileZ(item);
                      if (item['style'] == 'X') return _buildTileX(item, funkyColors[index % funkyColors.length]);
                      return _buildTileY_ArcticIce(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // BOTTOM NAVIGATION BAR
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
  // ✅ TILE X: FUNKY (70% OPACITY) | FONT SERIF ITALIK
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileX(Map<String, dynamic> item, Color bgColor) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.format_quote, color: Colors.white54, size: 18),
                Text(
                  item['desc'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 3, offset: const Offset(1, 1))],
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        _buildBottomCaption(item),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ TILE Y: ARCTIC ICE (KELABU BERBELANG + TULISAN 3D STACKED)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileY_ArcticIce(Map<String, dynamic> item) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: const Color(0xFFD1D9E6), // Ice Grey
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: CustomPaint(painter: IceStripePainter())),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Layer 1 (Depth)
                        Transform.translate(
                          offset: const Offset(1.5, 1.5),
                          child: Text(
                            item['desc'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.indigo[900]?.withOpacity(0.5)),
                          ),
                        ),
                        // Layer 2 (Body)
                        Transform.translate(
                          offset: const Offset(0.5, 0.5),
                          child: Text(
                            item['desc'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.cyanAccent),
                          ),
                        ),
                        // Layer 3 (Surface Silver)
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE0E0E0), Colors.white, Color(0xFFBDBDBD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            item['desc'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomCaption(item),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ TILE Z: MEDIA (Kekal Hero & Video Icon)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTileZ(Map<String, dynamic> item) {
    final String heroTag = 'hero_z_${item['name']}_${Random().nextInt(1000)}';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeedDetailScreen(item: item, heroTag: heroTag))),
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(item['asset'], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black)),
                      if (item['type'] == 'video') const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30)),
                      Positioned(bottom: 5, left: 5, child: Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
              _buildBottomCaption(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCaption(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 6, backgroundColor: Colors.white30, child: Icon(Icons.person, size: 8, color: Colors.white)),
          const SizedBox(width: 4),
          Expanded(child: Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// 🎨 PAINTER UNTUK TEXTURE AIS
class IceStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 1.2;
    for (double i = -size.height; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
// DETAIL SCREEN (UNTUK VIDEO/IMAGE)
// ══════════════════════════════════════════════════════════════
class FeedDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final String heroTag;
  const FeedDetailScreen({Key? key, required this.item, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: Hero(tag: heroTag, child: Image.asset(item['asset'], fit: BoxFit.contain))),
          Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }
}
