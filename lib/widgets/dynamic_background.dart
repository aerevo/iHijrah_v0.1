// lib/widgets/dynamic_background.dart
// Latar corak geometri — lukis Flutter CustomPainter, ZERO assets

import 'dart:math' as math;
import 'package:flutter/material.dart';

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IslamicPatternPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  // ── WARNA TEMA: putih, kelabu, biru muda ──────────────────
  static const Color _bg         = Color(0xFFF4F7FA); // biru muda sangat pucat
  static const Color _gridLine   = Color(0xFFDDE5EE); // kelabu biru
  static const Color _circle1    = Color(0xFFCFDCEC); // biru muda
  static const Color _circle2    = Color(0xFFE8EEF5); // putih kebiruan
  static const Color _accent     = Color(0xFFB8CCDE); // biru kelabu
  static const Color _dotColor   = Color(0xFFAFC5D8); // titik biru

  @override
  void paint(Canvas canvas, Size size) {
    // 1. BASE BACKGROUND
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bg,
    );

    // 2. GRID LINES HALUS — bersilang diagonal
    _drawGrid(canvas, size);

    // 3. CORAK BULATAN BERTINDIH — Islamic geometric feel
    _drawCirclePattern(canvas, size);

    // 4. TITIK-TITIK HALUS
    _drawDots(canvas, size);

    // 5. AMBIENT GRADIENT BAWAH — supaya feed card nampak float
    _drawBottomFade(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gridLine
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const spacing = 36.0;

    // Grid horizontal
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Grid diagonal kiri-kanan
    for (double x = -size.height; x < size.width + size.height; x += spacing * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint..color = _gridLine.withOpacity(0.5),
      );
    }
  }

  void _drawCirclePattern(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = _circle1.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paint2 = Paint()
      ..color = _circle2.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Grid bulatan berulang
    const r = 28.0;
    const gap = 70.0;

    for (double x = 0; x < size.width + gap; x += gap) {
      for (double y = 0; y < size.height + gap; y += gap) {
        final offset = (x / gap).floor().isOdd ? gap / 2 : 0.0;
        final center = Offset(x, y + offset);

        // Bulatan isi — sangat pudar
        canvas.drawCircle(center, r * 0.6, paint2);

        // Bulatan garisan luar
        canvas.drawCircle(center, r, paint1);

        // Petal kecil dalam — Islamic rosette
        for (int i = 0; i < 6; i++) {
          final angle = (i * math.pi * 2) / 6;
          final px = center.dx + r * 0.55 * math.cos(angle);
          final py = center.dy + r * 0.55 * math.sin(angle);
          canvas.drawCircle(
            Offset(px, py),
            r * 0.22,
            Paint()
              ..color = _accent.withOpacity(0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8,
          );
        }
      }
    }
  }

  void _drawDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _dotColor.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  void _drawBottomFade(Canvas canvas, Size size) {
    // Gradient lembut dari bawah — bagi depth kepada feed
    final rect = Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFD6E4F0).withOpacity(0.3),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
