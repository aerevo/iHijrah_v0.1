// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import '../models/user_model.dart';
import '../screens/onboarding_screen.dart';
import '../utils/audio_service.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _lineW;
  late Animation<double> _letterSpacing;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));

    _lineW = Tween<double>(begin: 0.0, end: 120.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.3, 0.75, curve: Curves.easeOut)));

    _letterSpacing = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)));

    _ctrl.forward();

    // Play audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });

    // Navigate selepas 3.5 saat
    Timer(const Duration(milliseconds: 3500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = Provider.of<UserModel>(context, listen: false);

    // Pergi onboarding kalau nama kosong ATAU tiada tarikh lahir
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

          // ── Latar ivory lembut ───────────────────────────────
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: kBgGradient),
            ),
          ),

          // ── Konten splash ───────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Logo / ikon
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: kPrimaryGold.withOpacity(0.6), width: 1.5),
                          color: kPrimaryGold.withOpacity(0.08),
                        ),
                        child: const Icon(
                          Icons.cruelty_free_outlined, // placeholder — ganti logo.png
                          color: kPrimaryGold,
                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nama app
                      Text(
                        'iHijrah',
                        style: TextStyle(
                          color: kGoldLight,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Playfair',
                          letterSpacing: _letterSpacing.value,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Garis emas
                      Container(
                        height: 1.5,
                        width: _lineW.value,
                        decoration: BoxDecoration(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
