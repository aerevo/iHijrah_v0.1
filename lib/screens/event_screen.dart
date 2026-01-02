import 'package:flutter/material.dart';
import 'dart:ui';

// ✅ INTEGRASI: Panggil fail emas original
// Pastikan path ini betul. Jika MetallicGold ada dalam folder 'widgets', ini betul.
import '../widgets/metallic_gold.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final PageController _heroController = PageController(
    viewportFraction: 0.75,
    initialPage: 0,
  );
  
  int _currentHeroIndex = 0;
  int _selectedThumbnail = 0;

  // ══════════════════════════════════════════════════════════════
  // DATA COLLECTION - ISLAMIC AUTHENTIC CONTENT
  // ══════════════════════════════════════════════════════════════
  final List<Map<String, dynamic>> heroItems = [
    {
      'name': 'USTAZ AZHAR IDRUS',
      'role': 'Mufti Perlis',
      'quote': 'Sunat ab\'ad itu sunat yang ditinggalkan tidak berdosa, diamalkan dapat pahala.',
      'description': 'Penjelasan lengkap tentang pembahagian sunat dalam Fiqh Syafie.',
      'image': 'assets/images/dummy_post1.jpg',
      'collection': 'FIQH SERIES™',
      'price': 'PERCUMA',
      'material': 'KITAB FIQH',
      'rating': '4.9/5.0',
      'views': '2.3M'
    },
    {
      'name': 'DR. MAZA',
      'role': 'Pendakwah',
      'quote': 'Salon khusus wanita mestilah bebas daripada pandangan lelaki ajnabi.',
      'description': 'Hukum salon kecantikan dalam Islam dan syarat-syaratnya.',
      'image': 'assets/images/dummy_post2.jpg',
      'collection': 'MUAMALAT™',
      'price': 'PERCUMA',
      'material': 'FATWA',
      'rating': '4.8/5.0',
      'views': '1.8M'
    },
    {
      'name': 'IMAM NAWAWI',
      'role': 'Ulama Salaf',
      'quote': 'Barangsiapa meninggalkan sunat ab\'ad tidak berdosa, tetapi kehilangan keutamaan.',
      'description': 'Rujukan dari Kitab Al-Majmu\' Syarah Al-Muhazzab.',
      'image': 'assets/images/dummy_post1.jpg',
      'collection': 'CLASSIC™',
      'price': 'WARISAN',
      'material': 'MATAN KITAB',
      'rating': 'LEGACY',
      'views': 'ABADI'
    },
    {
      'name': 'USTAZAH SITI',
      'role': 'Pakar Fiqh Wanita',
      'quote': 'Salon muslimah di Wisma Yakin KL, The Curve, dan Sogo ada bahagian tertutup.',
      'description': 'Panduan memilih salon yang patuh syariah untuk muslimah.',
      'image': 'assets/images/dummy_post2.jpg',
      'collection': 'URBAN GUIDE™',
      'price': 'RM50-150',
      'material': 'CERTIFIED',
      'rating': '4.7/5.0',
      'views': '890K'
    },
    {
      'name': 'SYEIKH AHMAD',
      'role': 'Mufassir',
      'quote': 'Sunat muakkad wajib dijaga, sunat ghair muakkad dituntut tetapi ringan.',
      'description': 'Kategori sunat dari perspektif usul fiqh dan tafsir.',
      'image': 'assets/images/dummy_post1.jpg',
      'collection': 'TASAWWUR™',
      'price': 'ILMU',
      'material': 'AUDIO 12HR',
      'rating': '5.0/5.0',
      'views': '3.1M'
    },
  ];

  // Data untuk NEW COLLECTION Grid (Bottom Section)
  final List<Map<String, dynamic>> gridItems = [
    {
      'title': 'SUNAT\nAB\'AD',
      'subtitle': 'Hukum & Dalil',
      'price': 'Free PDF',
      'image': 'assets/images/dummy_post1.jpg',
    },
    {
      'title': 'SALON\nMUSLIMAH',
      'subtitle': 'Directory MY',
      'price': 'Updated 2025',
      'image': 'assets/images/dummy_post2.jpg',
    },
    {
      'title': 'FIQH\nWANITA',
      'subtitle': 'Panduan Lengkap',
      'price': 'RM29.90',
      'image': 'assets/images/dummy_post1.jpg',
    },
    {
      'title': 'SOLAT\nSUNAT',
      'subtitle': 'Panduan Visual',
      'price': 'Free',
      'image': 'assets/images/dummy_post2.jpg',
    },
    {
      'title': 'HIJAB\nSTYLE',
      'subtitle': 'Syar\'ie Guide',
      'price': 'RM15',
      'image': 'assets/images/dummy_post1.jpg',
    },
  ];

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A3F54),
      body: Stack(
        children: [
          // ══════════════════════════════════════════════════════════════
          // BACKGROUND MOUNTAIN LAYER (Arctic Vibes)
          // ══════════════════════════════════════════════════════════════
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF4A6278),
                    const Color(0xFF2A3F54),
                    const Color(0xFF1A2332),
                  ],
                ),
              ),
            ),
          ),

          // Mountain Silhouette Effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 400,
            child: CustomPaint(
              painter: MountainPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ══════════════════════════════════════════════════════════════
                // HEADER BAR
                // ══════════════════════════════════════════════════════════════
                _buildHeader(),

                // ══════════════════════════════════════════════════════════════
                // HERO SECTION WITH THUMBNAILS
                // ══════════════════════════════════════════════════════════════
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      // Main Hero Cards (Swipeable)
                      Expanded(
                        child: PageView.builder(
                          controller: _heroController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentHeroIndex = index;
                              _selectedThumbnail = index;
                            });
                          },
                          itemCount: heroItems.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _heroController,
                              builder: (context, child) {
                                double value = 1.0;
                                // ✅ [FRANCOIS FIX]: Null Safety Check untuk elak crash screen putih
                                if (_heroController.position.haveDimensions) {
                                  value = (_heroController.page ?? 0) - index;
                                  // Clamp pada 0.0 - 1.0 supaya tiada nilai pelik
                                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                                }
                                
                                return Center(
                                  child: SizedBox(
                                    // Guna EaseOut supaya animasi smooth
                                    height: Curves.easeOut.transform(value) * 480,
                                    width: Curves.easeOut.transform(value) * 340,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildHeroCard(heroItems[index]),
                            );
                          },
                        ),
                      ),

                      // Thumbnail Selector (Kanan)
                      _buildThumbnailSelector(),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // NEW COLLECTION GRID
                // ══════════════════════════════════════════════════════════════
                _buildNewCollectionSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER BAR
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Brand/Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.mosque,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TREN',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                  MetallicGold(
                    child: Text(
                      'ILMU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Icons
          Row(
            children: [
              _buildHeaderIcon(Icons.share_outlined),
              _buildHeaderIcon(Icons.more_horiz),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HERO CARD (Main Product Card)
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeroCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              item['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey);
              },
            ),

            // Frosted Glass Overlay (Top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpecBox('RATING', item['rating'], Icons.star_outline),
                        _buildSpecBox('VIEWS', item['views'], Icons.visibility_outlined),
                        _buildSpecBox('MATERIAL', item['material'], Icons.book_outlined),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Bottom Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Collection Badge
                    Text(
                      'COLLECTION',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),
                    MetallicGold(
                      child: Text(
                        item['collection'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quote
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '"${item['quote']}"',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bottom Row: Price + Profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.play_circle_outline, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                item['price'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Profile Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item['name'],
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                item['role'].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildSpecBox(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 7,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // THUMBNAIL SELECTOR (Kanan Side)
  // ══════════════════════════════════════════════════════════════
  Widget _buildThumbnailSelector() {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: heroItems.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedThumbnail;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedThumbnail = index;
                _currentHeroIndex = index;
              });
              _heroController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              height: isSelected ? 90 : 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 10,
                        )
                      ]
                    : null,
                image: DecorationImage(
                  image: AssetImage(heroItems[index]['image']),
                  fit: BoxFit.cover,
                  colorFilter: isSelected
                      ? null
                      : const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // NEW COLLECTION GRID SECTION
  // ══════════════════════════════════════════════════════════════
  Widget _buildNewCollectionSection() {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEW COLLECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '• ${gridItems.length} TOPIK PILIHAN •',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'EXPLORE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Grid
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                return _buildGridItem(gridItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> item) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item['image'],
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['subtitle'],
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['price'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ══════════════════════════════════════════════════════════════
// MOUNTAIN PAINTER (Background Effect)
// ══════════════════════════════════════════════════════════════
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Mountain 1 (Foreground - Darkest)
    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, size.height * 0.5);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.4,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.6,
    );
    path1.lineTo(size.width, size.height);
    path1.close();

    // Mountain 2 (Middle)
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.5,
    );
    path2.lineTo(size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.close();

    // Mountain 3 (Background - Lightest)
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.7);
    path3.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );
    path3.lineTo(size.width, size.height * 0.75);
    path3.lineTo(size.width, size.height);
    path3.close();

    canvas.drawPath(path3, paint3);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
