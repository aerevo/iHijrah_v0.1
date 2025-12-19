// lib/screens/onboarding_screen.dart (PREMIUM WHEEL DATE PICKER)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ WAJIB: Untuk Kalendar Pusing
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';

import '../home.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/dynamic_background.dart';

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

  // ✅ FUNGSI PILIH TARIKH BARU (GAYA PUSING/WHEEL)
  void _pickDate() {
    // Kalau belum pilih, set default ke tahun 2000
    if (_selectedDate == null) {
      _selectedDate = DateTime(2000, 1, 1);
      _updateHijri(_selectedDate!);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: kCardDark, // Latar Gelap
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 300, // Tinggi panel pusing
          child: Column(
            children: [
              // 1. Toolbar (Butang Selesai)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pilih Tarikh Lahir", style: TextStyle(color: kTextSecondary)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "SELESAI",
                        style: TextStyle(
                          color: kPrimaryGold, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 2. Roda Pusing (Spinner)
              Expanded(
                child: CupertinoTheme(
                  // Paksa tema gelap supaya tulisan roda jadi Putih
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark, 
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white, 
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    minimumDate: DateTime(1940),
                    maximumDate: DateTime.now(),
                    // Tukar format tarikh ikut susunan Malaysia (Hari - Bulan - Tahun)
                    dateOrder: DatePickerDateOrder.dmy, 
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                        _updateHijri(newDate);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateHijri(DateTime date) {
    HijriCalendar hDate = HijriCalendar.fromDate(date);
    _hijriString = hDate.toFormat("dd MMMM yyyy"); 
  }

  void _submitData() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kWarningRed,
          content: Text("Sila masukkan nama panggilan sahabat.", style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kWarningRed,
          content: Text("Sila pilih tarikh lahir anda.", style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    // Simpan Data
    final user = Provider.of<UserModel>(context, listen: false);
    
    await user.updateProfile(
      name: name,
      // Simpan ISO string untuk data, Hijri untuk display nanti
      hijriDOB: _selectedDate!.toIso8601String(), 
    );

    // Animasi Masuk Home
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
      resizeToAvoidBottomInset: false, 
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
                            cursorColor: kPrimaryGold,
                            decoration: const InputDecoration(
                              labelText: "Nama Panggilan",
                              labelStyle: TextStyle(color: kTextSecondary),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryGold)),
                              prefixIcon: Icon(Icons.person_outline, color: kPrimaryGold),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input Tarikh Lahir (TRIGGER RODA PUSING)
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Tarikh Lahir",
                                labelStyle: TextStyle(color: kTextSecondary),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                prefixIcon: Icon(Icons.cake_outlined, color: kPrimaryGold),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDate == null 
                                      ? "Sentuh untuk pilih" 
                                      : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
                                    style: TextStyle(
                                      color: _selectedDate == null ? Colors.white38 : Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: kTextSecondary),
                                ],
                              ),
                            ),
                          ),

                          // Paparan Hijrah Preview
                          if (_hijriString.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kAccentOlive.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: kAccentOlive.withOpacity(0.5)),
                                ),
                                child: Text(
                                  "Tarikh Hijrah: $_hijriString",
                                  style: const TextStyle(color: kAccentOlive, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
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
