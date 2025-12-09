import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class HijrahTree extends StatefulWidget {
  const HijrahTree({Key? key}) : super(key: key);

  @override
  State<HijrahTree> createState() => _HijrahTreeState();
}

class _HijrahTreeState extends State<HijrahTree> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  final List<LeafParticle> _leaves = [];
  Timer? _leafSpawner;
  
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Shake pantas
    );

    // Spawn daun setiap 2 saat (Idle animation)
    _leafSpawner = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) _spawnLeaf();
    });
  }

  void _spawnLeaf({int count = 1}) {
    setState(() {
      for (int i = 0; i < count; i++) {
        _leaves.add(LeafParticle(
          x: Random().nextDouble() * 300, // Lebar container
          y: 0,
          angle: Random().nextDouble() * 2 * pi,
          speed: Random().nextDouble() * 2 + 1,
        ));
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _leafSpawner?.cancel();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact(); // Getaran fizikal
    _shakeController.forward(from: 0);
    _spawnLeaf(count: 5); // Gugurkan banyak daun bila tekan
    
    // TODO: Trigger popup menu atau stats di sini
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, _) {
        // Update physics daun (Simple loop dalam build untuk demo, better guna Ticker)
        // Nota: Untuk production, move logic ni ke Ticker.
        for (var leaf in _leaves) {
          leaf.y += leaf.speed;
          leaf.angle += 0.05;
        }
        _leaves.removeWhere((leaf) => leaf.y > 400); // Buang bila keluar skrin

        return GestureDetector(
          onTap: _handleTap,
          child: SizedBox(
            height: 400,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. GLOW BELAKANG (Mystical)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryGold.withOpacity(0.1),
                        blurRadius: 60,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
                
                // 2. POKOK (Dengan Shake Animation)
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    // Kira offset untuk gegaran
                    double offset = sin(_shakeController.value * pi * 4) * 5;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/pokok_level${user.treeLevel > 4 ? 4 : 1}.png', // Pastikan aset wujud
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                ),

                // 3. DAUN GUGUR (Custom Painter)
                Positioned.fill(
                  child: CustomPaint(
                    painter: LeafPainter(_leaves),
                  ),
                ),

                // 4. LEVEL BADGE (Floating Premium)
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: kGoldGradientColors[1].withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
                      ]
                    ),
                    child: MetallicGold(
                      child: Text(
                        "LVL ${user.treeLevel} • ${user.totalPoints} XP",
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Logic Daun
class LeafParticle {
  double x, y, angle, speed;
  LeafParticle({required this.x, required this.y, required this.angle, required this.speed});
}

class LeafPainter extends CustomPainter {
  final List<LeafParticle> leaves;
  LeafPainter(this.leaves);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kAccentOlive;
    
    for (var leaf in leaves) {
      canvas.save();
      canvas.translate(leaf.x, leaf.y);
      canvas.rotate(leaf.angle);
      // Lukis daun simple (bujur)
      canvas.drawOval(const Rect.fromLTWH(0, 0, 10, 6), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}