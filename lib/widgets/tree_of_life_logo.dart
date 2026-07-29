// lib/widgets/tree_of_life_logo.dart
// Lambang "Pokok Hayat" v2 — dijana secara procedural (recursive branching)
// supaya dahan, akar dan daun kelihatan natural & padat macam inspirasi AAA,
// tapi tetap satu CustomPainter (bukan aset gambar).
//
// Timeline animasi "tumbuh" (bila animated:true), total 4 saat:
//   0.0 – 0.6s   : cincin + glow muncul
//   0.6 – 1.6s   : batang tumbuh dari bawah, akar berkembang
//   1.4 – 2.9s   : dahan bercambah (3 peringkat), daun mula muncul
//   2.7 – 3.4s   : seluruh pokok mula melambai lembut
//   3.2 – 4.0s   : kilauan emas menyapu, pokok berhenti statik
// Selepas itu (kalau animated:true) — lambaian angin berterusan +
// kilauan emas berulang setiap kitaran, macam idle premium.
//
// animated:false -> versi pantas (700ms) & statik selepas itu, sesuai
// untuk rel/tempat kekal supaya tak ganggu mata.

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TreeOfLifeLogo extends StatefulWidget {
  final double size;
  final bool animated;
  const TreeOfLifeLogo({Key? key, this.size = 84, this.animated = true})
      : super(key: key);

  @override
  State<TreeOfLifeLogo> createState() => _TreeOfLifeLogoState();
}

