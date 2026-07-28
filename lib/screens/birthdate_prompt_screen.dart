// lib/screens/birthdate_prompt_screen.dart
// Screen prompt tarikh lahir — boleh dipanggil dari dalam app
// (contoh: dari profil bila user nak update tarikh)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../home.dart';

class BirthdatePromptScreen extends StatefulWidget {
  const BirthdatePromptScreen({Key? key}) : super(key: key);

  @override
  State<BirthdatePromptScreen> createState() =>
      _BirthdatePromptScreenState();
}

class _BirthdatePromptScreenState extends State<BirthdatePromptScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  DateTime _selectedDate = DateTime(1995, 1, 1);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill nama kalau dah ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserModel>(context, listen: false);
      if (user.name.isNotEmpty) _nameCtrl.text = user.name;
      if (user.birthdate != null) {
        setState(() => _selectedDate = user.birthdate!);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _hijriPreview {
    final h = HijriService.fromDate(_selectedDate);
    return '${h.hDay} ${HijriService.bulanMelayu(h.hMonth)} ${h.hYear}H';
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kWarningRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Sila masukkan nama anda'); return; }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserModel>(context, listen: false);
      user.name      = name;
      user.birthdate = _selectedDate;
      user.hijriDOB  = _selectedDate.toIso8601String();
      await user.save();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (_) {
      setState(() => _isLoading = false);
      _snack('Ralat menyimpan data. Cuba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Text(
                'Profil Hijrah',
                style: GoogleFonts.playfairDisplay(
                  color: kGoldLight,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Masukkan nama dan tarikh lahir untuk mengira identiti Hijrah anda.',
                style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5),
              ),

              const SizedBox(height: 28),

              // Nama
              const Text('Nama Penuh',
                  style: TextStyle(color: kTextSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: kTextPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama anda',
                  hintStyle: TextStyle(color: kTextMuted),
                  prefixIcon: const Icon(Icons.badge_outlined,
                      color: kPrimaryGold, size: 20),
                  filled: true,
                  fillColor: kCardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    borderSide: const BorderSide(color: kPrimaryGold),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Tarikh lahir
              const Text('Tarikh Lahir (Masihi)',
                  style: TextStyle(color: kTextSecondary, fontSize: 12)),
              const SizedBox(height: 6),

              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: kCardDark,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: kPrimaryGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    minimumDate: DateTime(1900),
                    maximumDate: DateTime.now(),
                    backgroundColor: kCardDark,
                    onDateTimeChanged: (d) =>
                        setState(() => _selectedDate = d),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Preview Hijri
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimaryGold.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                      color: kPrimaryGold.withOpacity(0.2), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_hijriPreview,
                            style: const TextStyle(
                                color: kGoldLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        Text(
                          HijriService.calculateHijriAge(
                              _selectedDate.toIso8601String()),
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: kPrimaryGold.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.cardRadius)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text(
                          'MULAKAN PERJALANAN',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
