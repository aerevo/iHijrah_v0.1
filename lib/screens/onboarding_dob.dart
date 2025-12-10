// lib/screens/onboarding_dob.dart (VERSI 3 - BACKGROUND CORAK)
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';

class OnboardingDOB extends StatefulWidget {
  const OnboardingDOB({Key? key}) : super(key: key);

  @override
  State<OnboardingDOB> createState() => _OnboardingDOBState();
}

class _OnboardingDOBState extends State<OnboardingDOB> {
  DateTime _selectedDate = DateTime(2000, 1, 1);
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameValid = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onConfirm() async {
    if (!_isNameValid) return;

    // 1. Simpan Data
    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.updateProfile(
      newName: _nameController.text.trim(),
      newDate: _selectedDate
    );
    
    // 2. Audio & Haptic
    Provider.of<AudioService>(context, listen: false).playClick();

    // 3. Masuk ke Home
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
      backgroundColor: Colors.black, // Fallback color
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // === LAYER 1: BACKGROUND IMAGE (CORAK) ===
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black, // Dasar hitam
                  image: DecorationImage(
                    image: AssetImage('assets/images/latar_corak.png'),
                    fit: BoxFit.cover, // Penuhi skrin
                    opacity: 0.3, // Pudar sikit (30% nampak)
                  ),
                ),
              ),
            ),

            // === LAYER 2: VIGNETTE / SHADOW OVERLAY ===
            // (Supaya tulisan putih nampak jelas atas corak)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7), // Atas gelap
                      Colors.black.withOpacity(0.3), // Tengah terang
                      Colors.black.withOpacity(0.8), // Bawah gelap
                    ],
                  ),
                ),
              ),
            ),
      
            // === LAYER 3: KANDUNGAN ===
            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      
                      const Icon(Icons.diamond_outlined, color: kPrimaryGold, size: 40),
                      const SizedBox(height: 20),
      
                      const Text(
                        "IDENTITI HIJRAH",
                        style: TextStyle(
                          color: kPrimaryGold,
                          fontSize: 14,
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        ),
                      ),
                      
                      const Spacer(flex: 1),
      
                      // INPUT NAMA
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
      
                      // INPUT TARIKH
                      const Text(
                        "Tarikh Lahir Masihi",
                        style: TextStyle(color: Colors.white70),
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
      
                      // BUTANG
                      GestureDetector(
                        onTap: _isNameValid ? _onConfirm : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          height: 60,
                          decoration: BoxDecoration(
                            color: _isNameValid ? kPrimaryGold : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: _isNameValid ? [
                              BoxShadow(
                                color: kPrimaryGold.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ] : [],
                            border: _isNameValid ? null : Border.all(color: Colors.white10),
                          ),
                          child: Center(
                            child: Text(
                              "MULAKAN PERJALANAN",
                              style: TextStyle(
                                color: _isNameValid ? Colors.black : Colors.white24,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.5,
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