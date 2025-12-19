// lib/screens/splash_screen.dart (ZYAMINA STUDIO - TENCENT STYLE)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import '../utils/audio_service.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _spacingAnim;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi (Total 3.5 Saat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), 
    );

    // Animasi Pudar Masuk (Fade In)
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // Animasi Jarak Huruf (Cinematic Spacing) - Mula rapat, kemudian renggang sikit
    _spacingAnim = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );

    // Animasi Garisan Putih (Melebar)
    _lineAnim = Tween<double>(begin: 0.0, end: 150.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    // 2. Mula Animasi & Audio
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mainkan bunyi intro (Boom effect jika ada, atau intro sedia ada)
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });

    // 3. Pindah ke Home selepas 4 saat
    Timer(const Duration(seconds: 4), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Transisi Pudar (Fade) yang smooth ke alam semulajadi
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1200), // Masuk perlahan
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // HITAM LEGAM (Tencent Style)
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnim.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. ZYAMINA (BOLD & BIG)
                  Text(
                    "ZYAMINA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900, // Tebal Maksimum
                      letterSpacing: 2.0 + _spacingAnim.value, // Huruf bergerak
                      fontFamily: 'Roboto', // Atau font 'Impact' jika ada
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // 2. GARISAN PUTIH (Animated Width)
                  Container(
                    height: 2,
                    width: _lineAnim.value,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 10),

                  // 3. STUDIO (SPACED OUT)
                  Text(
                    "STUDIO",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w300, // Nipis
                      letterSpacing: 8.0 + _spacingAnim.value, // Jarak luas
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
