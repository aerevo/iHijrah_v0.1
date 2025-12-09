import 'dart:async';
import 'package:flutter/material.dart';

class AtmosphericSky extends StatefulWidget {
  final Widget child;
  const AtmosphericSky({Key? key, required this.child}) : super(key: key);

  @override
  State<AtmosphericSky> createState() => _AtmosphericSkyState();
}

class _AtmosphericSkyState extends State<AtmosphericSky> {
  late Timer _timer;
  List<Color> _currentColors = _getThemeColors();

  @override
  void initState() {
    super.initState();
    // Check masa setiap 1 minit untuk tukar mood
    _timer = Timer.periodic(const Duration(minutes: 1), (t) {
      setState(() {
        _currentColors = _getThemeColors();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static List<Color> _getThemeColors() {
    final hour = DateTime.now().hour;

    // LOGIK WAKTU (Boleh diselaraskan dengan waktu solat sebenar nanti)
    if (hour >= 5 && hour < 7) {
      // SUBUH: Mystic Purple/Blue
      return [const Color(0xFF1A2980), const Color(0xFF26D0CE)]; 
    } else if (hour >= 7 && hour < 12) {
      // DHUHA: Morning Glory (Gold/Soft Blue)
      return [const Color(0xFFCAC531), const Color(0xFFF3F9A7)]; 
    } else if (hour >= 12 && hour < 16) {
      // ZOHOR: Bright & Sharp
      return [const Color(0xFF005C97), const Color(0xFF363795)];
    } else if (hour >= 16 && hour < 19) {
      // ASAR: Calming Orange
      return [const Color(0xFFf12711), const Color(0xFFf5af19)];
    } else if (hour >= 19 && hour < 20) {
      // MAGHRIB: Deep Sunset
      return [const Color(0xFF2b5876), const Color(0xFF4e4376)];
    } else {
      // MALAM/ISYAK: Deep Space (Default Dark Mode)
      return [const Color(0xFF0F0F0F), const Color(0xFF232526)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3), // Perubahan warna smooth (3 saat)
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _currentColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Overlay hitam nipis supaya teks putih tetap nampak jelas
        ),
      ),
      child: Stack(
        children: [
          // Lapisan Gelap (Vignette) supaya tak terlalu terang
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.9), // Gelap di tepi
                ],
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}