import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math'; // Untuk Shuffle

// ✅ INTEGRASI: Fail emas
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // PALET WARNA BADGE
  final List<Color> badgeColors = [
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
  // 🧠 DATA GENERATOR (CHECKERBOARD LOGIC)
  // ══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _generateCheckerboardData() {
    final List<Map<String, dynamic>> sourceQuotes = [
      {'name': 'GHAZALI', 'title': 'Nasihat', 'description': 'Ilmu tanpa amal itu gila. Amal tanpa ilmu itu sia-sia. Jangan jadi lilin yang menerangi orang lain tapi membakar diri sendiri.', 'badge': 'ILMU'},
      {'name': 'RUMI', 'title': 'Cinta', 'description': 'Apa yang kau cari, sedang mencarimu. Luka adalah tempat di mana cahaya memasukimu. Jangan bersedih, segala yang hilang akan kembali dalam bentuk lain.', 'badge': 'SUFI'},
      {'name': 'HIKMAH', 'title': 'Sabar', 'description': 'Sabar itu separuh daripada iman. Dan yakin itu adalah seluruh iman.', 'badge': 'ADAB'},
      {'name': 'BUYA', 'title': 'Hidup', 'description': 'Jangan takut jatuh, takutlah mati sebelum hidup. Kehidupan yang tidak dipertaruhkan tidak akan dimenangkan.', 'badge': 'JIWA'},
      {'name': 'IBNU SINA', 'title': 'Sihat', 'description': 'Waham adalah penyakit, tenang adalah ubat, dan sabar adalah permulaan kesembuhan.', 'badge': 'MEDIK'},
      {'name': 'SYAFIE', 'title': 'Masa', 'description': 'Masa ibarat pedang, jika kau tak potong, ia memotongmu. Jiwa jika tidak disibukkan dengan kebenaran, ia akan disibukkan dengan kebatilan.', 'badge': 'MASA'},
    ];

    final List<Map<String, dynamic>> sourceMedia = [
      {'type': 'video', 'name': 'TADABBUR', 'title': 'Zikir', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'VIDEO', 'duration': '0:45', 'desc': 'Video pokok berzikir menyerap keagungan Ilahi. Lihatlah dedaunan yang bergerak mengikut irama angin.'},
      {'type': 'image', 'name': 'ALAM FANA', 'title': 'Puncak', 'asset': 'assets/images/pokok_level5.png', 'badge': 'LVL 5', 'desc': 'Pemandangan dari puncak yang mendamaikan jiwa. Mengingatkan kita betapa kecilnya diri ini.'},
      {'type': 'image', 'name': 'USTAZ DON', 'title': 'Ranting', 'asset': 'assets/images/pokok_level3.png', 'badge': 'LVL 3', 'desc': 'Kisah ranting yang rapuh namun tetap bertahan demi menampung dedaunan.'},
      {'type': 'video', 'name': 'HIJRAH', 'title': 'Agung', 'asset': 'assets/videos/tree_v1.mp4', 'badge': 'DOCU', 'duration': '2:30', 'desc': 'Dokumentari khas perjalanan Hijrah Rasulullah SAW.'},
      {'type': 'image', 'name': 'HAMKA', 'title': 'Mula', 'asset': 'assets/images/pokok_level2.png', 'badge': 'LVL 2', 'desc': 'Permulaan segalanya bermula dengan niat yang suci.'},
      {'type': 'image', 'name': 'DR. MAZA', 'title': 'Syariah', 'asset': 'assets/images/pokok_level4.png', 'badge': 'LVL 4', 'desc': 'Perbincangan mendalam mengenai hukum fiqh semasa.'},
      {'type': 'image', 'name': 'UK STORY', 'title': 'London', 'asset': 'assets/images/dummy_post1.jpg', 'badge': 'STORY', 'desc': 'Pengalaman mencari arah kiblat di tengah kota London.'},
      {'type': 'image', 'name': 'SITI', 'title': 'Fiqh', 'asset': 'assets/images/dummy_post2.jpg', 'badge': 'FIQH', 'desc': 'Panduan lengkap solat bagi wanita bekerjaya.'},
    ];

    sourceMedia.shuffle(Random());

    List<Map<String, dynamic>> finalGrid = [];
    int quoteIndex = 0;
    int mediaIndex = 0;

    for (int i = 0; i < 15; i++) {
      if (i % 2 == 0) {
        // X - KUOTA
        var quote = Map<String, dynamic>.from(sourceQuotes[quoteIndex % sourceQuotes.length]);
        quote['type'] = 'quote';
        quote['badgeColor'] = badgeColors[quoteIndex % badgeColors.length];
        finalGrid.add(quote);
        quoteIndex++;
      } else {
        // O - MEDIA
        var media = Map<String, dynamic>.from(sourceMedia[mediaIndex % sourceMedia.length]);
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
          // LATAR BELAKANG LANGIT
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
                      childAspectRatio: 0.58, 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // UNTUK HERO ANIMATION YG UNIK
                      final String heroTag = 'hero_${index}_${item['name']}';

                      return GestureDetector(
                        onTap: () {
                          // 🚀 NAVIGASI ZOOM IN (DETAIL SCREEN)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedDetailScreen(item: item, heroTag: heroTag),
                            ),
                          );
                        },
                        child: Hero(
                          tag: heroTag, // Kunci Animasi Zoom
                          child: Material(
                            color: Colors.transparent,
                            child: item['type'] == 'quote' 
                                ? _buildTransparentTile(item) 
                                : _buildMediaTile(item),
                          ),
                        ),
                      );
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
  // TILE BUILDERS (STATIC - UNTUK GRID)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTransparentTile(Map<String, dynamic> item) {
    const textShadows = [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))];
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    item['description'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                    ),
                    maxLines: 6, overflow: TextOverflow.ellipsis,
                  ),
                ),
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
        _buildBottomCaption(item),
      ],
    );
  }

  Widget _buildMediaTile(Map<String, dynamic> item) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item['asset'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                  ),
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
                  // VIDEO ICON (STATIK DI GRID - TIADA BUTANG PLAY MENYEMAK)
                  if (item['type'] == 'video')
                    Positioned(
                      right: 6, top: 6,
                      child: Icon(Icons.videocam, color: Colors.white.withOpacity(0.8), size: 16),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildBottomCaption(item),
      ],
    );
  }

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
              backgroundImage: (item['type'] != 'quote' && item['asset'] != '') ? AssetImage(item['asset']) : null,
              child: (item['type'] == 'quote' || item['asset'] == '') ? const Icon(Icons.person, size: 12, color: Colors.white) : null,
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
                Text(
                  item['title'],
                  style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 8, fontWeight: FontWeight.w500, shadows: textShadows),
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
// 🚀 FEED DETAIL SCREEN (ZOOM IN & INTERACTIVE)
// ══════════════════════════════════════════════════════════════
class FeedDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String heroTag;

  const FeedDetailScreen({Key? key, required this.item, required this.heroTag}) : super(key: key);

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  bool isExpanded = false; // Status caption (Short/Full)
  bool isPlaying = false;  // Status video (Play/Pause)

  @override
  Widget build(BuildContext context) {
    bool isVideo = widget.item['type'] == 'video';
    bool isQuote = widget.item['type'] == 'quote';

    // Text Description (Fallback jika tiada 'desc', guna 'description')
    String fullText = widget.item['desc'] ?? widget.item['description'] ?? "Tiada kapsyen.";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CONTENT UTAMA (FULL SCREEN)
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: AspectRatio(
                aspectRatio: isQuote ? 0.8 : 9/16, // Quote petak, Video panjang
                child: Container(
                  decoration: BoxDecoration(
                    // Jika Quote, kekalkan background glass
                    color: isQuote 
                        ? (widget.item['badgeColor'] as Color).withOpacity(0.2) 
                        : Colors.black,
                    borderRadius: BorderRadius.circular(isQuote ? 20 : 0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // A. MEDIA
                      if (!isQuote)
                        Image.asset(widget.item['asset'], fit: BoxFit.cover),
                      
                      // B. QUOTE TEXT
                      if (isQuote)
                         Center(
                           child: Padding(
                             padding: const EdgeInsets.all(20),
                             child: Text(
                                widget.item['description'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 24, 
                                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.none
                                ),
                             ),
                           ),
                         ),

                      // C. VIDEO CONTROLS (HANYA JIKA VIDEO)
                      if (isVideo)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isPlaying ? 0.0 : 1.0, // Hilang bila play
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2)
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. TOP BAR (CLOSE BUTTON)
          Positioned(
            top: 40, left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          // 3. BOTTOM CAPTION (INTERACTIVE)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle Zoom Text
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // USER INFO
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: (!isQuote && widget.item['asset'] != '') 
                            ? AssetImage(widget.item['asset']) 
                            : null,
                          child: isQuote ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(widget.item['title'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // CAPTION TEXT (EXPANDABLE)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        fullText,
                        maxLines: isExpanded ? null : 2, // 2 Baris -> Unlimited
                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      ),
                    ),
                    
                    // HINT TEXT
                    if (!isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("Lihat lagi...", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
