// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import '../models/user_model.dart';
import '../screens/onboarding_screen.dart';
import '../utils/audio_service.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';
import '../widgets/tree_of_life_logo.dart';
import '../widgets/iridescent_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  
  // Animasi Pokok & Latar
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  
  // Animasi Teks Utama (iHijrah & Embun Jiwa)
  late Animation<double> _textOpacity;
  late Animation<double> _lineW;
  late Animation<double> _letterSpacing;

  // Animasi Khas Watermark ZyaMina Tech
  late Animation<double> _watermarkOpacity;
  late Animation<double> _watermarkSlide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    // 1. Fasa Pokok (0.0s - 1.2s)
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.30, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOutBack),
      ),
    );

    // 2. Fasa Teks & Garisan Emas (0.8s - 2.1s)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.20, 0.50, curve: Curves.easeIn),
      ),
    );

    _lineW = Tween<double>(begin: 0.0, end: 130.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _letterSpacing = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.20, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Fasa Watermark ZyaMina Tech (1.8s - 3.2s)
    _watermarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
      ),
    );

    _watermarkSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();

    // Mainkan Audio Intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });

    // Pindah skrin selepas animasi lengkap (4.6s)
    Timer(const Duration(milliseconds: 4600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = Provider.of<UserModel>(context, listen: false);

    final bool needsOnboarding =
        user.name.isEmpty || user.birthdate == null;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            needsOnboarding ? const OnboardingScreen() : const HomePage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBase,
      body: Stack(
        children: [

          // ── 1. Latar Belakang — "oil on water" pastel lembut ──
          const Positioned.fill(child: IridescentBackground()),

          // ── 2. Cahaya Aura Emas Belakang Logo ─────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _logoOpacity.value * 0.65,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kPrimaryGold.withOpacity(0.18),
                        kPrimaryGold.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Kandungan Utama (Pokok + iHijrah + Embun Jiwa) ──
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Pokok Hayat — Vektor Teratur + Animasi Tiupan Angin
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const TreeOfLifeLogo(size: 148, animated: true),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Teks Nama App & Tagline
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MetallicGold(
                          child: Text(
                            'iHijrah',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: _letterSpacing.value,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Garis Penamat Emas
                        Container(
                          height: 1.5,
                          width: _lineW.value,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                kPrimaryGold,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        Text(
                          'EMBUN JIWA',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4.0 + _letterSpacing.value * 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Watermark ZyaMina Tech (Susunan 3 Baris Kemas) ──
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _watermarkOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _watermarkSlide.value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'POWERED BY',
                        style: TextStyle(
                          color: kTextMuted.withOpacity(0.65),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ZyaMina',
                        style: GoogleFonts.montserrat(
                          color: kPrimaryGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tech',
                        style: GoogleFonts.montserrat(
                          color: kTextSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
