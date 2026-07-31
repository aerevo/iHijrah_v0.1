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

// ─────────────────────────────────────────────────────────────────────────
// BRUSHED METAL DISC — cakera logam bulat bercalar (brushed) + kilauan
// diagonal terang + glyph "terukir". Gaya ni beza dari MetallicIcon di atas
// (yg leper/glossy warna) — ni rujukan "3D chrome button" (cakera logam
// pekat, calar diagonal, sangat reflektif).
// ─────────────────────────────────────────────────────────────────────────

class BrushedMetalIcon extends StatelessWidget {
  final IconData icon;
  final double size; // saiz keseluruhan cakera
  final List<Color> tones; // [gelap, pertengahan, terang] logam
  final Color glyphColor;

  const BrushedMetalIcon({
    Key? key,
    required this.icon,
    required this.tones,
    this.size = 40,
    this.glyphColor = const Color(0xFF2B2015),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double glyphSize = size * 0.46;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bayang jatuh — cakera "timbul" drpd latar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.26),
                  blurRadius: size * 0.16,
                  offset: Offset(0, size * 0.05),
                ),
              ],
            ),
          ),

          // Badan logam bercalar — banyak jalur berselang-seli mensimulasi
          // tekstur "brushed metal" diagonal
          ClipOval(
            child: Container(
              decoration: BoxDecoration(gradient: _brushedGradient()),
            ),
          ),

          // Kilauan diagonal terang (specular sweep) — ciri utama gaya "chrome"
          ClipOval(
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                width: size * 1.7,
                height: size * 0.5,
                margin: EdgeInsets.only(top: -size * 0.08),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Rim gelap (bevel tepi) — beri kesan cakera padat
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tones.first.withOpacity(0.6),
                width: size * 0.035,
              ),
            ),
          ),

          // Glyph — "terukir" (emboss halus: bayang bawah + cahaya atas)
          Transform.translate(
            offset: Offset(size * 0.018, size * 0.02),
            child: Icon(icon, size: glyphSize, color: Colors.black.withOpacity(0.45)),
          ),
          Transform.translate(
            offset: Offset(-size * 0.014, -size * 0.014),
            child: Icon(icon, size: glyphSize, color: Colors.white.withOpacity(0.30)),
          ),
          Icon(icon, size: glyphSize, color: glyphColor),
        ],
      ),
    );
  }

  Gradient _brushedGradient() {
    final Color dark = tones.first;
    final Color mid = tones.length > 1 ? tones[1] : tones.first;
    final Color light = tones.last;

    const int bands = 14;
    final List<Color> colors = [];
    final List<double> stops = [];
    for (int i = 0; i <= bands; i++) {
      final double t = i / bands;
      colors.add(
        i.isEven
            ? Color.lerp(mid, light, 0.45)!
            : Color.lerp(mid, dark, 0.4)!,
      );
      stops.add(t);
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
    );
  }
}

// ── Set tona logam bercalar (utk BrushedMetalIcon) ─────────────
class BrushedMetalTones {
  static const List<Color> gold = [
    Color(0xFF7A5A16), Color(0xFFC79A38), Color(0xFFF3DFA0),
  ];
  static const List<Color> navy = [
    Color(0xFF0E2444), Color(0xFF1B3A63), Color(0xFF7B96C4),
  ];
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
