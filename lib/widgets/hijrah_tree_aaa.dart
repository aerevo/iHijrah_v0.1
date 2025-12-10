// lib/widgets/hijrah_tree_aaa.dart (AAA PREMIUM - NON-CARTOON)

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class HijrahTreeAAA extends StatefulWidget {
  const HijrahTreeAAA({Key? key}) : super(key: key);

  @override
  State<HijrahTreeAAA> createState() => _HijrahTreeAAAState();
}

class _HijrahTreeAAAState extends State<HijrahTreeAAA> with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _breathAnimation;
  late Animation<double> _glowAnimation;

  final List<TreeParticle> _particles = [];
  Timer? _particleSpawner;

  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();

    // Breathing animation (subtle scale)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Particle system
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Spawn ambient particles
    _particleSpawner = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted && !_isInteracting) _spawnParticle();
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _particleSpawner?.cancel();
    super.dispose();
  }

  void _spawnParticle({int count = 1}) {
    setState(() {
      for (int i = 0; i < count; i++) {
        _particles.add(TreeParticle(
          x: 150 + Random().nextDouble() * 100 - 50,
          y: 320,
          velocity: Offset(
            Random().nextDouble() * 2 - 1,
            -(Random().nextDouble() * 3 + 2),
          ),
          color: Color.lerp(
            kPrimaryGold,
            const Color(0xFF4DD0E1), // Cyan (water)
            Random().nextDouble(),
          )!,
          size: Random().nextDouble() * 4 + 2,
        ));
      }
    });

    // Remove old particles
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => p.age > 3.0);
        });
      }
    });
  }

  void _handleInteraction() {
    if (_isInteracting) return;

    setState(() => _isInteracting = true);
    HapticFeedback.mediumImpact();

    // Burst particles
    _spawnParticle(count: 15);

    // Show info dialog
    _showTreeInfo();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isInteracting = false);
    });
  }

  void _showTreeInfo() {
    final user = Provider.of<UserModel>(context, listen: false);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kCardDark.withOpacity(0.95),
                kCardDark.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: kPrimaryGold.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimaryGold.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: kGoldGradientColors.take(2).toList(),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGold.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  size: 48,
                  color: kBackgroundDark,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const MetallicGold(
                child: Text(
                  'POKOK HIJRAH ANDA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair',
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stats
              _buildStatRow('Level Rohani', '${user.treeLevel}'),
              _buildStatRow('Total XP', '${user.totalPoints}'),
              _buildStatRow('Progress', '${(user.progressPercentage * 100).toInt()}%'),

              const SizedBox(height: 20),

              // Description
              Text(
                'Pokok ini melambangkan perjalanan hijrah anda. Setiap amalan menyuburkannya dengan "Embun Jiwa" - rahmat Allah yang turun.',
                style: TextStyle(
                  color: kTextSecondary.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGold,
                    foregroundColor: kBackgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TERUSKAN PERJALANAN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 14,
            ),
          ),
          MetallicGold(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, _) {
        // Update particle physics
        for (var particle in _particles) {
          particle.update();
        }

        return GestureDetector(
          onTap: _handleInteraction,
          child: SizedBox(
            height: 400,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. AMBIENT GLOW (Multiple layers)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            kPrimaryGold.withOpacity(_glowAnimation.value * 0.3),
                            kPrimaryGold.withOpacity(_glowAnimation.value * 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),

                // 2. SECONDARY GLOW (Cyan tint for water)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4DD0E1).withOpacity(_glowAnimation.value * 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 3. TREE WITH BREATHING ANIMATION
                AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathAnimation.value,
                      child: child,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_isInteracting ? 1.05 : 1.0),
                    child: Image.asset(
                      'assets/images/pokok_level${user.treeLevel > 4 ? 4 : 1}.png',
                      height: 320,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.eco,
                        size: 200,
                        color: kPrimaryGold.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                // 4. PARTICLE SYSTEM
                Positioned.fill(
                  child: CustomPaint(
                    painter: TreeParticlePainter(_particles),
                  ),
                ),

                // 5. INTERACTION HINT (Subtle pulse)
                Positioned(
                  bottom: 40,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.3 + (_glowAnimation.value * 0.4),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kPrimaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: kPrimaryGold,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tap untuk maklumat',
                            style: TextStyle(
                              color: kPrimaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. LEVEL BADGE (Premium floating)
                Positioned(
                  bottom: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: kGoldGradientColors[1].withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MetallicGold(
                          child: Text(
                            'LVL ${user.treeLevel}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: kPrimaryGold.withOpacity(0.3),
                        ),
                        MetallicGold(
                          child: Text(
                            '${user.totalPoints} XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Particle class
class TreeParticle {
  double x;
  double y;
  Offset velocity;
  Color color;
  double size;
  double age = 0;

  TreeParticle({
    required this.x,
    required this.y,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update() {
    age += 0.016; // ~60fps
    y += velocity.dy;
    x += velocity.dx;
    velocity = Offset(
      velocity.dx * 0.98,
      velocity.dy + 0.05, // Gravity
    );
  }
}

// Painter
class TreeParticlePainter extends CustomPainter {
  final List<TreeParticle> particles;

  TreeParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final opacity = (1.0 - (particle.age / 3.0)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );

      // Inner glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
