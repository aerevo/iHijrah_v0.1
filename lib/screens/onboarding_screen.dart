// lib/screens/onboarding_screen.dart (NEW: PREMIUM REGISTRATION)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart'; // Pastikan package ini ada

import '../home.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/embun_ui/embun_ui.dart'; // Untuk butang cantik

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _hijriString = "";

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi Pilih Tarikh Lahir
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryGold,
              onPrimary: Colors.black,
              surface: kCardDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: kCardDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Convert ke Hijrah
        HijriCalendar hDate = HijriCalendar.fromDate(picked);
        _hijriString = hDate.toFormat("dd MMMM yyyy"); // Contoh: 12 Ramadan 1421
      });
    }
  }

  void _submitData() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila masukkan nama panggilan sahabat.")),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila pilih tarikh lahir.")),
      );
      return;
    }

    // Simpan ke UserModel
    final user = Provider.of<UserModel>(context, listen: false);
    
    // Kita simpan format Hijrah string untuk paparan
    // (Anda boleh ubah logic save ni ikut UserModel Tuan sedia ada)
    await user.updateProfile(
      name: name,
      // Simpan tarikh masihi string ISO8601 atau Hijrah, bergantung implementation Tuan.
      // Di sini saya simpan string Hijrah untuk display umur nanti.
      hijriDOB: _selectedDate!.toIso8601String(), 
    );

    // Masuk Home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Elak keyboard tolak background
      body: Stack(
        children: [
          // 1. Background Alam
          const Positioned.fill(child: DynamicBackground()),

          // 2. Glass Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo / Icon
                          const Icon(Icons.mosque, size: 50, color: kPrimaryGold),
                          const SizedBox(height: 20),
                          
                          const Text(
                            "Selamat Datang",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Playfair',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Mari mulakan perjalanan Hijrah ini.",
                            style: TextStyle(color: kTextSecondary, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Input Nama
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Nama Panggilan",
                              labelStyle: const TextStyle(color: kTextSecondary),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryGold)),
                              prefixIcon: const Icon(Icons.person_outline, color: kPrimaryGold),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input Tarikh Lahir
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Tarikh Lahir",
                                labelStyle: TextStyle(color: kTextSecondary),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                prefixIcon: Icon(Icons.cake_outlined, color: kPrimaryGold),
                              ),
                              child: Text(
                                _selectedDate == null 
                                  ? "Pilih Tarikh (Masihi)" 
                                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          // Paparan Hijrah Preview
                          if (_hijriString.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Tarikh Hijrah: $_hijriString",
                                style: const TextStyle(color: kAccentOlive, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ),

                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryGold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 10,
                                shadowColor: kPrimaryGold.withOpacity(0.4),
                              ),
                              child: const Text(
                                "MULA HIJRAH",
                                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}