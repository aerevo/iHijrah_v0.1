import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';

// ✅ INTEGRASI: Kita panggil fail emas original Kapten
import '../widgets/metallic_gold.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Premium Dummy (Nanti kita sambung ke JSON Sirah)
    final List<Map<String, dynamic>> items = [
      {
        'name': 'HIJRAH',
        'category': 'SPIRITUAL',
        'age': '100%',
        'caption': 'Transform Your Soul ✨',
        'image': 'assets/images/mosque_bg.jpg',
        'height': 320.0,
        'featured': true,
      },
      {
        'name': 'FATIMAH',
        'category': 'INSPIRATION',
        'age': '21',
        'caption': 'Cinta Al-Quran',
        'image': 'assets/images/quran_bg.jpg',
        'height': 240.0,
        'featured': false,
      },
      {
        'name': 'ADAM',
        'category': 'JOURNEY',
        'age': '28',
        'caption': 'Musafir Ilmu',
        'image': 'assets/images/nature_bg.jpg',
        'height': 280.0,
        'featured': false,
      },
      {
        'name': 'YUSOF',
        'category': 'FAITH',
        'age': '30',
        'caption': 'Hijrah Hati',
        'image': 'assets/images/kaaba_bg.jpg',
        'height': 300.0,
        'featured': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent supaya nampak latar belakang app
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Masonry Grid (Susunan Pinterest)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _PremiumPosterCard(
                    name: item['name'],
                    category: item['category'],
                    age: item['age'],
                    caption: item['caption'],
                    height: item['height'],
                    imagePath: item['image'],
                    isFeatured: item['featured'] ?? false,
                  );
                },
              ),
            ),
            // Ruang tambahan di bawah supaya tak tertutup menu
            const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }
}

/// KAD POSTER PREMIUM (REKAAN CLAUDE)
class _PremiumPosterCard extends StatefulWidget {
  final String name;
  final String category;
  final String age;
  final String caption;
  final double height;
  final String imagePath;
  final bool isFeatured;

  const _PremiumPosterCard({
    required this.name,
    required this.category,
    required this.age,
    required this.caption,
    required this.height,
    required this.imagePath,
    required this.isFeatured,
  });

  @override
  State<_PremiumPosterCard> createState() => _PremiumPosterCardState();
}

class _PremiumPosterCardState extends State<_PremiumPosterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: () {
        // Nanti kita tambah fungsi buka detail di sini
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow lebih lembut
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Gambar Latar dengan Efek Zoom
                AnimatedScale(
                  scale: _isPressed ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white24),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Vignette Gelap (Gradient Bawah ke Atas)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.9), // Gelap pekat di bawah
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),

                // 3. Badge "Featured" (Bucu Kanan Atas)
                if (widget.isFeatured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _GlassBadge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 10, color: Color(0xFFFFD54F)),
                          const SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Kategori (Bucu Kiri Atas)
                Positioned(
                  top: 10,
                  left: 10,
                  child: _GlassBadge(
                    color: Colors.white.withOpacity(0.1),
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // 5. Kandungan Utama (Bawah)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag Umur (Kaca)
                        _GlassBadge(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            "${widget.age} THN",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Nama Emas (Guna Widget Master Kita)
                        MetallicGold(
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: widget.name.length > 8 ? 22 : 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  offset: const Offset(0, 2),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Caption
                        Text(
                          widget.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// KOMPONEN KACA (GLASSMORPHISM)
class _GlassBadge extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;

  const _GlassBadge({
    required this.child,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
