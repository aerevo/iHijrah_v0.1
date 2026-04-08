// lib/home.dart — WHEEL FEED AKTIF

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';
import 'widgets/feed_panel.dart';       // ✅ WHEEL FEED AKTIF
import 'widgets/dynamic_background.dart';
// import 'screens/event_screen.dart';  // ❌ EventScreen diketepikan buat masa ni

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  // Phantom Mode — sorok sidebar bila scroll turun
  bool _onScroll(UserScrollNotification notification, BuildContext context) {
    final sidebarModel = Provider.of<SidebarStateModel>(context, listen: false);
    if (notification.direction == ScrollDirection.reverse && sidebarModel.isVisible) {
      sidebarModel.setSidebarVisibility(false);
    } else if (notification.direction == ScrollDirection.forward && !sidebarModel.isVisible) {
      sidebarModel.setSidebarVisibility(true);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final sidebarModel = Provider.of<SidebarStateModel>(context);
    final user = Provider.of<UserModel>(context);
    final bool showZikirPrompt = !user.zikirDoneToday;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND
          const Positioned.fill(
            child: DynamicBackground(),
          ),

          // 2. MAIN CONTENT — Wheel Feed + Phantom Sidebar padding
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: sidebarModel.isClosed
                      ? NotificationListener<UserScrollNotification>(
                          onNotification: (n) => _onScroll(n, context),
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            // ✅ Padding kiri = lebar sidebar bila visible,
                            //    0 bila sidebar tersembunyi (Phantom Mode)
                            padding: EdgeInsets.only(
                              left: sidebarModel.isVisible
                                  ? AppSizes.sidebarWidth
                                  : 0,
                            ),
                            child: const FeedPanel(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // SIDEBAR
                const Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Sidebar(),
                ),
              ],
            ),
          ),

          // 3. FLYOUT PANEL
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0, bottom: 0,
            child: const FlyoutPanel(),
          ),

          // 4. OVERLAYS
          if (showZikirPrompt)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () => user.recordZikir(),
              ),
            ),

          const Positioned(
            left: 0, right: 0, bottom: 0,
            child: PrayerTimeOverlay(),
          ),

          // 5. CONFETTI
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                controller: _particleController,
                repeat: false,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
