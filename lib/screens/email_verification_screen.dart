// lib/screens/email_verification_screen.dart
//
// Skrin lepas Daftar (atau Log Masuk dgn akaun yg belum verify email).
// PENTING: skrin ni TIDAK auto-hantar semula e-mel pengesahan bila
// dibina — e-mel pertama dihantar SEKALI oleh AuthScreen semasa
// pendaftaran. Di sini, hantar semula HANYA bila user tekan butang
// "Hantar semula", dan ada cooldown supaya tak kena throttle
// ('too-many-requests') daripada Firebase.
//
// Semakan status pengesahan guna Timer.periodic (interval sederhana,
// BUKAN 2 saat) + boleh dibatalkan dlm dispose() — bukan
// Future.delayed berulang tanpa kawalan.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import '../home.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  static const Duration _pollInterval      = Duration(seconds: 5);
  static const int      _resendCooldownSec = 60;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  bool   _checking       = false;
  bool   _resending      = false;
  int    _resendCooldown = 0;

  // Lock dalaman berasingan daripada `_checking` (yg cuma untuk UI
  // butang manual). Sebelum ni automatic timer tak pernah set
  // `_checking = true`, jadi guard "if (_checking) return" langsung
  // tak halang dua automatic tick bertindih bila reload() lambat
  // (>_pollInterval). Lock ni cover manual DAN automatic sekali.
  bool _reloadInFlight = false;

  @override
  void initState() {
    super.initState();
    // Semakan berkala sederhana — bukan polling agresif tiap 2 saat.
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkVerified());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified({bool manual = false}) async {
    if (_reloadInFlight) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // dah signed out di tempat lain (cth. tab lain)

    _reloadInFlight = true;
    if (manual && mounted) setState(() => _checking = true);
    bool verified = false;
    try {
      await user.reload();
      final User? fresh = FirebaseAuth.instance.currentUser;
      if (fresh != null && fresh.emailVerified) {
        // reload() cuma kemas kini flag tempatan; claim email_verified
        // dalam ID token kekal lama sampai token di-refresh. Rules
        // posts guna claim tu, jadi paksa refresh SEBELUM route —
        // kalau gagal, jangan anggap siap; poll seterusnya cuba lagi.
        await fresh.getIdToken(true);
        verified = true;
      }
    } catch (e) {
      debugPrint('EmailVerificationScreen: reload/refresh token gagal: $e');
    } finally {
      _reloadInFlight = false;
    }
    if (!mounted) return;

    if (manual && mounted) setState(() => _checking = false);
    if (verified) {
      _pollTimer?.cancel();
      _routeAfterVerified();
    }
  }

  void _routeAfterVerified() {
    if (!mounted) return;
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final bool needsOnboarding =
        userModel.name.isEmpty || userModel.birthdate == null;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            needsOnboarding ? const OnboardingScreen() : const HomePage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _resending) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _resending = true);
    try {
      await user.sendEmailVerification();
      if (mounted) {
        _snack('E-mel pengesahan dihantar semula.', color: kAccentGreen);
        _startCooldown();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _snack(e.code == 'too-many-requests'
            ? 'Terlalu kerap cuba. Tunggu sekejap sebelum cuba lagi.'
            : 'Gagal hantar semula. Cuba lagi.');
      }
    } catch (_) {
      if (mounted) _snack('Gagal hantar semula. Cuba lagi.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = _resendCooldownSec);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _resendCooldown -= 1;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _signOut() async {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    await FirebaseAuth.instance.signOut();
    // Sama macam logout biasa (SettingsView): bersihkan sesi local supaya
    // akaun seterusnya pada peranti ni tak warisi data akaun ini.
    // resetLocalSession() tak push apa-apa ke cloud.
    await userModel.resetLocalSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  void _snack(String msg, {Color color = kWarningRed}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded,
                  color: kPrimaryGold, size: 56),
              const SizedBox(height: 20),
              MetallicGold(
                child: Text(
                  'Sahkan E-mel Anda',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                email.isEmpty
                    ? 'Pautan pengesahan telah dihantar ke e-mel anda.'
                    : 'Pautan pengesahan telah dihantar ke:\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Skrin ini akan menyemak status pengesahan secara berkala.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextMuted, fontSize: 11.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLg,
                child: ElevatedButton(
                  onPressed:
                      _checking ? null : () => _checkVerified(manual: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: kPrimaryGold.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('SEMAK SEKARANG',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed:
                    (_resendCooldown > 0 || _resending) ? null : _resend,
                child: Text(
                  _resendCooldown > 0
                      ? 'Hantar semula (${_resendCooldown}s)'
                      : (_resending ? 'Menghantar...' : 'Hantar semula e-mel'),
                  style: const TextStyle(color: kTextSecondary, fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _signOut,
                child: const Text('Log keluar',
                    style: TextStyle(color: kWarningRed, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
