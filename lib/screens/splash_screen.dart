import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _glitchAnim;

  @override
  void initState() {
    super.initState();
    
    // Setup Fullscreen Immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 1. Scale dari kecil ke besar (Impact)
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutExpo)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
    ]).animate(_mainController);

    // 2. Opacity pantas
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.3)),
    );

    // Mula animasi & Navigasi
    _mainController.forward();
    
    // TODO: Masukkan AudioService.playIntro() di sini untuk bunyi 'BASS DROP'
    
    Future.delayed(const Duration(milliseconds: 4000), () {
       // Reset UI overlay
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
       Navigator.of(context).pushReplacement(
         PageRouteBuilder(
           pageBuilder: (_, __, ___) => const HomePage(),
           transitionDuration: const Duration(milliseconds: 800),
           transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
         )
       );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            // Efek bergegar sedikit (Glitch vibe)
            double shake = (_mainController.value > 0.8) ? 0 : (0.5 - _mainController.value).abs() * 5;
            
            return Transform.translate(
              offset: Offset(shake * (DateTime.now().millisecond % 2 == 0 ? 1 : -1), 0),
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Opacity(
                  opacity: _opacityAnim.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO EMAS METALIK
                      const MetallicGold(
                        child: Icon(Icons.diamond_outlined, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      // TEXT ZYAMINA STUDIO (Cinematic Spacing)
                      Text(
                        "ZYAMINA STUDIO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0 + (2 * _mainController.value), // Huruf meregang
                          fontFamily: 'Roboto', // Guna font tebal jika ada
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "CRAFTING DIGITAL BARAKAH",
                        style: TextStyle(
                          color: kTextSecondary.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}