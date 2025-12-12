// lib/widgets/embun_ui/animations/floating_particles.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Floating Particles - Zarah yang melayang
class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;
  final double size;
  
  const FloatingParticles({
    Key? key,
    this.count = 20,
    this.color = kPrimaryGold,
    this.size = 4,
  }) : super(key: key);
  
  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _particles = List.generate(widget.count, (i) => Particle());
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
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
            size: widget.size,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double speed = Random().nextDouble() * 0.5 + 0.5;
  final double size = Random().nextDouble() * 0.5 + 0.5;
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;
  final double size;
  
  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.size,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = color;
    
    for (var particle in particles) {
      final x = particle.x * canvasSize.width;
      final y = ((particle.y + progress * particle.speed) % 1.0) * canvasSize.height;
      final particleSize = size * particle.size;
      
      paint.color = color.withOpacity(0.6 * (1 - (progress * particle.speed % 1.0)));
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}