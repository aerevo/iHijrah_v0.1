// lib/widgets/tree_of_life_logo.dart
// Lambang "Pokok Hayat" — cincin + akar + batang + dahan + kluster daun,
// dilukis terus guna CustomPainter (bukan ikon tekaan). Koordinat asas
// 100x100, sama seperti pratonton HTML yang telah disahkan Tuan.
//
// animated:true  -> lambaian angin + kilauan menyapu + denyut cincin (splash/intro)
// animated:false -> statik, sesuai untuk rel/tempat kekal supaya tak ganggu mata

import 'dart:math' as math;
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
      duration: const Duration(milliseconds: 900),
    )..forward();

    if (widget.animated) {
      _loop = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      )..repeat();
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
    final Listenable merged = _loop != null
        ? Listenable.merge([_entrance, _loop])
        : _entrance;

    return AnimatedBuilder(
      animation: merged,
      builder: (context, _) {
        final double swayPhase =
            _loop != null ? _loop!.value * 2 * math.pi : 0.0;
        final double shimmerProgress =
            _loop != null ? (_loop!.value * 2) % 1.0 : -1.0;
        final double ringProgress = _loop != null ? _loop!.value % 1.0 : -1.0;

        final double ease = Curves.easeOutBack.transform(_entrance.value);

        return Opacity(
          opacity: Curves.easeOut.transform(_entrance.value).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.55 + 0.45 * ease).clamp(0.0, 1.15),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TreeOfLifePainter(
                swayPhase: swayPhase,
                shimmerProgress: shimmerProgress,
                ringProgress: ringProgress,
                showRings: widget.animated,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TreeOfLifePainter extends CustomPainter {
  final double swayPhase;
  final double shimmerProgress; // -1 = jangan lukis
  final double ringProgress; // -1 = jangan lukis
  final bool showRings;

  _TreeOfLifePainter({
    required this.swayPhase,
    required this.shimmerProgress,
    required this.ringProgress,
    required this.showRings,
  });

  static const List<Color> _lineColors = [kGoldHighlight, kGoldMid, kGoldDeep];
  static const List<Color> _fillColors = [
    kGoldHighlight,
    kGoldMid,
    kGoldDeep,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);

    const Offset center = Offset(50, 50);
    final Rect fullRect = const Rect.fromLTWH(0, 0, 100, 100);

    // ── Cincin berdenyut (splash sahaja) ──
    if (showRings && ringProgress >= 0) {
      for (int i = 0; i < 3; i++) {
        final double phase = (ringProgress + i * 0.33) % 1.0;
        final double radius = 30 + phase * 16;
        final double opacity = (1 - phase).clamp(0.0, 1.0) * 0.5;
        final Paint ringPaint = Paint()
          ..color = kPrimaryGold.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(center, radius, ringPaint);
      }
    }

    final Paint linePaint = Paint()
      ..shader = LinearGradient(colors: _lineColors).createShader(fullRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Cincin luar tetap
    linePaint.strokeWidth = 2.2;
    canvas.drawCircle(center, 42, linePaint);

    // ── Akar ──
    linePaint.strokeWidth = 2;
    _curve(canvas, linePaint, const Offset(50, 58), const Offset(40, 68), const Offset(30, 76));
    _curve(canvas, linePaint, const Offset(50, 58), const Offset(60, 68), const Offset(70, 76));
    _curve(canvas, linePaint, const Offset(50, 60), const Offset(50, 72), const Offset(50, 82));
    linePaint.strokeWidth = 1.3;
    _curve(canvas, linePaint, const Offset(50, 63), const Offset(35, 68), const Offset(23, 73));
    _curve(canvas, linePaint, const Offset(50, 63), const Offset(65, 68), const Offset(77, 73));
    linePaint.strokeWidth = 1;
    _curve(canvas, linePaint, const Offset(43, 60), const Offset(33, 65), const Offset(25, 64));
    _curve(canvas, linePaint, const Offset(57, 60), const Offset(67, 65), const Offset(75, 64));
    _curve(canvas, linePaint, const Offset(50, 66), const Offset(44, 74), const Offset(38, 80));
    _curve(canvas, linePaint, const Offset(50, 66), const Offset(56, 74), const Offset(62, 80));

    // ── Batang ──
    linePaint.strokeWidth = 3.6;
    canvas.drawLine(const Offset(50, 63), const Offset(50, 42), linePaint);

    // ── Dahan ──
    linePaint.strokeWidth = 2;
    _curve(canvas, linePaint, const Offset(50, 45), const Offset(40, 32), const Offset(28, 24));
    _curve(canvas, linePaint, const Offset(50, 45), const Offset(60, 32), const Offset(72, 24));
    _curve(canvas, linePaint, const Offset(50, 42), const Offset(50, 28), const Offset(50, 14));
    linePaint.strokeWidth = 1.3;
    _curve(canvas, linePaint, const Offset(50, 40), const Offset(35, 32), const Offset(20, 28));
    _curve(canvas, linePaint, const Offset(50, 40), const Offset(65, 32), const Offset(80, 28));
    linePaint.strokeWidth = 1;
    _curve(canvas, linePaint, const Offset(43, 42), const Offset(33, 36), const Offset(24, 36));
    _curve(canvas, linePaint, const Offset(57, 42), const Offset(67, 36), const Offset(76, 36));

    // ── Kluster daun — bergoyang berasingan ──
    final Paint fillPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: _fillColors,
      ).createShader(fullRect);

    _swayCluster(canvas, fillPaint, pivot: const Offset(28, 24), speedMul: 1.0, dots: const [
      _Dot(Offset(28, 24), 7.0),
      _Dot(Offset(20, 28), 5.0),
      _Dot(Offset(24, 36), 4.0),
      _Dot(Offset(16, 33), 3.5),
    ]);
    _swayCluster(canvas, fillPaint, pivot: const Offset(72, 24), speedMul: 1.08, dots: const [
      _Dot(Offset(72, 24), 7.0),
      _Dot(Offset(80, 28), 5.0),
      _Dot(Offset(76, 36), 4.0),
      _Dot(Offset(84, 33), 3.5),
    ]);
    _swayCluster(canvas, fillPaint, pivot: const Offset(50, 15), speedMul: 0.95, dots: const [
      _Dot(Offset(50, 14), 8.0),
      _Dot(Offset(38, 18), 5.5),
      _Dot(Offset(62, 18), 5.5),
      _Dot(Offset(50, 26), 6.5),
    ]);

    // ── Kilauan menyapu ──
    if (shimmerProgress >= 0 && shimmerProgress < 0.45) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: 43)));
      final double travel = shimmerProgress / 0.45;
      final double dx = -70 + travel * 140;
      final double dy = -70 + travel * 140;
      final double fade = (1 - (travel - 0.5).abs() * 2).clamp(0.0, 1.0);
      canvas.translate(50 + dx, 50 + dy);
      canvas.rotate(25 * math.pi / 180);
      final Paint shimmerPaint = Paint()..color = Colors.white.withOpacity(0.85 * fade);
      canvas.drawRect(const Rect.fromLTWH(-6, -60, 12, 120), shimmerPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _curve(Canvas canvas, Paint paint, Offset start, Offset control, Offset end) {
    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  void _swayCluster(
    Canvas canvas,
    Paint paint, {
    required Offset pivot,
    required double speedMul,
    required List<_Dot> dots,
  }) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    final double angle = math.sin(swayPhase * speedMul) * 0.045; // ~2.5 darjah
    canvas.rotate(angle);
    canvas.translate(-pivot.dx, -pivot.dy);
    for (final _Dot d in dots) {
      canvas.drawCircle(d.offset, d.radius, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TreeOfLifePainter old) =>
      old.swayPhase != swayPhase ||
      old.shimmerProgress != shimmerProgress ||
      old.ringProgress != ringProgress;
}

class _Dot {
  final Offset offset;
  final double radius;
  const _Dot(this.offset, this.radius);
}
