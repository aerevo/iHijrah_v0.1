// lib/widgets/tree_of_life_logo.dart
// Algoritma Pokok Hayat Fraktal (Recursive Procedural Generation)
// Dirombak sepenuhnya dengan Cubic Beziers, Flared Trunk, dan Recursive Crown.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TreeOfLifeLogo extends StatefulWidget {
  final double size;
  final bool animated;

  const TreeOfLifeLogo({
    Key? key,
    this.size = 148,
    this.animated = true,
  }) : super(key: key);

  @override
  State<TreeOfLifeLogo> createState() => _TreeOfLifeLogoState();
}

class _TreeOfLifeLogoState extends State<TreeOfLifeLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  
  final List<_BranchSpec> _branches = [];
  final List<_LeafSpec> _leaves = [];
  late Path _trunkPath;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.animated
          ? const Duration(seconds: 5)
          : const Duration(milliseconds: 1),
    );

    if (widget.animated) {
      _anim.repeat(reverse: true);
    } else {
      _anim.value = 0.5;
    }
    
    _generateTree();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _generateTree() {
    _branches.clear();
    _leaves.clear();
    
    // Seed kekal supaya bentuk fraktal sentiasa cantik dan stabil setiap kali dimuatkan
    final rnd = math.Random(88); 
    
    const double maxCrownRadius = 38.0;
    const Offset centerCrown = Offset(50, 42);

    // ── 1. BATANG UTAMA (Flared Trunk) ──────────────────────
    // Batang direka sebagai blok solid supaya akar dan dahan bersambung licin
    _trunkPath = Path();
    _trunkPath.moveTo(40, 74); // Pangkal akar paling kiri
    _trunkPath.lineTo(46, 73); 
    _trunkPath.lineTo(54, 73); 
    _trunkPath.lineTo(60, 74); // Pangkal akar paling kanan
    // Lengkung badan kanan naik ke pangkal dahan
    _trunkPath.cubicTo(56, 68, 55, 55, 55, 43); 
    _trunkPath.lineTo(52, 42); 
    _trunkPath.lineTo(48, 42); 
    _trunkPath.lineTo(45, 43); 
    // Lengkung badan kiri turun ke pangkal akar
    _trunkPath.cubicTo(45, 55, 44, 68, 40, 74); 
    _trunkPath.close();

    // ── 2. ALGORITMA FRAKTAL DAHAN (Tahap 1 hingga 5) ───────
    void growBranches(Offset start, double angle, double length, double width, int depth) {
      if (depth > 5) return;
      
      // Lenturan 'S' organik dengan Cubic Bezier
      double a1 = angle + (rnd.nextDouble() - 0.5) * 0.5; 
      Offset end = Offset(
        start.dx + math.cos(a1) * length,
        start.dy + math.sin(a1) * length,
      );

      // Radial Clamping: Paksa hujung dahan masuk ke dalam acuan bulat (Mahkota Pokok)
      double dist = (end - centerCrown).distance;
      if (dist > maxCrownRadius) {
        double pull = dist - maxCrownRadius;
        length = math.max(2.0, length - pull);
        end = Offset(
          start.dx + math.cos(a1) * length,
          start.dy + math.sin(a1) * length,
        );
      }

      // 2 Titik Kawalan untuk lengkungan yang sangat semula jadi
      double curve = (rnd.nextDouble() - 0.5) * length * 0.6;
      Offset ctrl1 = Offset(
        start.dx + math.cos(angle) * (length * 0.4) + math.cos(angle + math.pi/2) * curve,
        start.dy + math.sin(angle) * (length * 0.4) + math.sin(angle + math.pi/2) * curve,
      );
      Offset ctrl2 = Offset(
        end.dx - math.cos(a1) * (length * 0.4) - math.cos(a1 + math.pi/2) * curve,
        end.dy - math.sin(a1) * (length * 0.4) - math.sin(a1 + math.pi/2) * curve,
      );

      _branches.add(_BranchSpec(start, ctrl1, ctrl2, end, width));

      // Hasilkan rimbunan daun pada ranting tahap 4 dan 5
      if (depth >= 4) {
        int leafCount = 2 + rnd.nextInt(3); // 2 hingga 4 daun setiap hujung
        for (int i = 0; i < leafCount; i++) {
          double leafAngle = a1 + (rnd.nextDouble() - 0.5) * 2.5;
          double leafDist = rnd.nextDouble() * 5.0;
          Offset leafPos = Offset(end.dx + math.cos(leafAngle) * leafDist, end.dy + math.sin(leafAngle) * leafDist);
          _leaves.add(_LeafSpec(leafPos, 2.8 + rnd.nextDouble() * 1.5, leafAngle + math.pi/2));
        }
        if (depth == 5) return;
      }

      // Pembiakan cabang dahan (2 dahan per nod)
      int children = 2;
      for (int i = 0; i < children; i++) {
        double spread = 0.45;
        double nextAngle = a1 + (i == 0 ? -spread : spread) + (rnd.nextDouble() - 0.5) * 0.2;
        growBranches(end, nextAngle, length * (0.75 + rnd.nextDouble() * 0.1), width * 0.65, depth + 1);
      }
    }

    // ── 3. ALGORITMA FRAKTAL AKAR (Tahap 1 hingga 3) ────────
    void growRoots(Offset start, double angle, double length, double width, int depth) {
      if (depth > 3) return;
      
      double a1 = angle + (rnd.nextDouble() - 0.5) * 0.3;
      Offset end = Offset(
        start.dx + math.cos(a1) * length,
        start.dy + math.sin(a1) * length,
      );

      Offset ctrl1 = Offset(
        start.dx + math.cos(angle) * (length * 0.4),
        start.dy + math.sin(angle) * (length * 0.4),
      );
      Offset ctrl2 = Offset(
        end.dx - math.cos(a1) * (length * 0.4),
        end.dy - math.sin(a1) * (length * 0.4),
      );

      _branches.add(_BranchSpec(start, ctrl1, ctrl2, end, width));

      for (int i = 0; i < 2; i++) {
        double spread = 0.5;
        double nextAngle = a1 + (i == 0 ? -spread : spread) + (rnd.nextDouble() - 0.5) * 0.2;
        growRoots(end, nextAngle, length * (0.7 + rnd.nextDouble() * 0.2), width * 0.65, depth + 1);
      }
    }

    // Suntik titik punca dahan utama (tepat bersambung dengan atas batang)
    growBranches(const Offset(45, 43), -2.5, 12, 4.0, 1);
    growBranches(const Offset(48, 42), -1.9, 14, 4.5, 1);
    growBranches(const Offset(52, 42), -1.2, 14, 4.5, 1);
    growBranches(const Offset(55, 43), -0.6, 12, 4.0, 1);

    // Suntik titik punca akar utama (tepat bersambung dengan tapak batang)
    growRoots(const Offset(40, 74), 2.4, 9, 3.5, 1);
    growRoots(const Offset(46, 73), 1.8, 10, 4.0, 1);
    growRoots(const Offset(54, 73), 1.3, 10, 4.0, 1);
    growRoots(const Offset(60, 74), 0.7, 9, 3.5, 1);

    // ── 4. KEPADATAN EKSTRA (Fill the Void) ────────────────
    // Tabur dedaun tambahan dalam kanopi supaya siluet luar nampak penuh (± 30 daun)
    for (int i = 0; i < 30; i++) {
      double r = rnd.nextDouble() * maxCrownRadius * 0.85; 
      double a = rnd.nextDouble() * math.pi * 2;
      // Elak daun tumbuh di tengah bawah (kawasan batang)
      if (a > 0 && a < math.pi * 0.8 && a > math.pi * 0.2) continue; 
      
      Offset pos = Offset(centerCrown.dx + math.cos(a) * r, centerCrown.dy + math.sin(a) * r);
      _leaves.add(_LeafSpec(pos, 3.0 + rnd.nextDouble() * 1.5, rnd.nextDouble() * math.pi));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _VectorTreePainter(
            branches: _branches,
            leaves: _leaves,
            trunkPath: _trunkPath,
            progress: _anim.value,
            animated: widget.animated,
          ),
        );
      },
    );
  }
}

