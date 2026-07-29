// lib/widgets/metallic_icon.dart
// Ikon berlapis logam v2 — gaya "3D glossy chrome" (rujukan: 3D Glossy Icons,
// Studio 2am / Creative Market). Semua dilukis guna widget asas Flutter
// sahaja (tiada aset gambar), supaya kekal ringan & senang tukar warna ikut
// tab.
//
// Lapisan (dari belakang ke depan):
//   1. Halo lembut     — beri kesan "bersinar"/neon di belakang ikon
//   2. Bayang jatuh     — kedalaman, ikon gelap sedikit tersasar ke bawah
//   3. Bezel gelap      — ikon sama tapi sedikit lebih besar & gelap,
//                         beri kesan "bucu timbul" (emboss) di sekeliling
//   4. Badan utama      — gradient radial dari putih (specular) → warna
//                         terang → warna gelap, cahaya datang dari
//                         penjuru atas-kiri macam refleksi kaca sebenar
//
// glossy:false -> gaya lama (leper, gradient linear tunggal), dikekalkan
// sebagai fallback kalau-kalau perlu versi ringkas di tempat lain.

import 'package:flutter/material.dart';

class MetallicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> gradient; // [terang, pertengahan, gelap]
  final bool glossy;
  final bool showGlow;

  const MetallicIcon({
    Key? key,
    required this.icon,
    required this.gradient,
    this.size = 20,
    this.glossy = true,
    this.showGlow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!glossy) {
      return _legacyFlat();
    }

    final Color glow = gradient.length > 1 ? gradient[1] : gradient.first;
    final Color deep = gradient.last;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── 1. Halo — kesan bersinar di belakang ──
          if (showGlow)
            Container(
              width: size * 1.35,
              height: size * 1.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [glow.withOpacity(0.30), glow.withOpacity(0.0)],
                ),
              ),
            ),

          // ── 2. Bayang jatuh — kedalaman ──
          Transform.translate(
            offset: Offset(0, size * 0.06),
            child: Icon(icon, size: size, color: Colors.black.withOpacity(0.30)),
          ),

          // ── 3. Bezel gelap — bucu "timbul" di sekeliling bentuk ikon ──
          Icon(icon, size: size + size * 0.09, color: deep.withOpacity(0.85)),

          // ── 4. Badan utama — gradient radial + specular dibakar terus
          //      dalam shader (elak isu blend-mode antara lapisan berasingan,
          //      lebih selamat & konsisten hasilnya) ──
          ShaderMask(
            shaderCallback: (bounds) => RadialGradient(
              center: const Alignment(-0.5, -0.6),
              radius: 1.15,
              colors: [
                Colors.white,
                gradient.first,
                gradient.length > 1 ? gradient[1] : gradient.first,
                gradient.last,
              ],
              stops: const [0.0, 0.22, 0.6, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(icon, size: size, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _legacyFlat() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, 1.2),
            child: Icon(icon, size: size, color: Colors.black.withOpacity(0.22)),
          ),
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
// (nilai sama seperti asal — tak diubah supaya warna tab kekal sama,
// cuma cara render ikon yang baru lebih glossy)
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
