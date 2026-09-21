// lib/screens/auth_screen.dart
// Log masuk / Daftar — Email & Password sahaja (bukan Google Sign-In:
// perlukan SHA-1 fingerprint, persekitaran dev tiada Flutter/Gradle
// utk generate senang — lihat nota keputusan Firebase). Skrin ni
// muncul SEBELUM Onboarding, supaya data (streak/pokok/profil) terus
// terikat ke akaun sejak awal & boleh dipulih lepas reinstall/tukar
// telefon.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';
import '../widgets/tree_of_life_logo.dart';
import '../widgets/iridescent_background.dart';
import '../screens/onboarding_screen.dart';
import '../home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl  = TextEditingController();

  bool _isRegisterMode = true; // mula dgn Daftar — pengguna baru lagi biasa
  bool _loading         = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color color = kWarningRed}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  // Mesej Firebase asal dlm Inggeris/teknikal — terjemah kpd Melayu
  // ringkas & mesra, supaya pengguna faham apa nak buat seterusnya.
  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'E-mel ni dah didaftarkan. Cuba Log Masuk pula.';
      case 'invalid-email':
        return 'Format e-mel tak sah.';
      case 'weak-password':
        return 'Kata laluan terlalu mudah — guna sekurang-kurangnya 6 aksara.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'E-mel atau kata laluan salah.';
      case 'network-request-failed':
        return 'Tiada sambungan internet. Cuba lagi.';
      case 'too-many-requests':
        return 'Terlalu banyak percubaan. Tunggu sekejap & cuba lagi.';
      default:
        return 'Ralat: $code';
    }
  }

  Future<void> _submit() async {
    final String email = _emailCtrl.text.trim();
    final String pass  = _passCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _snack('Sila masukkan e-mel yang sah');
      return;
    }
    if (pass.length < 6) {
      _snack('Kata laluan sekurang-kurangnya 6 aksara');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isRegisterMode) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: pass);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: pass);
      }

      if (!mounted) return;
      final user = Provider.of<UserModel>(context, listen: false);
      user.email = email;

      // Cuba tarik data sedia ada dari cloud (kes: akaun lama, telefon
      // baru). Kalau takde (akaun baru terus didaftar), teruskan je —
      // data local (kosong/onboarding blm isi) yg jadi asas.
      await user.pullFromCloud();

      if (!mounted) return;
      final bool needsOnboarding =
          user.name.isEmpty || user.birthdate == null;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              needsOnboarding ? const OnboardingScreen() : const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      _snack(_friendlyError(e.code));
    } catch (e) {
      setState(() => _loading = false);
      _snack('Ralat tidak dijangka. Cuba lagi.');
    }
  }

  Future<void> _forgotPassword() async {
    final String email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Masukkan e-mel anda dahulu, baru tekan "Lupa Kata Laluan"');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _snack('Pautan set semula kata laluan dihantar ke $email',
          color: kAccentGreen);
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyError(e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const Positioned.fill(child: IridescentBackground()),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 40),
                    const TreeOfLifeLogo(size: 84, animated: false),
                    const SizedBox(height: 20),

                    MetallicGold(
                      child: Text(
                        'iHijrah',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegisterMode
                          ? 'Cipta akaun — data anda kekal selamat\nwalau tukar telefon.'
                          : 'Selamat kembali.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextSecondary, fontSize: 12.5, height: 1.5),
                    ),

                    const SizedBox(height: 36),

                    _inputLabel('E-mel'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: kTextPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'nama@contoh.com',
                        hintStyle: const TextStyle(color: kTextMuted),
                        prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryGold, size: 20),
                        filled: true,
                        fillColor: kCardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          borderSide: const BorderSide(color: kPrimaryGold, width: 1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _inputLabel('Kata Laluan'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: kTextPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Sekurang-kurangnya 6 aksara',
                        hintStyle: const TextStyle(color: kTextMuted),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: kPrimaryGold, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: kTextMuted, size: 19,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: kCardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          borderSide: const BorderSide(color: kPrimaryGold, width: 1),
                        ),
                      ),
                    ),

                    if (!_isRegisterMode) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _loading ? null : _forgotPassword,
                          child: const Text('Lupa kata laluan?',
                              style: TextStyle(color: kTextSecondary, fontSize: 11.5)),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 16),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightLg,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: kPrimaryGold.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Text(_isRegisterMode ? 'DAFTAR' : 'LOG MASUK',
                                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() => _isRegisterMode = !_isRegisterMode),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: kTextSecondary, fontSize: 12.5),
                          children: [
                            TextSpan(text: _isRegisterMode
                                ? 'Dah ada akaun? '
                                : 'Belum ada akaun? '),
                            TextSpan(
                              text: _isRegisterMode ? 'Log Masuk' : 'Daftar',
                              style: const TextStyle(color: kGoldLight, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      );
}
