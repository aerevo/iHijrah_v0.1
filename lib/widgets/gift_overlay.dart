import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GiftOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const GiftOverlay({Key? key, required this.onAnimationComplete}) : super(key: key);

  @override
  State<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<GiftOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<GiftParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Tempoh animasi
    );

    // Generate 50 particles
    for (int i = 0; i < 50; i++) {
      _particles.add(GiftParticle());
    }

    _controller.forward().then((_) => widget.onAnimationComplete());
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
          size: Size.infinite,
          painter: GiftPainter(_particles, _controller.value),
        );
      },
    );
  }
}

class GiftParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  GiftParticle()
      : angle = Random().nextDouble() * 2 * pi,
        speed = Random().nextDouble() * 10 + 5,
        size = Random().nextDouble() * 5 + 2,
        color = [
          Colors.cyanAccent, // Air
          const Color(0xFFFCF6BA), // Emas
          Colors.white
        ][Random().nextInt(3)];
}

class GiftPainter extends CustomPainter {
  final List<GiftParticle> particles;
  final double progress;

  GiftPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      // Fizik letupan
      final distance = p.speed * (progress * 50); // Bergerak keluar
      final dx = center.dx + cos(p.angle) * distance;
      final dy = center.dy + sin(p.angle) * distance;
      
      // Opacity pudar di hujung
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(opacity);

      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}