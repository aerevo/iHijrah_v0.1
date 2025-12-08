// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../home.dart';
import 'birthdate_prompt_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigasi Selepas 3.5 Saat
    Future.delayed(const Duration(milliseconds: 3500), () {
      _checkUserAndNavigate();
    });
  }

  void _checkUserAndNavigate() {
    final user = Provider.of<UserModel>(context, listen: false);

    // [PEMBAIKAN] Semak 'birthdate'. Jika null, bermakna user belum set tarikh lahir (User Baru).
    // Jika ada birthdate, bermakna profil asas dah lengkap.
    if (user.birthdate != null) {
      // User dah wujud
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage())
      );
    } else {
      // User baru atau data tak lengkap
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BirthdatePromptScreen())
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar Gelap (Cinematic)
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Logo Ikon
              Icon(
                Icons.diamond_outlined,
                size: 60,
                color: kPrimaryGold.withOpacity(0.8),
              ),
              const SizedBox(height: 20),

              // 2. Nama Studio
              const Text(
                "ZYAMINA STUDIO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6.0,
                  fontFamily: 'Poppins',
                ),
              ),

              // 3. Slogan Kecil
              const SizedBox(height: 8),
              const Text(
                "Crafting Digital Barakah",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