class _TreeOfLifeLogoState extends State<TreeOfLifeLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  AnimationController? _loop;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: widget.animated
          ? const Duration(milliseconds: 4000)
          : const Duration(milliseconds: 700),
    )..forward();

    if (widget.animated) {
      _loop = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      );
      _entrance.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loop?.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Listenable merged =
        _loop != null ? Listenable.merge([_entrance, _loop]) : _entrance;

    return AnimatedBuilder(
      animation: merged,
      builder: (context, _) {
        final double introT = _entrance.value; // 0..1 sepanjang 4 saat intro
        final double swayPhase =
            _loop != null ? _loop!.value * 2 * math.pi : 0.0;

        // Kilauan sekali semasa intro (hujung timeline), kemudian berulang
        // secara halus setiap kitaran loop.
        double shimmerProgress = -1;
        if (introT < 1.0) {
          if (introT >= 0.80) {
            shimmerProgress = ((introT - 0.80) / 0.20).clamp(0.0, 1.0);
          }
        } else if (_loop != null) {
          final double lp = _loop!.value % 1.0;
          if (lp < 0.16) shimmerProgress = lp / 0.16;
        }

        return Opacity(
          opacity: (introT < 0.08 ? introT / 0.08 : 1.0).clamp(0.0, 1.0),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TreeOfLifePainter(
              introT: introT,
              swayPhase: swayPhase,
              shimmerProgress: shimmerProgress,
              loopActive: _loop != null,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STRUKTUR POKOK — dijana sekali (seed tetap) supaya bentuk konsisten setiap
// kali logo dilukis, tapi organik (bukan koordinat kaku hardcode).
// ─────────────────────────────────────────────────────────────────────────

class _Seg {
  final Offset start;
  final Offset ctrl;
  final Offset end;
  final double width;
  final double growStart;
  final double growEnd;
  const _Seg(this.start, this.ctrl, this.end, this.width, this.growStart,
      this.growEnd);
}

class _LeafDef {
  final Offset center;
  final double rx;
  final double ry;
  final double rotation;
  final double swaySpeed;
  final double swayAmt;
  final double appearStart;
  final double appearEnd;
  final bool shine;
  final double depthLayer; // 0 = jauh/belakang (kecil, gelap, kabur sikit) .. 1 = dekat/depan (besar, terang)
  const _LeafDef({
    required this.center,
    required this.rx,
    required this.ry,
    required this.rotation,
    required this.swaySpeed,
    required this.swayAmt,
    required this.appearStart,
    required this.appearEnd,
    required this.shine,
    required this.depthLayer,
  });
}

class _TreeData {
  final List<_Seg> branches;
  final List<_Seg> roots;
  final List<_LeafDef> leaves;
  const _TreeData(this.branches, this.roots, this.leaves);
}

class _TreeBlueprint {
  static const Offset trunkBase = Offset(50, 64);
  static const Offset trunkTop = Offset(50, 39);
  static const Offset swayPivot = Offset(50, 60);

  static final _TreeData data = _build();

  static _TreeData _build() {
    final math.Random rnd = math.Random(42); // seed tetap = bentuk konsisten
    final List<_Seg> branches = [];
    final List<_Seg> roots = [];
    final List<_LeafDef> leaves = [];

    // Batang — tebal, sedikit melengkung, tumbuh dulu (0.08–0.30)
    branches.add(_Seg(trunkBase, const Offset(47, 52), trunkTop, 4.4, 0.08, 0.30));

    // Dahan utama — kipas dari hujung batang, memenuhi bahagian atas bulatan
    // (7 dahan, bukan 5 — canopy lagi lebar & padat)
    const List<double> primaryAngles = [
      -2.55, -2.20, -1.88, -1.5708, -1.26, -0.94, -0.60
    ];
    for (final a in primaryAngles) {
      _growBranch(
        rnd,
        branches,
        leaves,
        trunkTop,
        a,
        16,
        1,
        3,
        depthWindows: const [
          [0.26, 0.46],
          [0.40, 0.62],
          [0.54, 0.74],
        ],
        leafWindowStart: 0.62,
        leafWindowSpan: 0.22,
      );
    }

    // Akar — kipas dari pangkal batang ke bawah
    const List<double> rootAngles = [0.70, 1.15, 1.5708, 2.00, 2.45];
    for (final a in rootAngles) {
      _growRoot(
        rnd,
        roots,
        trunkBase,
        a,
        13,
        1,
        2,
        depthWindows: const [
          [0.12, 0.30],
          [0.24, 0.42],
        ],
      );
    }

    // Susun ikut depthLayer (jauh -> dekat) supaya bila dilukis, daun
    // "belakang" jatuh dulu dan daun "depan" bertindih atasnya — bagi rasa
    // kedalaman betul-betul, bukan flat semua sama rata.
    leaves.sort((x, y) => x.depthLayer.compareTo(y.depthLayer));

    return _TreeData(branches, roots, leaves);
  }

  static void _growBranch(
    math.Random rnd,
    List<_Seg> branches,
    List<_LeafDef> leaves,
    Offset start,
    double angle,
    double length,
    int depth,
    int maxDepth, {
    required List<List<double>> depthWindows,
    required double leafWindowStart,
    required double leafWindowSpan,
  }) {
    final double a = angle + (rnd.nextDouble() - 0.5) * 0.18;
    final Offset end = Offset(
      start.dx + math.cos(a) * length,
      start.dy + math.sin(a) * length,
    );
    final Offset ctrl = Offset(
      (start.dx + end.dx) / 2 + math.cos(a + math.pi / 2) * length * 0.18,
      (start.dy + end.dy) / 2 + math.sin(a + math.pi / 2) * length * 0.18,
    );
    final List<double> win =
        depthWindows[math.min(depth - 1, depthWindows.length - 1)];
    final double width = math.max(0.9, 3.0 - depth * 0.75);
    branches.add(_Seg(start, ctrl, end, width, win[0], win[1]));

    if (depth >= maxDepth) {
      // 9–14 daun tiap hujung ranting (dulu cuma 3–5) — canopy jadi rimbun,
      // bukan skeletal. Disebar dalam 2 "lapisan": belakang (kecil/gelap,
      // isi kekosongan) dan depan (besar/terang, bagi tumpuan).
      final int leafCount = 9 + rnd.nextInt(6);
      for (int i = 0; i < leafCount; i++) {
        final double spread = (rnd.nextDouble() - 0.5) * 1.7;
        final double dist = 1.8 + rnd.nextDouble() * 4.2;
        final double leafAngle = a + spread;
        final Offset leafCenter = Offset(
          end.dx + math.cos(leafAngle) * dist,
          end.dy + math.sin(leafAngle) * dist,
        );
        final double appearStart =
            leafWindowStart + rnd.nextDouble() * leafWindowSpan;

        // Lapisan depth: ~40% jadi "belakang" (isi lompang, kecil & gelap),
        // selebihnya "depan" (besar & terang) — bukan semua sama rata flat.
        final double depthLayer =
            rnd.nextDouble() < 0.4 ? rnd.nextDouble() * 0.45 : 0.55 + rnd.nextDouble() * 0.45;
        final double sizeMul = 0.68 + depthLayer * 0.55;

        leaves.add(_LeafDef(
          center: leafCenter,
          rx: (2.3 + rnd.nextDouble() * 1.7) * sizeMul,
          ry: (1.35 + rnd.nextDouble() * 1.05) * sizeMul,
          rotation: leafAngle + math.pi / 2,
          swaySpeed: 0.85 + rnd.nextDouble() * 0.4,
          swayAmt: (0.05 + rnd.nextDouble() * 0.05) * (0.6 + depthLayer * 0.4),
          appearStart: appearStart,
          appearEnd: math.min(0.94, appearStart + 0.10),
          shine: depthLayer > 0.55 && rnd.nextDouble() < 0.35,
          depthLayer: depthLayer,
        ));
      }
      return;
    }

    final double spread = 0.42 + rnd.nextDouble() * 0.12;
    _growBranch(rnd, branches, leaves, end, a - spread, length * 0.72,
        depth + 1, maxDepth,
        depthWindows: depthWindows,
        leafWindowStart: leafWindowStart,
        leafWindowSpan: leafWindowSpan);
    _growBranch(rnd, branches, leaves, end, a + spread, length * 0.72,
        depth + 1, maxDepth,
        depthWindows: depthWindows,
        leafWindowStart: leafWindowStart,
        leafWindowSpan: leafWindowSpan);
  }

  static void _growRoot(
    math.Random rnd,
    List<_Seg> roots,
    Offset start,
    double angle,
    double length,
    int depth,
    int maxDepth, {
    required List<List<double>> depthWindows,
  }) {
    final double a = angle + (rnd.nextDouble() - 0.5) * 0.16;
    final Offset end = Offset(
      start.dx + math.cos(a) * length,
      start.dy + math.sin(a) * length,
    );
    final Offset ctrl = Offset(
      (start.dx + end.dx) / 2 + math.cos(a - math.pi / 2) * length * 0.14,
      (start.dy + end.dy) / 2 + math.sin(a - math.pi / 2) * length * 0.14,
    );
    final List<double> win =
        depthWindows[math.min(depth - 1, depthWindows.length - 1)];
    final double width = math.max(0.7, 2.2 - depth * 0.6);
    roots.add(_Seg(start, ctrl, end, width, win[0], win[1]));

    if (depth >= maxDepth) return;

    final double spread = 0.36 + rnd.nextDouble() * 0.12;
    _growRoot(rnd, roots, end, a - spread, length * 0.68, depth + 1, maxDepth,
        depthWindows: depthWindows);
    _growRoot(rnd, roots, end, a + spread, length * 0.68, depth + 1, maxDepth,
        depthWindows: depthWindows);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PAINTER
// ─────────────────────────────────────────────────────────────────────────

class _TreeOfLifePainter extends CustomPainter {
  final double introT;
  final double swayPhase;
  final double shimmerProgress; // -1 = jangan lukis
  final bool loopActive;

  _TreeOfLifePainter({
    required this.introT,
    required this.swayPhase,
    required this.shimmerProgress,
    required this.loopActive,
  });

  static double _win(double t, double a, double b) {
    if (b <= a) return t >= a ? 1.0 : 0.0;
    return ((t - a) / (b - a)).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);

    const Offset center = Offset(50, 50);
    final Rect fullRect = const Rect.fromLTWH(0, 0, 100, 100);

    // ── Glow lembut di belakang logo ──
    final double glowT = _win(introT, 0.0, 0.25);
    final Paint glowPaint = Paint()
      ..color = kPrimaryGold.withOpacity(0.16 * glowT)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, 34, glowPaint);

    // ── Cincin luar (identiti kekal, dgn pantulan cahaya sweep) ──
    final double ringT = _win(introT, 0.0, 0.14);
    if (ringT > 0) {
      final Paint ringPaint = Paint()
        ..shader = const SweepGradient(
          colors: [kGoldDeep, kGoldHighlight, kGoldMid, kGoldHighlight, kGoldDeep],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 42))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: 46),
        Paint()..color = Colors.black.withOpacity(ringT),
      );
      canvas.drawCircle(center, 42, ringPaint);
      canvas.restore();
    }

    // Gema cincin lembut semasa idle (dekoratif, halus sahaja)
    if (loopActive) {
      for (int i = 0; i < 2; i++) {
        final double phase = (swayPhase / (2 * math.pi) + i * 0.5) % 1.0;
        final double radius = 42 + phase * 6;
        final double op = (1 - phase) * 0.16;
        final Paint echo = Paint()
          ..color = kPrimaryGold.withOpacity(op)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, radius, echo);
      }
    }

    final Paint linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGoldHighlight, kGoldMid, kGoldDeep, kGoldMid, kGoldHighlight],
        stops: [0.0, 0.3, 0.55, 0.8, 1.0],
      ).createShader(fullRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ── Akar (tumbuh dari bawah ke luar) ──
    for (final seg in _TreeBlueprint.data.roots) {
      _drawGrowingSegment(canvas, linePaint, seg, introT, 0);
    }

    // ── Batang + dahan (tumbuh ke atas, kemudian melambai) ──
    final double swayGate = _win(introT, 0.68, 0.85);
    for (final seg in _TreeBlueprint.data.branches) {
      _drawGrowingSegment(canvas, linePaint, seg, introT, swayGate);
    }

    // ── Daun elips organik — muncul satu-satu, bergoyang lembut ──
    // Setiap daun dapat warna/opacity sendiri ikut depthLayer supaya
    // canopy nampak berlapis (belakang gelap+pudar, depan terang+pekat)
    // dan bukan flat rata.
    final Paint shinePaint = Paint()
      ..color = kGoldHighlight.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (final leaf in _TreeBlueprint.data.leaves) {
      final Color leafColor = Color.lerp(kGoldDeep, kGoldHighlight, leaf.depthLayer * 0.85 + 0.1)!;
      final double leafOpacity = 0.55 + leaf.depthLayer * 0.45;
      final Paint leafPaint = Paint()..color = leafColor.withOpacity(leafOpacity);
      _drawLeaf(canvas, leafPaint, shinePaint, leaf, introT, swayGate);
    }

    // ── Kilauan emas menyapu ──
    if (shimmerProgress >= 0) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: 42)));
      final double dx = -70 + shimmerProgress * 140;
      final double dy = -70 + shimmerProgress * 140;
      final double fade = (1 - (shimmerProgress - 0.5).abs() * 2).clamp(0.0, 1.0);
      canvas.translate(50 + dx, 50 + dy);
      canvas.rotate(25 * math.pi / 180);
      final Paint shimmerPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.9 * fade),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(const Rect.fromLTWH(-8, -60, 16, 120));
      canvas.drawRect(const Rect.fromLTWH(-8, -60, 16, 120), shimmerPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawGrowingSegment(
    Canvas canvas,
    Paint sharedPaint,
    _Seg seg,
    double t,
    double swayGate,
  ) {
    final double p = _win(t, seg.growStart, seg.growEnd);
    if (p <= 0) return;

    final Path fullPath = Path()
      ..moveTo(seg.start.dx, seg.start.dy)
      ..quadraticBezierTo(seg.ctrl.dx, seg.ctrl.dy, seg.end.dx, seg.end.dy);

    Path drawPath = fullPath;
    if (p < 1.0) {
      final ui.PathMetrics metrics = fullPath.computeMetrics();
      final Path partial = Path();
      for (final ui.PathMetric metric in metrics) {
        partial.addPath(metric.extractPath(0, metric.length * p), Offset.zero);
      }
      drawPath = partial;
    }

    canvas.save();
    if (swayGate > 0) {
      final double angle = math.sin(swayPhase) * 0.05 * swayGate;
      canvas.translate(_TreeBlueprint.swayPivot.dx, _TreeBlueprint.swayPivot.dy);
      canvas.rotate(angle);
      canvas.translate(-_TreeBlueprint.swayPivot.dx, -_TreeBlueprint.swayPivot.dy);
    }
    sharedPaint.strokeWidth = seg.width;
    canvas.drawPath(drawPath, sharedPaint);
    canvas.restore();
  }

  void _drawLeaf(
    Canvas canvas,
    Paint fillPaint,
    Paint shinePaint,
    _LeafDef leaf,
    double t,
    double swayGate,
  ) {
    final double p = _win(t, leaf.appearStart, leaf.appearEnd);
    if (p <= 0) return;
    final double scale = Curves.easeOutBack.transform(p).clamp(0.0, 1.3);

    canvas.save();
    if (swayGate > 0) {
      final double treeAngle = math.sin(swayPhase) * 0.05 * swayGate;
      canvas.translate(_TreeBlueprint.swayPivot.dx, _TreeBlueprint.swayPivot.dy);
      canvas.rotate(treeAngle);
      canvas.translate(-_TreeBlueprint.swayPivot.dx, -_TreeBlueprint.swayPivot.dy);
    }
    final double leafAngle = swayGate > 0
        ? math.sin(swayPhase * leaf.swaySpeed) * leaf.swayAmt * swayGate
        : 0.0;
    canvas.translate(leaf.center.dx, leaf.center.dy);
    canvas.rotate(leaf.rotation + leafAngle);
    canvas.scale(scale);
    final Rect ovalRect =
        Rect.fromCenter(center: Offset.zero, width: leaf.rx * 2, height: leaf.ry * 2);
    canvas.drawOval(ovalRect, fillPaint);
    if (leaf.shine) {
      canvas.drawOval(ovalRect.deflate(leaf.rx * 0.35), shinePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TreeOfLifePainter old) =>
      old.introT != introT ||
      old.swayPhase != swayPhase ||
      old.shimmerProgress != shimmerProgress ||
      old.loopActive != loopActive;
}
