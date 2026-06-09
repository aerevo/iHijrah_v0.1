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

    // Padding atas untuk bagi ruang navbar
    final double topPad = kNavbarHeight +
        MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

          // ── 1. BACKGROUND ─────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Cahaya emas atas
                  Positioned(
                    top: -100, left: -100,
                    child: Container(
                      width: 400, height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFFF59E0B).withOpacity(0.10),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  // Cahaya biru bawah
                  Positioned(
                    bottom: -150, right: -150,
                    child: Container(
                      width: 500, height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF3B82F6).withOpacity(0.08),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. FEED — penuh skrin, padding atas ikut navbar ──
          Positioned(
            top: topPad,
            left: 0, right: 0, bottom: 0,
            child: sidebar.isClosed
                ? FeedPanel(onScrollDirection: _onFeedScroll)
                : const SizedBox.shrink(),
          ),

          // ── 3. TOP NAVBAR + FAB ───────────────────────────
          Positioned.fill(
            child: const Sidebar(),
          ),

          // ── 4. FLYOUT PANEL ───────────────────────────────
          Positioned(
            top: topPad,
            left: 0, right: 0, bottom: 0,
            child: const FlyoutPanel(),
          ),

          // ── 5. ZIKIR PROMPT ───────────────────────────────
          if (!user.zikirDoneToday)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () => user.recordZikir(),
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
