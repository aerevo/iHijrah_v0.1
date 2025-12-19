// lib/widgets/dynamic_background.dart (LIVING ATMOSPHERE: FIREFLIES & GLOW)
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
        // Kita kekalkan logic asal (0% overlay untuk Alam)
        // Tapi overlay akan ditambah secara manual di bawah guna Gradient
        bool isMenuOpen = sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty;

        if (isMenuOpen) {
          targetImage = AppAssets.bgPattern;
        } else {
          targetImage = AppAssets.bgDay; 
        }

        return Stack(
          children: [
            // 1. BASE IMAGE (Animated Switcher)
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

            // 2. FIREFLIES / PARTICLES (Hanya bila Menu Tutup / Alam Mode)
            if (!isMenuOpen)
              const Positioned.fill(
                child: _FireflyEffect(), 
              ),

            // 3. AMBIENT GLOW (Gradient dari bawah ke atas)
            // Ini yang buat teks nampak jelas tapi gambar masih terang
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8), // Bawah: Gelap (untuk Navigation/Footer)
                      Colors.black.withOpacity(0.3), // Tengah: Sederhana
                      Colors.transparent,            // Atas: Jelas (untuk Langit)
                    ],
                    stops: const [0.0, 0.4, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // 4. EXTRA SHADOW FOR SIDEBAR AREA (Left Side)
            // Supaya sidebar nampak jelas walaupun background terang
            Positioned(
              left: 0, top: 0, bottom: 0,
              width: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
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

// --- CLASS: FIREFLY PARTICLES (KUNANG-KUNANG) ---
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
    // Buat 25 ekor kunang-kunang
    for (int i = 0; i < 25; i++) {
      _fireflies.add(_generateFirefly());
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Loop panjang supaya tak nampak berulang
    )..repeat();
  }

  _Firefly _generateFirefly() {
    return _Firefly(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 3 + 1, // Saiz 1.0 - 4.0
      opacity: _random.nextDouble() * 0.5 + 0.3, // Opacity 0.3 - 0.8
      speedX: (_random.nextDouble() - 0.5) * 0.002, // Gerak perlahan kiri/kanan
      speedY: (_random.nextDouble() - 0.5) * 0.002, // Gerak perlahan atas/bawah
      offset: _random.nextDouble() * 2 * pi, // Fasa kelip berbeza
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
      // 1. Gerakkan Firefly
      fly.x += fly.speedX;
      fly.y += fly.speedY;

      // Wrap around screen (Pacman style)
      if (fly.x < 0) fly.x = 1;
      if (fly.x > 1) fly.x = 0;
      if (fly.y < 0) fly.y = 1;
      if (fly.y > 1) fly.y = 0;

      // 2. Efek Kelip (Twinkle) - Guna Sinus wave
      final twinkle = (sin((animationValue * 2 * pi) + fly.offset) + 1) / 2; // 0.0 -> 1.0
      final currentOpacity = fly.opacity * (0.5 + 0.5 * twinkle); // Min opacity 50% dari base

      // 3. Lukis Glow
      paint.color = kPrimaryGold.withOpacity(currentOpacity * 0.5); // Glow luar pudar
      canvas.drawCircle(Offset(fly.x * size.width, fly.y * size.height), fly.size * 2, paint);

      // 4. Lukis Core (Titik Putih/Emas)
      paint.color = Color(0xFFFFF9C4).withOpacity(currentOpacity); // Putih kekuningan
      canvas.drawCircle(Offset(fly.x * size.width, fly.y * size.height), fly.size * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
