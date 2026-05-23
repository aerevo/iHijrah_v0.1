// lib/widgets/brush_divider.dart
// Garis pisah ala sapuan berus cat — untuk kad harian

import 'package:flutter/material.dart';

class BrushDivider extends StatelessWidget {
  final Color color;
  final double opacity;
  final double height;

  const BrushDivider({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.45,
    this.height = 9,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BrushPainter(
          color: color.withOpacity(opacity),
          shadow: color.withOpacity(opacity * 0.30),
        ),
      ),
    );
  }
}

class _BrushPainter extends CustomPainter {
  final Color color;
  final Color shadow;

  const _BrushPainter({required this.color, required this.shadow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Stroke utama ────────────────────────────────────────────
    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mainPath = Path()
      ..moveTo(w * 0.01, h * 0.52)
      ..cubicTo(
        w * 0.15, h * 0.18,
        w * 0.30, h * 0.82,
        w * 0.48, h * 0.42,
      )
      ..cubicTo(
        w * 0.65, h * 0.08,
        w * 0.80, h * 0.76,
        w * 0.99, h * 0.48,
      );

    canvas.drawPath(mainPath, mainPaint);

    // ── Bayang tipis bawah ───────────────────────────────────────
    final shadowPaint = Paint()
      ..color = shadow
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shadowPath = Path()
      ..moveTo(w * 0.02, h * 0.72)
      ..cubicTo(
        w * 0.18, h * 0.44,
        w * 0.35, h * 0.92,
        w * 0.52, h * 0.60,
      )
      ..cubicTo(
        w * 0.70, h * 0.30,
        w * 0.84, h * 0.88,
        w * 0.98, h * 0.65,
      );

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(_BrushPainter old) =>
      old.color != color || old.shadow != shadow;
}
