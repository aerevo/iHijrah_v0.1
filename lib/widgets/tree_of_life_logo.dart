// lib/widgets/tree_of_life_logo.dart
// Lambang "Pokok Hayat" dioptimumkan untuk gaya artistik (merimbun & akar berselirat).
// Menggunakan pemalar warna emas teras terus dari constants.dart.

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
      duration: widget.animated ? const Duration(seconds: 6) : const Duration(milliseconds: 700),
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
    // Seed tetap supaya bentuk sentiasa konsisten dan kemas
    final math.Random rnd = math.Random(88);
    final Offset rootBase = const Offset(50, 75);
    final Offset trunkTop = const Offset(50, 48);
    
    // Batang Utama yang tebal dan sedikit melengkung
    _branches.add(_Branch(rootBase, const Offset(49, 60), trunkTop, 8.0));
    
    // Kipas Dahan Utama (Ke atas dan melebar)
    // Sudut radian dari kiri ke kanan
    const List<double> branchAngles = [-2.7, -2.2, -1.57, -0.9, -0.4];
    for (var angle in branchAngles) {
      _growBranch(rnd, trunkTop, angle, 16, 1, 4, isRoot: false);
    }
    
    // Kipas Akar (Ke bawah dan merayap)
    const List<double> rootAngles = [0.4, 1.0, 1.57, 2.1, 2.7];
    for (var angle in rootAngles) {
      _growBranch(rnd, rootBase, angle, 14, 1, 3, isRoot: true);
    }
  }

  void _growBranch(math.Random rnd, Offset start, double angle, double length, int depth, int maxDepth, {bool isRoot = false}) {
    // Tambah sedikit lencongan rawak untuk gaya organik
    final double a = angle + (rnd.nextDouble() - 0.5) * 0.4;
    final Offset end = Offset(start.dx + math.cos(a) * length, start.dy + math.sin(a) * length);
    
    // Titik kawalan Bezier untuk lengkungan dahan/akar
    final double curveStrength = length * 0.3 * (rnd.nextBool() ? 1 : -1);
    final Offset ctrl = Offset(
      (start.dx + end.dx) / 2 + math.cos(a + math.pi / 2) * curveStrength,
      (start.dy + end.dy) / 2 + math.sin(a + math.pi / 2) * curveStrength,
    );
    
    // Ketebalan dahan mengecil mengikut kedalaman (tapering)
    final double width = isRoot 
        ? math.max(1.0, 6.0 - (depth * 1.5)) 
        : math.max(1.0, 6.5 - (depth * 1.5));
        
    _branches.add(_Branch(start, ctrl, end, width));

    // Jika sampai di hujung dahan (bukan akar), hasilkan daun yang rimbun
    if (depth >= maxDepth) {
      if (isRoot) return;
      
      // Kepadatan daun ditingkatkan untuk efek "merimbun"
      final int leafCount = 6 + rnd.nextInt(5); 
      for (int i = 0; i < leafCount; i++) {
        final double dist = 1.0 + rnd.nextDouble() * 8.0;
        final double leafAngle = a + (rnd.nextDouble() - 0.5) * 2.5;
        final Offset center = Offset(end.dx + math.cos(leafAngle) * dist, end.dy + math.sin(leafAngle) * dist);
        
        // Saiz daun bujur/teardrop
        final double rx = 3.5 + rnd.nextDouble() * 2.0;
        final double ry = 1.8 + rnd.nextDouble() * 1.2;
        final double swaySpeed = 0.5 + rnd.nextDouble() * 1.5;
        
        _leaves.add(_Leaf(center, rx, ry, leafAngle + math.pi / 2, swaySpeed));
      }
      return;
    }

    // Pembiakan cabang (2 hingga 3 cabang baharu per nod)
    final int branchesToGrow = (depth == 1) ? 3 : 2;
    for (int i = 0; i < branchesToGrow; i++) {
      final double spread = 0.4 + rnd.nextDouble() * 0.4;
      final double newAngle = (i == 0) ? (a - spread) : (i == 1 ? a + spread : a + (rnd.nextDouble() - 0.5) * 0.2);
      final double newLength = length * (0.7 + rnd.nextDouble() * 0.15);
      
      _growBranch(rnd, end, newAngle, newLength, depth + 1, maxDepth, isRoot: isRoot);
    }
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

    const Offset center = Offset(50, 48);
    final Rect fullRect = const Rect.fromLTWH(0, 0, 100, 100);

    // 1. Bingkai Artistik Luar (Cincin Terbuka)
    // Cincin ditinggalkan terbuka sedikit di bahagian bawah untuk akar melepasi bingkai
    final Paint ringPaint = Paint()
      ..shader = const SweepGradient(
        colors: [kGoldMid, kGoldHighlight, kGoldDeep, kGoldHighlight, kGoldMid],
      ).createShader(Rect.fromCircle(center: center, radius: 46))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
      
    // Lukis lengkok (arc) bermula dari bawah kanan pusing ke bawah kiri
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 46), 
      math.pi * 0.25, 
      math.pi * 1.5, 
      false, 
      ringPaint
    );

    // 2. Batang, Dahan & Akar
    final Paint linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep],
      ).createShader(fullRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Animasi tiupan angin pada dahan
    final double swayAngle = animated ? math.sin(time) * 0.02 : 0.0;
    const Offset pivot = Offset(50, 75);

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

    // 3. Daun Rimbun Organik
    final Paint leafPaint = Paint()..color = kPrimaryGold;

    // Bentuk daun diubahsuai menyerupai daun zaitun/teardrop berseni
    Path getLeafPath(double rx, double ry) {
      return Path()
        ..moveTo(0, -ry)
        ..quadraticBezierTo(rx, -ry * 0.2, rx, ry * 0.6)
        ..quadraticBezierTo(rx * 0.5, ry, 0, ry)
        ..quadraticBezierTo(-rx * 0.5, ry, -rx, ry * 0.6)
        ..quadraticBezierTo(-rx, -ry * 0.2, 0, -ry)
        ..close();
    }

    for (final leaf in leaves) {
      canvas.save();
      final double leafSway = animated ? math.sin(time * leaf.swaySpeed) * 0.12 : 0.0;
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
