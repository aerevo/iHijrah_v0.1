// lib/widgets/tree_of_life_logo.dart
// Lambang "Pokok Hayat" dioptimumkan untuk maintainability.
// Menggunakan pemalar warna emas teras terus dari constants.dart baharu.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TreeOfLifeLogo extends StatefulWidget {
  final double size;
  final bool animated;
  const TreeOfLifeLogo({Key? key, this.size = 84, this.animated = true}) : super(key: key);

  @override
  State<TreeOfLifeLogo> createState() => _TreeOfLifeLogoState();
}

class _TreeOfLifeLogoState extends State<TreeOfLifeLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final List<_Branch> _branches = [];
  final List<_Leaf> _leaves = [];
  
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.animated ? const Duration(seconds: 5) : const Duration(milliseconds: 700),
    );
    
    if (widget.animated) {
      _anim.repeat();
    } else {
      _anim.value = 1.0;
    }
    _generateTree();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _generateTree() {
    final math.Random rnd = math.Random(42);
    final Offset root = const Offset(50, 68);
    final Offset trunkTop = const Offset(50, 42);
    
    // Batang Utama
    _branches.add(_Branch(root, const Offset(48, 55), trunkTop, 5.5));
    
    // Dahan Utama (Kipas)
    const List<double> angles = [-2.4, -1.9, -1.57, -1.2, -0.7];
    for (var angle in angles) {
      _growBranch(rnd, trunkTop, angle, 17, 1, 3);
    }
    
    // Akar
    const List<double> rootAngles = [0.8, 1.57, 2.3];
    for (var angle in rootAngles) {
      _growBranch(rnd, root, angle, 12, 1, 2, isRoot: true);
    }
  }

  void _growBranch(math.Random rnd, Offset start, double angle, double length, int depth, int maxDepth, {bool isRoot = false}) {
    final double a = angle + (rnd.nextDouble() - 0.5) * 0.2;
    final Offset end = Offset(start.dx + math.cos(a) * length, start.dy + math.sin(a) * length);
    final Offset ctrl = Offset(
      (start.dx + end.dx) / 2 + math.cos(a + math.pi / 2) * length * 0.2,
      (start.dy + end.dy) / 2 + math.sin(a + math.pi / 2) * length * 0.2,
    );
    
    final double width = isRoot ? math.max(1.0, 3.0 - depth) : math.max(1.5, 4.5 - depth * 1.2);
    _branches.add(_Branch(start, ctrl, end, width));

    if (depth >= maxDepth) {
      if (isRoot) return;
      final int leafCount = 4 + rnd.nextInt(3); 
      for (int i = 0; i < leafCount; i++) {
        final double dist = 2.0 + rnd.nextDouble() * 5.0;
        final double leafAngle = a + (rnd.nextDouble() - 0.5) * 2.0;
        final Offset center = Offset(end.dx + math.cos(leafAngle) * dist, end.dy + math.sin(leafAngle) * dist);
        
        final double rx = 3.5 + rnd.nextDouble() * 1.5;
        final double ry = 2.0 + rnd.nextDouble() * 1.0;
        final double swaySpeed = 0.5 + rnd.nextDouble() * 1.0;
        
        _leaves.add(_Leaf(center, rx, ry, leafAngle + math.pi / 2, swaySpeed));
      }
      return;
    }

    final double spread = 0.5 + rnd.nextDouble() * 0.2;
    _growBranch(rnd, end, a - spread, length * 0.7, depth + 1, maxDepth, isRoot: isRoot);
    _growBranch(rnd, end, a + spread, length * 0.7, depth + 1, maxDepth, isRoot: isRoot);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _TreePainter(
            branches: _branches,
            leaves: _leaves,
            time: _anim.value * 2 * math.pi,
            animated: widget.animated,
          ),
        );
      },
    );
  }
}

// ── MODELS ──────────────────────────────────────────────────

class _Branch {
  final Offset start, ctrl, end;
  final double width;
  _Branch(this.start, this.ctrl, this.end, this.width);
}

class _Leaf {
  final Offset center;
  final double rx, ry, rotation, swaySpeed;
  _Leaf(this.center, this.rx, this.ry, this.rotation, this.swaySpeed);
}

// ── PAINTER ─────────────────────────────────────────────────

class _TreePainter extends CustomPainter {
  final List<_Branch> branches;
  final List<_Leaf> leaves;
  final double time;
  final bool animated;

  _TreePainter({required this.branches, required this.leaves, required this.time, required this.animated});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale);

    const Offset center = Offset(50, 50);
    final Rect fullRect = const Rect.fromLTWH(0, 0, 100, 100);

    // 1. Cincin Luar (Guna kGoldDeep, kGoldHighlight, kGoldMid)
    final Paint ringPaint = Paint()
      ..shader = const SweepGradient(
        colors: [kGoldDeep, kGoldHighlight, kGoldMid, kGoldHighlight, kGoldDeep],
      ).createShader(Rect.fromCircle(center: center, radius: 42))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 42, ringPaint);

    // 2. Batang & Dahan
    final Paint linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep],
      ).createShader(fullRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double swayAngle = animated ? math.sin(time) * 0.03 : 0.0;
    const Offset pivot = Offset(50, 68);

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(swayAngle);
    canvas.translate(-pivot.dx, -pivot.dy);

    for (final b in branches) {
      linePaint.strokeWidth = b.width;
      final Path p = Path()
        ..moveTo(b.start.dx, b.start.dy)
        ..quadraticBezierTo(b.ctrl.dx, b.ctrl.dy, b.end.dx, b.end.dy);
      canvas.drawPath(p, linePaint);
    }

    // 3. Daun Organik (Guna kPrimaryGold dari constants baharu)
    final Paint leafPaint = Paint()..color = kPrimaryGold.withOpacity(0.85);

    Path getLeafPath(double rx, double ry) {
      return Path()
        ..moveTo(0, -ry)
        ..quadraticBezierTo(rx, -ry * 0.3, rx * 0.7, ry * 0.5)
        ..quadraticBezierTo(rx * 0.3, ry, 0, ry)
        ..quadraticBezierTo(-rx * 0.3, ry, -rx * 0.7, ry * 0.5)
        ..quadraticBezierTo(-rx, -ry * 0.3, 0, -ry)
        ..close();
    }

    for (final leaf in leaves) {
      canvas.save();
      final double leafSway = animated ? math.sin(time * leaf.swaySpeed) * 0.15 : 0.0;
      canvas.translate(leaf.center.dx, leaf.center.dy);
      canvas.rotate(leaf.rotation + leafSway);
      canvas.drawPath(getLeafPath(leaf.rx, leaf.ry), leafPaint);
      canvas.restore();
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => animated && old.time != time;
}
