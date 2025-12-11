// lib/screens/onboarding_dob.dart (VERSI 4 - POKOK MELAMBAI)
import 'dart:ui';
import 'dart:math'; // Untuk fungsi sin
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';

// Ganti class OnboardingDOB
class OnboardingDOB extends StatefulWidget {
  const OnboardingDOB({Key? key}) : super(key: key);

  @override
  State<OnboardingDOB> createState() => _OnboardingDOBState();
}

// Guna TickerProviderStateMixin untuk animasi goyangan
class _OnboardingDOBState extends State<OnboardingDOB> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime(2000, 1, 1);
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;

  // Controller untuk Animasi Goyangan
  late AnimationController _treeController;

  @override
  void initState() {
    super.initState();
    // Animasi Goyangan (Looping)
    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Goyangan perlahan dan natural
    )..repeat();

    _nameController.addListener(() {
      setState(() {
        _isNameValid = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _treeController.dispose(); // Wajib dispose
    super.dispose();
  }

  void _onConfirm() async {
    if (!_isNameValid) return;

    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.updateProfile(
      newName: _nameController.text.trim(),
      newDate: _selectedDate
    );

    Provider.of<AudioService>(context, listen: false).playClick();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background Gradient (Macam asal)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F172A), Colors.black],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // LOGO POKOK MELAMBAI
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: AnimatedBuilder(
                          animation: _treeController,
                          builder: (context, child) {
                            // Panggil Painter Pokok Goyang
                            return CustomPaint(
                              painter: _WavingCyberTreePainter(animation: _treeController),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "IDENTITI HIJRAH",
                        style: TextStyle(
                          color: kPrimaryGold,
                          fontSize: 14,
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ... (Input Nama, Tarikh, Butang Kekal Sama) ...

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Nama Panggilan:", style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: "Cth: Aer",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryGold)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      const Text(
                        "Tarikh Lahir Masihi",
                        style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                      ),
                      SizedBox(
                        height: 200,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            brightness: Brightness.dark,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime(2000, 1, 1),
                            maximumDate: DateTime.now(),
                            minimumYear: 1940,
                            maximumYear: DateTime.now().year,
                            onDateTimeChanged: (val) {
                              setState(() => _selectedDate = val);
                            },
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      GestureDetector(
                        onTap: _isNameValid ? _onConfirm : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          height: 60,
                          decoration: BoxDecoration(
                            color: _isNameValid ? kPrimaryGold : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: _isNameValid ? [
                              BoxShadow(
                                color: kPrimaryGold.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ] : [],
                          ),
                          child: Center(
                            child: Text(
                              "MULAKAN PERJALANAN",
                              style: TextStyle(
                                color: _isNameValid ? Colors.black : Colors.white24,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    // KIRAAN GOYANGAN (Sinusoidal - Nampak natural seperti angin)
    final double windFactor = sin(animation.value * 2 * pi) * 10; // Kekuatan angin 10px

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    final Paint fillPaint = Paint()..color = Colors.white;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double windShift = windFactor * (h/w) * 0.1; // Shift bergantung ketinggian

    // --- LUKISAN POKOK ---
    final Path path = Path();

    // 1. Batang Pokok (Pangkal tetap, atas bergoyang)
    path.moveTo(cx, h); // Pangkal (Hujung bawah)
    path.lineTo(cx + windShift, h * 0.3); // Hujung atas (Bergoyang)

    // 2. Dahan Kiri (Bergoyang)
    path.moveTo(cx + windShift * 0.5, h * 0.7); // Titik sambungan tengah
    path.lineTo(cx - w * 0.25 + windShift, h * 0.6);
    path.lineTo(cx - w * 0.25 + windShift, h * 0.45);

    // 3. Dahan Kanan (Bergoyang)
    path.moveTo(cx + windShift * 0.4, h * 0.6);
    path.lineTo(cx + w * 0.25 + windShift, h * 0.5);
    path.lineTo(cx + w * 0.35 + windShift, h * 0.35);

    canvas.drawPath(path, paint);

    // 4. Nodes (Bergoyang)
    // Hujung Kiri
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - w * 0.25 + windShift, h * 0.45), width: 8, height: 8), fillPaint);
    // Hujung Kanan
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + w * 0.35 + windShift, h * 0.35), width: 8, height: 8), fillPaint);
    // Puncak
    canvas.drawCircle(Offset(cx + windShift, h * 0.2), 6, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _WavingCyberTreePainter oldDelegate) {
    return oldDelegate.animation != animation; // Repaint bila animasi berubah
  }
}