// lib/screens/splash_screen.dart (FIXED & FINAL)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';
import 'tracker_screen.dart';
import 'birthdate_prompt_screen.dart'; // ✅ DIPERBETULKAN (Nama fail betul)
import '../utils/premium_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup Animasi Premium
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );

    _controller.forward();

    // Timer Navigasi
    Timer(const Duration(seconds: 3), _checkUserAndNavigate);
  }

  void _checkUserAndNavigate() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    
    // Semak jika data user (tarikh lahir Hijrah) sudah wujud
    if (userModel.hijriDOB != null && userModel.hijriDOB!.isNotEmpty) {
      // User lama -> Terus ke Home
      Navigator.of(context).pushReplacement(PremiumRoute.createRoute(const TrackerScreen()));
    } else {
      // User baru -> Setup Tarikh Lahir
      // ✅ DIPERBETULKAN: Menggunakan nama kelas yang betul 'BirthdatePromptScreen'
      Navigator.of(context).pushReplacement(PremiumRoute.createRoute(const BirthdatePromptScreen()));
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
      backgroundColor: kBackgroundDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO / ICON DENGAN GLOW
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryGold.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10
                          )
                        ]
                      ),
                      child: const Icon(Icons.diamond, size: 80, color: kPrimaryGold),
                    ),
                    const SizedBox(height: 30),
                    
                    // TAJUK APP (METALLIC GOLD)
                    const MetallicGold(
                      child: Text(
                        "iHijrah",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair',
                          letterSpacing: 2
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Embun Jiwa",
                      style: TextStyle(
                        color: kTextSecondary.withOpacity(0.7),
                        fontSize: 16,
                        letterSpacing: 4
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}