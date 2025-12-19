// lib/widgets/dynamic_background.dart (LATAR CORAK MODE)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, sidebarState, child) {
        String targetImage;
        bool isMenuOpen = sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty;

        // ✅ FIX 1: Dua-dua keadaan (Menu Buka atau Tutup) guna LATAR CORAK.
        // Alam.png disimpan dalam sejarah. Sekarang era Latar Corak.
        targetImage = AppAssets.bgPattern; 

        return Stack(
          children: [
            // 1. BASE IMAGE
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: Container(
                key: ValueKey<String>(targetImage),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(targetImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 2. FIREFLIES (Kekal ada untuk effect hidup)
            // Kita benarkan fireflies walaupun guna latar corak supaya tak kaku
             const Positioned.fill(
                child: _FireflyEffect(), 
              ),

            // 3. AMBIENT GLOW (Gradient dari bawah)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8), // Bawah: Gelap
                      Colors.black.withOpacity(0.3), // Tengah
                      Colors.transparent,            // Atas
                    ],
                    stops: const [0.0, 0.4, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- CLASS: FIREFLY PARTICLES ---
class _FireflyEffect extends StatefulWidget {
  const _FireflyEffect({Key? key}) : super(key: key);

  @override
  State<_FireflyEffect> createState() => _FireflyEffectState();
}

class _FireflyEffectState extends State<_FireflyEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Firefly> _fireflies = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 25; i++) {
      _fireflies.add(_generateFirefly());
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), 
    )..repeat();
  }

  _Firefly _generateFirefly() {
    return _Firefly(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 3 + 1, 
      opacity: _random.nextDouble() * 0.5 + 0.3,
      speedX: (_random.nextDouble() - 0.5) * 0.002,
      speedY: (_random.nextDouble() - 0.5) * 0.002,
      offset: _random.nextDouble() * 2 * pi, 
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FireflyPainter(_fireflies, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Firefly {
  double x;
  double y;
  double size;
  double opacity;
  double speedX;
  double speedY;
  double offset;

  _Firefly({
    required this.x, required this.y, required this.size, 
    required this.opacity, required this.speedX, required this.speedY, required this.offset
  });
}

class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double animationValue;

  _FireflyPainter(this.fireflies, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var fly in fireflies) {
      fly.x += fly.speedX;
      fly.y += fly.speedY;

      if (fly.x < 0) fly.x = 1;
      if (fly.x > 1) fly.x = 0;
      if (fly.y < 0) fly.y = 1;
      if (fly.y > 1) fly.y = 0;

      final twinkle = (sin((animationValue * 2 * pi) + fly.offset) + 1) / 2; 
      final currentOpacity = fly.opacity * (0.5 + 0.5 * twinkle); 

      paint.color = kPrimaryGold.withOpacity(currentOpacity * 0.5); 
      canvas.drawCircle(Offset(fly.x * size.width, fly.y * size.height), fly.size * 2, paint);

      paint.color = const Color(0xFFFFF9C4).withOpacity(currentOpacity);
      canvas.drawCircle(Offset(fly.x * size.width, fly.y * size.height), fly.size * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
