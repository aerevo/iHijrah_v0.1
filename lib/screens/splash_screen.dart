// lib/screens/splash_screen.dart (TENCENT B&W + POKOK MELAMBAI)
import 'dart:async';
import 'dart:ui';
import 'dart:math'; // Untuk fungsi sin
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import 'onboarding_dob.dart';
import '../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Guna TickerProviderStateMixin untuk animasi goyangan pokok & intro
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController; // Controller untuk goyangan
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Controller 1: Entrance (1.0s)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), 
    );

    // Controller 2: Goyangan (Looping)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Animasi "Impact" (Zoom In Laju)
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 5.0, end: 0.9).chain(CurveTween(curve: Curves.easeInExpo)), 
        weight: 30
      ), 
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), 
        weight: 70
      ), 
    ]).animate(_mainController);

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.3))
    );

    _runSequence();
  }

  void _runSequence() async {
    // 1. MULA LOAD DATA (Background Process)
    final dataLoading = Provider.of<UserModel>(context, listen: false).loadData();

    // 2. JALANKAN ANIMASI TENCENT (Zyamina Studio)
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward(); // BAM!
    // Tidak perlu tunggu flare controller, pokok sudah bergoyang dengan waveController
    
    // 3. TUNGGU KEADAAN SELESAI
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)), // Wajib tunggu 2.5s intro
      dataLoading, // Tunggu data siap
    ]);
    
    // 4. SEMUA DAH SIAP -> NAVIGATE
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final userModel = Provider.of<UserModel>(context, listen: false);
    
    Widget nextScreen;
    if (userModel.birthdate == null) {
       nextScreen = const OnboardingDOB();
    } else {
       nextScreen = const HomePage();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        )
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose(); // Wajib dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // HITAM PEKAT
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController, // Hanya guna mainController untuk scale/opacity
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _opacityAnim.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO POKOK MELAMBAI
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          // Guna Painter Pokok Goyang (Sama dengan onboarding)
                          return CustomPaint(
                            painter: _WavingCyberTreePainter(animation: _waveController),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // TEKS ZYAMINA STUDIO (Static B&W)
                    const Text(
                      "ZYAMINA STUDIO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "DIGITAL CRAFTING.. BISMILLAH",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Poppins',
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

// === POKOK PENCANTUM LITAR YANG BERGOYANG (CUSTOM PAINTER) ===
class _WavingCyberTreePainter extends CustomPainter {
  final Animation<double> animation;

  _WavingCyberTreePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double windFactor = sin(animation.value * 2 * pi) * 10;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    final Paint fillPaint = Paint()..color = Colors.white;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double windShift = windFactor * (h/w) * 0.1;

    final Path path = Path();
    
    // 1. Batang Pokok
    path.moveTo(cx, h); 
    path.lineTo(cx + windShift, h * 0.3);

    // 2. Dahan Kiri
    path.moveTo(cx + windShift * 0.5, h * 0.7);
    path.lineTo(cx - w * 0.25 + windShift, h * 0.6);
    path.lineTo(cx - w * 0.25 + windShift, h * 0.45);

    // 3. Dahan Kanan
    path.moveTo(cx + windShift * 0.4, h * 0.6);
    path.lineTo(cx + w * 0.25 + windShift, h * 0.5);
    path.lineTo(cx + w * 0.35 + windShift, h * 0.35);

    canvas.drawPath(path, paint);

    // 4. Nodes
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - w * 0.25 + windShift, h * 0.45), width: 8, height: 8), fillPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + w * 0.35 + windShift, h * 0.35), width: 8, height: 8), fillPaint);
    canvas.drawCircle(Offset(cx + windShift, h * 0.2), 6, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _WavingCyberTreePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}