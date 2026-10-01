// lib/home.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';
import 'theme/feed_theme.dart';

import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/feed_panel.dart';
import 'screens/create_post_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {

  late AnimationController _confettiCtrl;

  /// Elak dua bootstrap serentak (mis. rebuild ganjil) menyegerakkan
  /// profil dua kali.
  bool _bootstrapRunning = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
      // Bootstrap profil awam: async, berurutan, dan TIDAK menelan ralat
      // (semua ralat dilog dalam _bootstrapPublicProfile).
      unawaited(_bootstrapPublicProfile());
    });
  }

  /// Urutan (bukan fire-and-forget):
  ///   1. guest → berhenti (tiada panggilan rangkaian);
  ///   2. tarik data users/{uid} TERKINI dan TUNGGU siap — nama/bio
  ///      tempatan mungkin lapuk, jadi tak boleh dipakai sebelum ini;
  ///   3. pastikan UID sesi masih sama;
  ///   4. e-mel MESTI sudah verified (Firebase Auth) — kalau belum, tiada
  ///      profil awam dicipta dan tiada ralat palsu; aliran pengesahan
  ///      e-mel yang sedia ada menguruskannya;
  ///   5. segerakkan profil awam SEKALI melalui UserModel (yang menyemak
  ///      sesi/generation dan kesegaran data).
  /// Tiada setState / navigasi di sini; `mounted` disemak sebelum setiap
  /// langkah yang menyentuh context.
  Future<void> _bootstrapPublicProfile() async {
    if (_bootstrapRunning) return;
    _bootstrapRunning = true;
    try {
      if (!mounted) return;
      // Ambil rujukan SEBELUM sebarang await (context tak selamat selepas).
      final UserModel user = Provider.of<UserModel>(context, listen: false);

      final User? authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) return; // guest
      final String uid = authUser.uid;

      final CloudPullResult pull = await user.pullFromCloudDetailed();
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser?.uid != uid) return; // sesi berubah

      if (pull != CloudPullResult.applied) {
        debugPrint(
          'HomePage: pull users/$uid tidak berjaya ($pull) — '
          'profil awam tidak disegerakkan kali ini.',
        );
        return;
      }

      if (FirebaseAuth.instance.currentUser?.emailVerified != true) return;

      final result = await user.syncPublicProfile();
      if (result.isFailure) {
        debugPrint('HomePage: sync profil awam gagal: ${result.error}');
      }
    } catch (e, st) {
      debugPrint('HomePage._bootstrapPublicProfile ralat: $e\n$st');
    } finally {
      _bootstrapRunning = false;
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  // ── SCROLL CALLBACK dari FeedPanel ───────────────────────────
  void _onFeedScroll(bool scrollingDown) {
    final sidebar =
        Provider.of<SidebarStateModel>(context, listen: false);
    if (scrollingDown && sidebar.isVisible) {
      sidebar.setSidebarVisibility(false);
    } else if (!scrollingDown && !sidebar.isVisible) {
      sidebar.setSidebarVisibility(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final sidebar = Provider.of<SidebarStateModel>(context);

    // Padding kiri untuk bagi ruang rel navigasi — ikut status tampak,
    // supaya kandungan kembang penuh bila rel tersembunyi (bukan lompang kekal)
    final double leftPad = sidebar.isVisible ? kRailWidthCollapsed : 10.0;

    // DayNightTheme bekalkan FeedPalette yg SUDAH beranimasi lembut,
    // diikat pada Subuh/Maghrib sebenar (PrayerService). Letak di sini
    // (punca pokok) — feed panel & feed card terima palette siap lerp,
    // tak perlu masing2 dengar PrayerService sendiri.
    return DayNightTheme(
      builder: (context, palette) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [

          // ── 1. BACKGROUND — latar palet siang/malam ───────────────
          // wallpaper.png TAK LAGI jadi latar global (dulu di sini) —
          // ia kekal dlm assets/images/ semata2 sbg imej post dummy
          // KOMUNITI (id '124', tema wallpaper baharu), lihat
          // feed_panel.dart. Guna Container biasa (BUKAN AnimatedContainer)
          // sebab `palette` di sini dah beranimasi setiap frame drpd
          // DayNightTheme sendiri — bungkus animasi kali kedua di sini
          // cuma buat lag mengekor, bukan lebih lembut.
          Positioned.fill(
            child: Container(
              color: palette.background,
              child: Stack(
                children: [
                  // Cahaya emas atas — pudar sikit siang, lebih nampak malam
                  Positioned(
                    top: -100, left: -100,
                    child: Container(
                      width: 400, height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          palette.accent.withOpacity(0.03 + 0.05 * (1 - palette.t)),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  // Cahaya biru lembut bawah
                  Positioned(
                    bottom: -150, right: -150,
                    child: Container(
                      width: 500, height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          kAccentBlue.withOpacity(0.035),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. FEED — penuh skrin, kembang bila rel tersembunyi ──
          AnimatedPositioned(
            duration: AppDurations.normal,
            curve: AppCurves.smooth,
            top: 0,
            left: leftPad, right: 0, bottom: 0,
            child: sidebar.isClosed
                ? FeedPanel(onScrollDirection: _onFeedScroll, palette: palette)
                : const SizedBox.shrink(),
          ),

          // ── 3. REL NAVIGASI KIRI + HANDLE ─────────────────
          Positioned.fill(
            child: const Sidebar(),
          ),

          // ── 4. FLYOUT PANEL ───────────────────────────────
          AnimatedPositioned(
            duration: AppDurations.normal,
            curve: AppCurves.smooth,
            top: 0,
            left: leftPad, right: 0, bottom: 0,
            child: const FlyoutPanel(),
          ),

          // ── 5. ZIKIR PROMPT ───────────────────────────────
          if (!user.zikirDoneToday)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: ZikirPrompt(
                  zikirDone: user.zikirDoneToday,
                  onDone: () => user.recordZikir(),
                ),
              ),
            ),

          // ── 6. CONFETTI ───────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                AppAssets.animPath + 'confetti.json',
                controller: _confettiCtrl,
                repeat: false,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // ── 7. FAB — Buat Post (cuma waktu feed aktif) ────
          // NOTA: UI ini BUKAN sempadan keselamatan. Cipta post hanya
          // dibenarkan untuk pengguna verified oleh firestore.rules; apa-apa
          // guard di UI hanyalah kemudahan pengguna.
          if (sidebar.isClosed)
            Positioned(
              bottom: 24, right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                ),
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGoldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryGold.withOpacity(0.45),
                        blurRadius: 16, spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.black, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
