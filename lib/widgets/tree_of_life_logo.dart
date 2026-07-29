// lib/widgets/tree_of_life_logo.dart
// Vektor Pokok Hayat Teratur (Clean Vector Silhouette Geometry)
// Menggunakan pemalar warna teras dari constants.dart

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

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.animated ? const Duration(seconds: 5) : const Duration(milliseconds: 1),
    );

    if (widget.animated) {
      _anim.repeat(reverse: true);
    } else {
      _anim.value = 0.5;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _VectorTreePainter(
            progress: _anim.value,
            animated: widget.animated,
          ),
        );
      },
    );
  }
}

// ── PAINTER VEKTOR BERSIH ─────────────────────────────────────

class _VectorTreePainter extends CustomPainter {
  final double progress;
  final bool animated;

  _VectorTreePainter({required this.progress, required this.animated});

  @override
  void paint(Canvas canvas, Size size) {
    // Skala kanvas berdasarkan saiz 100x100
    final double scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale);

    final Offset center = const Offset(50, 50);
    final double radius = 44.0;

    // 1. Bingkai Bulatan Luar
    final Paint ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep, kGoldHighlight],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawCircle(center, radius, ringPaint);

    // 2. Cat Utama untuk Siluet Pokok Emas
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

    // Tiupan angin lembut untuk animasi
    final double sway = animated ? math.sin(progress * math.pi * 2) * 0.015 : 0.0;

    canvas.save();
    canvas.translate(50, 68);
    canvas.rotate(sway);
    canvas.translate(-50, -68);

    // ── LUKIS BATANG UTAMA (Semulajadi & Mekar di Pangkal) ──────
    final Path trunkPath = Path();
    // Pangkal kiri -> Teras -> Pangkal kanan
    trunkPath.moveTo(43, 68);
    trunkPath.cubicTo(46, 62, 47, 54, 48, 46);
    trunkPath.lineTo(52, 46);
    trunkPath.cubicTo(53, 54, 54, 62, 57, 68);
    trunkPath.cubicTo(52, 70, 48, 70, 43, 68);
    trunkPath.close();
    canvas.drawPath(trunkPath, fillPaint);

    // ── LUKIS DAHAN BERSTRUKTUR (Simetri & Melengkung) ──────────
    final List<_BranchSpec> branches = [
      // Dahan Utama Kiri & Kanan
      _BranchSpec(const Offset(48.5, 48), const Offset(36, 40), const Offset(24, 34), 3.5),
      _BranchSpec(const Offset(51.5, 48), const Offset(64, 40), const Offset(76, 34), 3.5),
      
      // Cabang Atas Kiri & Kanan
      _BranchSpec(const Offset(49, 46), const Offset(42, 34), const Offset(32, 22), 2.8),
      _BranchSpec(const Offset(51, 46), const Offset(58, 34), const Offset(68, 22), 2.8),
      
      // Dahan Tengah Tinggi
      _BranchSpec(const Offset(50, 46), const Offset(48, 30), const Offset(44, 16), 2.5),
      _BranchSpec(const Offset(50, 46), const Offset(52, 30), const Offset(56, 16), 2.5),

      // Ranting Sub-Dahan
      _BranchSpec(const Offset(36, 40), const Offset(28, 44), const Offset(18, 46), 1.8),
      _BranchSpec(const Offset(64, 40), const Offset(72, 44), const Offset(82, 46), 1.8),
      _BranchSpec(const Offset(42, 34), const Offset(34, 28), const Offset(22, 26), 1.8),
      _BranchSpec(const Offset(58, 34), const Offset(66, 28), const Offset(78, 26), 1.8),
    ];

    for (var b in branches) {
      linePaint.strokeWidth = b.width;
      final Path p = Path()
        ..moveTo(b.start.dx, b.start.dy)
        ..quadraticBezierTo(b.control.dx, b.control.dy, b.end.dx, b.end.dy);
      canvas.drawPath(p, linePaint);
    }

    // ── LUKIS AKAR BERSENI (Melengkung menyentuh Bingkai) ───────
    final List<_BranchSpec> roots = [
      // Akar Tengah Utama
      _BranchSpec(const Offset(47, 68), const Offset(44, 78), const Offset(42, 88.5), 2.5),
      _BranchSpec(const Offset(53, 68), const Offset(56, 78), const Offset(58, 88.5), 2.5),
      
      // Akar Sisi Kiri
      _BranchSpec(const Offset(44, 68), const Offset(34, 76), const Offset(24, 82), 2.2),
      _BranchSpec(const Offset(43, 68), const Offset(28, 72), const Offset(16, 74), 1.8),

      // Akar Sisi Kanan
      _BranchSpec(const Offset(56, 68), const Offset(66, 76), const Offset(76, 82), 2.2),
      _BranchSpec(const Offset(57, 68), const Offset(72, 72), const Offset(84, 74), 1.8),
    ];

    for (var r in roots) {
      linePaint.strokeWidth = r.width;
      final Path p = Path()
        ..moveTo(r.start.dx, r.start.dy)
        ..quadraticBezierTo(r.control.dx, r.control.dy, r.end.dx, r.end.dy);
      canvas.drawPath(p, linePaint);
    }

    // ── LUKIS DAUN TAJAM BERGUSAN (Almond Vector Leaves) ────────
    final List<_LeafSpec> leafClusters = _generateCleanLeafClusters();

    for (var leaf in leafClusters) {
      canvas.save();
      canvas.translate(leaf.position.dx, leaf.position.dy);
      canvas.rotate(leaf.rotation);

      final Path leafPath = _createAlmondLeafPath(leaf.size);
      canvas.drawPath(leafPath, fillPaint);
      canvas.restore();
    }

    canvas.restore(); // Restore Sway
    canvas.restore(); // Restore Scale
  }

  // Rekabentuk Helaian Daun Vektor Badam Tepat
  Path _createAlmondLeafPath(double size) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size * 0.5, -size * 0.45, size, 0);
    path.quadraticBezierTo(size * 0.5, size * 0.45, 0, 0);
    path.close();
    return path;
  }

  // Menjana Kedudukan Daun yang Teratur dan Terpisah Tepat
  List<_LeafSpec> _generateCleanLeafClusters() {
    final List<_LeafSpec> leaves = [];

    // Format: Offset(x, y), Saiz, Sudut Radian
    void addPair(double x, double y, double baseAngle, double size) {
      leaves.add(_LeafSpec(Offset(x, y), size, baseAngle - 0.5));
      leaves.add(_LeafSpec(Offset(x, y), size, baseAngle + 0.5));
      leaves.add(_LeafSpec(Offset(x, y), size * 0.85, baseAngle));
    }

    // Gugusan Kanopi Atas (Top Crown)
    addPair(44, 16, -math.pi / 2, 4.5);
    addPair(56, 16, -math.pi / 2, 4.5);
    addPair(50, 14, -math.pi / 2, 5.0);

    // Gugusan Atas Kiri & Kanan
    addPair(32, 22, -2.2, 4.2);
    addPair(68, 22, -0.9, 4.2);
    addPair(22, 26, -2.5, 4.0);
    addPair(78, 26, -0.6, 4.0);

    // Gugusan Tengah Kiri & Kanan
    addPair(24, 34, -2.6, 4.0);
    addPair(76, 34, -0.5, 4.0);
    addPair(18, 46, -2.9, 3.8);
    addPair(82, 46, -0.2, 3.8);

    // Hiasan Isian Kanopi Luar (Menyelusuri Cincin Bulatan)
    const int outerCount = 16;
    for (int i = 0; i < outerCount; i++) {
      double angle = -math.pi + (i * (math.pi / (outerCount - 1)));
      // Abaikan bahagian bawah bulatan
      if (angle > -0.25 || angle < -math.pi + 0.25) continue;

      double lx = 50 + math.cos(angle) * 40.5;
      double ly = 50 + math.sin(angle) * 40.5;
      leaves.add(_LeafSpec(Offset(lx, ly), 3.6, angle + math.pi / 2));
    }

    return leaves;
  }

  @override
  bool shouldRepaint(covariant _VectorTreePainter oldDelegate) {
    return animated && oldDelegate.progress != progress;
  }
}

// ── MODEL BANTUAN ─────────────────────────────────────────────

class _BranchSpec {
  final Offset start;
  final Offset control;
  final Offset end;
  final double width;

  _BranchSpec(this.start, this.control, this.end, this.width);
}

class _LeafSpec {
  final Offset position;
  final double size;
  final double rotation;

  _LeafSpec(this.position, this.size, this.rotation);
}
