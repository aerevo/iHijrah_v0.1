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

// ═══════════════════════════════════════════════════════════════
// LUXURY GOLD ICON — teknik dari fasa asal ("VERSI ORIGINAL - APPROVED")
// ═══════════════════════════════════════════════════════════════
// ShaderMask + LinearGradient terus pada bentuk ikon. TIADA cakera/badge
// bulat, TIADA bezel, TIADA vignette, TIADA specular blob berasingan.
//
// Kenapa lebih "premium" drpd BrushedMetalIcon di bawah:
//  - Restraint. Mata baca "mewah" drpd peralihan WARNA yang licin, bukan
//    drpd lapisan bentuk/bayang yang banyak. Lebih banyak lapisan 3D palsu
//    pada saiz kecil (38-40px) jatuh nampak keruh/bising, bukan mewah.
//  - Bentuk cakera bulat berulang 8x menegak bersaing dgn bulatan lain
//    dlm rel (avatar, slot pokok) — hierarchy visual hilang. Glyph telus
//    tanpa badge biar bentuk ikon sendiri yg tenang, ada ruang negatif.
//  - Palet 5-stop (BF953F/FCF6BA/B38728/FBF5B7/AA771C) ni "classic luxury
//    gold" yang memang teruji — 2 highlight + 1 shadow band cukup bagi
//    kesan "gold foil bersinar" tanpa perlu bina kedalaman 3D secara manual.
//
// Nota: fasa asal duduk atas latar gelap+blur, jadi kontras automatik
// tinggi. Rel sekarang pun dah balik gelap (kGlassRailGradient, lihat
// sidebar.dart), jadi lapisan bayang di bawah ni sebenarnya dah jadi
// hampir tak diperlukan lagi — tapi dikekalkan (opacity rendah je) sbg
// jaring keselamatan kalau widget ni dipakai di latar cerah lain nanti.
class LuxuryGoldIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  // Bila diisi: lukis ikon warna PEJAL ni terus (skip gradient/bayang).
  // Guna utk kes kontras extreme (cth. navy atas pil emas pekat).
  final Color? solidColor;
  // Bila true: guna gradient EMAS MATTE (lebih gelap/pudar) drpd gold
  // terang biasa. Utk beza status aktif/tak-aktif TANPA hilang kilauan
  // sepenuhnya — flat solidColor buang gradient terus, jadi nampak
  // "mati"/suram; matte kekal ada gradient+silau, cuma lebih redup.
  final bool matte;

  const LuxuryGoldIcon({
    Key? key,
    required this.icon,
    this.size = 22,
    this.solidColor,
    this.matte = false,
  }) : super(key: key);

  static const List<Color> goldStops = [
    Color(0xFFBF953F), // Classic Gold (base)
    Color(0xFFFCF6BA), // Ultra Light Gold (silau)
    Color(0xFFB38728), // Dark Metallic Gold (shadow/depth)
    Color(0xFFFBF5B7), // Light Sand Gold (pantulan kedua)
    Color(0xFFAA771C), // Rich Gold (finishing)
  ];

  // Palet sama STRUKTUR (base→silau→bayang→pantulan→finishing), cuma
  // semua tona diturunkan — kekal ada gradient/silau (bukan flat), tapi
  // jelas lebih redup drpd goldStops. Ni yg beza aktif vs tak aktif.
  static const List<Color> matteGoldStops = [
    Color(0xFF6E5220),
    Color(0xFF9B7B34), // silau matte — jauh lebih redup drpd FCF6BA
    Color(0xFF5A4319),
    Color(0xFF8A6B2C),
    Color(0xFF4A3714),
  ];

  @override
  Widget build(BuildContext context) {
    if (solidColor != null) {
      return Icon(icon, size: size, color: solidColor);
    }

    final List<Color> stops = matte ? matteGoldStops : goldStops;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Bayang nipis — legibiliti atas latar cerah sahaja, bukan hiasan
        Transform.translate(
          offset: const Offset(0.6, 1.0),
          child: Icon(icon, size: size, color: Colors.black.withOpacity(0.16)),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: stops,
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ],
    );
  }
}

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
    final double glyphSize = size * 0.44;
    final Color dark  = tones.first;
    final Color mid   = tones.length > 1 ? tones[1] : tones.first;
    final Color light = tones.last;
    final double rim  = size * 0.05; // ketebalan bezel luar

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Bayang jatuh — cakera "timbul" drpd latar (2 lapis: bayang
          //    hitam lembut + bayang tona logam sendiri utk kesan lebih pekat)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: size * 0.20,
                  offset: Offset(0, size * 0.07),
                ),
                BoxShadow(
                  color: dark.withOpacity(0.25),
                  blurRadius: size * 0.06,
                  offset: Offset(0, size * 0.02),
                ),
              ],
            ),
          ),

          // 2. Bezel luar — cincin logam terarah cahaya (terang atas-kiri →
          //    gelap bawah-kanan), jadi rim tepi bila cakera dalam di-inset
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [light, mid, dark],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 3. Cakera dalam — badan logam calar BULAT (SweepGradient, bukan
          //    jalur diagonal keras) + pencahayaan terarah + specular
          Padding(
            padding: EdgeInsets.all(rim),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 3a. Tekstur brush halus — calar bulat kontras rendah,
                  //     macam logam dikilang guna lathe (bukan corak jalur)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _brushedSweep(dark, mid, light),
                    ),
                  ),

                  // 3b. Cahaya terarah (bulatan lembut atas-kiri, bukan
                  //     jalur diagonal keras) — simulasi sumber cahaya tunggal
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.45, -0.55),
                        radius: 1.05,
                        colors: [light.withOpacity(0.55), light.withOpacity(0.0)],
                        stops: const [0.0, 0.75],
                      ),
                    ),
                  ),

                  // 3c. Vignette tepi — gelapkan bucu utk kesan cakera cembung
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.75,
                        colors: [Colors.transparent, dark.withOpacity(0.35)],
                        stops: const [0.65, 1.0],
                      ),
                    ),
                  ),

                  // 3d. Titik specular terang — "hot spot" pantulan cahaya
                  Align(
                    alignment: const Alignment(-0.4, -0.6),
                    child: FractionallySizedBox(
                      widthFactor: 0.42,
                      heightFactor: 0.42,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.65),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bibir highlight halus di tepi cakera dalam
          Padding(
            padding: EdgeInsets.all(rim),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                  width: size * 0.012,
                ),
              ),
            ),
          ),

          // 5. Glyph — "terukir" (emboss halus: bayang bawah + cahaya atas)
          Transform.translate(
            offset: Offset(size * 0.02, size * 0.024),
            child: Icon(icon, size: glyphSize, color: Colors.black.withOpacity(0.50)),
          ),
          Transform.translate(
            offset: Offset(-size * 0.016, -size * 0.016),
            child: Icon(icon, size: glyphSize, color: Colors.white.withOpacity(0.35)),
          ),
          Icon(icon, size: glyphSize, color: glyphColor),
        ],
      ),
    );
  }

  // SweepGradient (360°) mensimulasikan calar halus BULAT/radial — macam
  // logam dikilang guna lathe — bukan jalur diagonal lurus yg nampak macam
  // corak "candy stripe". Kontras rendah antara jalur bersebelahan supaya
  // ia terbaca sbg TEKSTUR permukaan, bukan corak grafik yg jelas.
  Gradient _brushedSweep(Color dark, Color mid, Color light) {
    const int bands = 48;
    final Color base = Color.lerp(mid, light, 0.5)!;
    final List<Color> colors = [];
    final List<double> stops = [];
    for (int i = 0; i <= bands; i++) {
      colors.add(
        i.isEven
            ? Color.lerp(base, light, 0.35)!
            : Color.lerp(base, dark, 0.30)!,
      );
      stops.add(i / bands);
    }
    return SweepGradient(colors: colors, stops: stops);
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
