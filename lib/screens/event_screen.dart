import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';

// ✅ INTEGRASI: Panggil fail emas original
import '../widgets/metallic_gold.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ KONTEN ASAL KAPTEN (Dipindahkan dari FeedPanel)
    final List<Map<String, dynamic>> items = [
      {
        'name': 'USTAZ DON',
        'category': 'VIDEO',
        'age': '40',
        'caption': 'Kisah Hijrah Rasulullah: Detik cemas di Gua Thur. 🕷️',
        'image': 'assets/images/mosque_bg.jpg', 
        'height': 320.0,
        'featured': true,
      },
      {
        'name': 'IMAM SYAFII',
        'category': 'QUOTE',
        'age': '60+',
        'caption': 'Jangan bersedih, sesungguhnya Allah bersama kita. ✨',
        'image': 'assets/images/nature_bg.jpg', 
        'height': 240.0,
        'featured': false,
      },
      {
        'name': 'DR. ZUL',
        'category': 'ARTICLE',
        'age': '50',
        'caption': 'Tips Murah Rezeki: Amalan dhuha dan sedekah subuh.',
        'image': 'assets/images/quran_bg.jpg', 
        'height': 280.0,
        'featured': true,
      },
      {
        'name': 'MUALLAF',
        'category': 'STORY',
        'age': '25',
        'caption': 'Hidayah di London: Bagaimana Al-Quran mengubah hidup saya.',
        'image': 'assets/images/kaaba_bg.jpg', 
        'height': 300.0,
        'featured': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
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
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }
}

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
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
      onTapDown: (_) { setState(() => _isPressed = true); _controller.forward(); },
      onTapUp: (_) { setState(() => _isPressed = false); _controller.reverse(); },
      onTapCancel: () { setState(() => _isPressed = false); _controller.reverse(); },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _isPressed ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(color: Colors.grey.shade900),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.9)],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                if (widget.isFeatured)
                  Positioned(
                    top: 10, right: 10,
                    child: _GlassBadge(
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 10, color: Color(0xFFFFD54F)),
                          const SizedBox(width: 4),
                          const Text('FEATURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10, left: 10,
                  child: _GlassBadge(child: Text(widget.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70))),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GlassBadge(child: Text("${widget.age} THN", style: const TextStyle(fontSize: 10, color: Colors.white))),
                        const SizedBox(height: 8),
                        MetallicGold(
                          child: Text(
                            widget.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.2),
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

class _GlassBadge extends StatelessWidget {
  final Widget child;
  const _GlassBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        ),
      ),
    );
  }
}
