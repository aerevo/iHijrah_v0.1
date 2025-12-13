// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Perhatikan penggunaan '../' kerana fail ini berada di dalam folder screens
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../home.dart'; // Navigasi ke Home (Sidebar Tepi)
import 'birthdate_prompt_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // Navigasi
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _checkUserAndNavigate();
      }
    });
  }

  void _checkUserAndNavigate() {
    final user = Provider.of<UserModel>(context, listen: false);

    if (user.birthdate != null) {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()), 
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BirthdatePromptScreen()),
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
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond_outlined,
                size: 60,
                color: kPrimaryGold.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
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
