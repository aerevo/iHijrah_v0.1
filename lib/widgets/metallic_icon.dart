// lib/widgets/metallic_icon.dart
// Ikon berlapis logam — gradient terus pada bentuk ikon (bukan kad latar),
// guna teknik ShaderMask sama seperti MetallicGold, jadi risiko rendah
// (ikon sendiri sudah terbukti wujud/render betul, cuma diwarna semula).

import 'package:flutter/material.dart';

class MetallicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> gradient;

  const MetallicIcon({
    Key? key,
    required this.icon,
    required this.gradient,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bayang dalam — beri kesan kedalaman halus
          Transform.translate(
            offset: const Offset(0, 1.2),
            child: Icon(icon, size: size, color: Colors.black.withOpacity(0.22)),
          ),
          // Isi gradient logam
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(icon, size: size, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Set gradient sedia guna, satu setiap tab rel ──
class MetallicPalettes {
  static const List<Color> gold = [
    Color(0xFFFFF6D8), Color(0xFFE0AC2E), Color(0xFF6B4A0E),
  ];
  static const List<Color> navy = [
    Color(0xFFC9DAF5), Color(0xFF3B6FE0), Color(0xFF122A5E),
  ];
  static const List<Color> emerald = [
    Color(0xFFC8F5E4), Color(0xFF159E71), Color(0xFF0A3D2C),
  ];
  static const List<Color> bronze = [
    Color(0xFFF3DFB0), Color(0xFFB8823A), Color(0xFF4A3410),
  ];
}
