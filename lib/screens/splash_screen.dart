// lib/screens/splash_screen.dart (TENCENT B&W + PARALLEL LOADING)
import 'dart:async';
import 'dart:ui';
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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _flareController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Controller Utama (Entrance)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), 
    );

    // Controller Kilatan Cahaya (Flare)
    _flareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), 
    );

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
    // Jangan letak 'await' di depan supaya animasi jalan serentak!
    final dataLoading = Provider.of<UserModel>(context, listen: false).loadData();

    // 2. JALANKAN ANIMASI TENCENT (Zyamina Studio)
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward(); // BAM!
    
    await Future.delayed(const Duration(milliseconds: 300));
    _flareController.forward(); // SWISH!
    
    // 3. TUNGGU KEADAAN SELESAI
    // Kita tunggu intro habis (min 2.5s) DAN data siap load
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
    // Cek kalau user dah ada Tarikh Lahir (Maksudnya User Lama)
    if (userModel.birthdate == null) {
       nextScreen = const OnboardingDOB(); // User Baru
    } else {
       nextScreen = const HomePage(); // User Lama
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
    _flareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // HITAM PEKAT
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _flareController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _opacityAnim.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO POKOK PUTIH (LITAR)
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: _CyberTreePainter(progress: _mainController.value),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // TEKS PUTIH DENGAN LIGHT SWEEP
                    Stack(
                      children: [
                        // Base Text
                        Text(
                          "ZYAMINA STUDIO",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                            fontFamily: 'Poppins', 
                          ),
                        ),
                        // Light Sweep Overlay
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            final double offset = _flareController.value * 2 - 1;
                            return LinearGradient(
                              begin: Alignment(offset - 0.5, 0),
                              end: Alignment(offset + 0.5, 0),
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white, // KILAT PUTIH
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            "ZYAMINA STUDIO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6.0,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // TAGLINE
                    Text(
                      "DIGITAL CRAFTING.. BISMILLAH",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w300,
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

// PAINTER POKOK LITAR (PUTIH BERSIH)
class _CyberTreePainter extends CustomPainter {
  final double progress;
  _CyberTreePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final Path path = Path();
    
    // Lukis Pokok Geometrik
    path.moveTo(cx, h); 
    path.lineTo(cx, h * 0.3);
    path.moveTo(cx, h * 0.7);
    path.lineTo(cx - w * 0.25, h * 0.6);
    path.lineTo(cx - w * 0.25, h * 0.45); 
    path.moveTo(cx, h * 0.6);
    path.lineTo(cx + w * 0.25, h * 0.5);
    path.lineTo(cx + w * 0.35, h * 0.35); 

    canvas.drawRect(Rect.fromCenter(center: Offset(cx - w * 0.25, h * 0.45), width: 8, height: 8), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + w * 0.35, h * 0.35), width: 8, height: 8), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, h * 0.2), 6, Paint()..color = Colors.white);

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}