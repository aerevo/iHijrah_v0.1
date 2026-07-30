// lib/widgets/iridescent_background.dart
// Latar "minyak atas air" — beberapa gumpalan warna pastel lembut (biru,
// teal, lilac, blush) dikaburkan jadi satu kilauan iridescent yang halus.
// Sengaja diredam (bukan tepu) supaya teks/logo EMAS di atasnya tetap
// menjadi tumpuan utama — latar ni cuma "suasana", bukan pertandingan warna.
//
// Guna di splash_screen.dart & onboarding_screen.dart (menggantikan
// kBgGradient putih-kelabu lama yang buat teks emas nampak pudar/x sepadan).

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class IridescentBackground extends StatelessWidget {
  const IridescentBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dasar cerah neutral (bukan putih penuh — sedikit sejuk)
        Container(color: const Color(0xFFF9FBFD)),

        // Gumpalan warna pastel, dikaburkan jadi satu — kesan "oil on water"
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 65, sigmaY: 65),
          child: Stack(
            children: [
              Positioned(
                top: -70, left: -50,
                child: _blob(240, const Color(0xFFCFE3F5)), // biru langit
              ),
              Positioned(
                top: 60, right: -70,
                child: _blob(280, const Color(0xFFD6F0E8)), // teal lembut
              ),
              Positioned(
                bottom: -90, left: -30,
                child: _blob(300, const Color(0xFFE7E0F6)), // lilac
              ),
              Positioned(
                bottom: 40, right: -50,
                child: _blob(220, const Color(0xFFF6E3EC)), // blush pink
              ),
              Positioned(
                top: 220, left: 90,
                child: _blob(200, const Color(0xFFEEF6E2)), // hijau muda halus
              ),
            ],
          ),
        ),

        // Lapisan cerah nipis di atas — redamkan ketepuan supaya emas
        // (teks/logo) kekal jadi fokus, bukan warna latar
        Container(color: Colors.white.withOpacity(0.22)),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.95),
        ),
      );
}
