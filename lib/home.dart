// lib/home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/feed_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {

  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

          // ── 1. BACKGROUND — wallpaper.png (bukan gradient kosong lagi) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/wallpaper.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Wash putih sangat halus di atas wallpaper — supaya
                  // label "HARI INI"/"KOMUNITI" (yg duduk terus atas
                  // latar ni, bukan atas kad) kekal senang dibaca
                  Positioned.fill(
                    child: Container(color: Colors.white.withOpacity(0.30)),
                  ),
                  // Cahaya emas atas
                  Positioned(
                    top: -100, left: -100,
                    child: Container(
                      width: 400, height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          kPrimaryGold.withOpacity(0.07),
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
                          kAccentBlue.withOpacity(0.05),
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
                ? FeedPanel(onScrollDirection: _onFeedScroll)
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
        ],
      ),
    );
  }
}