// ── PAINTER BERPRESTASI TINGGI ─────────────────────────────────

class _VectorTreePainter extends CustomPainter {
  final List<_BranchSpec> branches;
  final List<_LeafSpec> leaves;
  final Path trunkPath;
  final double progress;
  final bool animated;

  _VectorTreePainter({
    required this.branches,
    required this.leaves,
    required this.trunkPath,
    required this.progress,
    required this.animated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale);

    final Offset center = const Offset(50, 50);
    const double radius = 44.0;

    // 1. Bingkai Bulatan Luar
    final Paint ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep, kGoldHighlight],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, ringPaint);

    // 2. Berus Siluet Pokok Emas
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100))
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ayunan angin lembut keseluruhan pokok bersendi pada pangkal (y=75)
    final double sway = animated ? math.sin(progress * math.pi * 2) * 0.012 : 0.0;

    canvas.save();
    canvas.translate(50, 75);
    canvas.rotate(sway);
    canvas.translate(-50, -75);

    // Lukis Batang Utama
    canvas.drawPath(trunkPath, fillPaint);

    // Lukis Akar dan Dahan (Cubic Beziers)
    for (var b in branches) {
      linePaint.strokeWidth = b.width;
      final Path p = Path()
        ..moveTo(b.start.dx, b.start.dy)
        ..cubicTo(b.ctrl1.dx, b.ctrl1.dy, b.ctrl2.dx, b.ctrl2.dy, b.end.dx, b.end.dy);
      canvas.drawPath(p, linePaint);
    }

    // Lukis Mahkota Daun (Lebih 150 helai)
    for (var leaf in leaves) {
      canvas.save();
      canvas.translate(leaf.position.dx, leaf.position.dy);
      
      // Mikro-animasi: Helaian daun bergetar sedikit mengikut tiupan angin bebas
      double leafSway = animated ? math.sin((progress * 4 * math.pi) + leaf.position.dx) * 0.08 : 0.0;
      canvas.rotate(leaf.rotation + leafSway);
      
      canvas.drawPath(_createAlmondLeafPath(leaf.size), fillPaint);
      canvas.restore();
    }

    canvas.restore(); // Restore sway pokok
    canvas.restore(); // Restore skala kanvas
  }

  // Rekabentuk Helaian Daun Vektor Badam (Organik)
  Path _createAlmondLeafPath(double size) {
    final Path path = Path();
    path.moveTo(0, -size);
    // Cubic bezier mencipta lengkung tepi daun yang montok & tajam di hujung
    path.cubicTo(size, -size * 0.5, size, size * 0.5, 0, size);
    path.cubicTo(-size, size * 0.5, -size, -size * 0.5, 0, -size);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _VectorTreePainter oldDelegate) {
    return animated && oldDelegate.progress != progress;
  }
}

// ── MODEL BANTUAN STRUKTUR POKOK ──────────────────────────────

class _BranchSpec {
  final Offset start;
  final Offset ctrl1;
  final Offset ctrl2;
  final Offset end;
  final double width;

  _BranchSpec(this.start, this.ctrl1, this.ctrl2, this.end, this.width);
}

class _LeafSpec {
  final Offset position;
  final double size;
  final double rotation;

  _LeafSpec(this.position, this.size, this.rotation);
}
