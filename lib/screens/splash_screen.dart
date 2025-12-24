// lib/screens/splash_screen.dart (LOGIC CHECK ADDED)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import '../models/user_model.dart'; // Import Model
import '../screens/onboarding_screen.dart'; // Import Screen Baru
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), 
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _spacingAnim = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );

    _lineAnim = Tween<double>(begin: 0.0, end: 150.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });

    // Cek User Selepas 4 Saat
    Timer(const Duration(seconds: 4), () {
      _checkUserAndNavigate();
    });
  }

  // ✅ FUNGSI BARU: Logic Semakan
  void _checkUserAndNavigate() {
    final user = Provider.of<UserModel>(context, listen: false);
    
    // Tentukan Destinasi
    // Kalau Nama kosong ATAU Tarikh Lahir tiada -> Pergi Onboarding
    // Kalau semua ada -> Pergi Home
    Widget destination;
    
    if (user.name.isEmpty || user.hijriDOB == null || user.hijriDOB!.isEmpty) {
      destination = const OnboardingScreen();
    } else {
      destination = const HomePage();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1200),
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
      backgroundColor: Colors.black, 
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnim.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ZYAMINA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2.0 + _spacingAnim.value,
                      fontFamily: 'Roboto', 
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 2,
                    width: _lineAnim.value,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "STUDIO",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w300, 
                      letterSpacing: 8.0 + _spacingAnim.value, 
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
