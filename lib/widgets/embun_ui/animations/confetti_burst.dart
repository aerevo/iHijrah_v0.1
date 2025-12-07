// lib/widgets/embun_ui/animations/confetti_burst.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Confetti Burst - Letupan confetti
class ConfettiBurst extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  
  const ConfettiBurst({
    Key? key,
    this.particleCount = 30,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);
  
  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    // Generate particles
    _particles = List.generate(
      widget.particleCount,
      (i) => ConfettiParticle(),
    );
    
    _controller.forward();
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
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double rotationSpeed;
  final double size;
  
  ConfettiParticle()
      : color = _randomColor(),
        angle = Random().nextDouble() * 2 * pi,
        speed = Random().nextDouble() * 300 + 100,
        rotationSpeed = Random().nextDouble() * 4 - 2,
        size = Random().nextDouble() * 8 + 4;
  
  static Color _randomColor() {
    final colors = [
      kPrimaryGold,
      kAccentOlive,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.orange,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (var particle in particles) {
      // Calculate position
      final distance = particle.speed * progress;
      final x = centerX + cos(particle.angle) * distance;
      final y = centerY + sin(particle.angle) * distance + (progress * progress * 200); // Gravity
      
      // Calculate rotation
      final rotation = particle.rotationSpeed * progress * 2 * pi;
      
      // Calculate opacity (fade out at end)
      final opacity = (1 - progress).clamp(0.0, 1.0);
      
      // Draw particle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 1.5,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}