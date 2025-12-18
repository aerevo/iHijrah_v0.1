// lib/home.dart (FULL CODE: SCROLL LISTENER ENABLED)

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // ✅ PENTING UTK SCROLL DIRECTION
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// Models & Services
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

// Widgets
import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';
import 'widgets/dummy_feed_panel.dart';
import 'widgets/dynamic_background.dart';

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
    // Controller untuk Lottie Particles (Confetti)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2)
    );

    // Mainkan audio intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  // ✅ LOGIK MENGESAN SCROLL
  bool _onScroll(UserScrollNotification notification, BuildContext context) {
    final sidebarModel = Provider.of<SidebarStateModel>(context, listen: false);

    // Kalau user scroll ke bawah (Forward) -> Sorok Sidebar
    if (notification.direction == ScrollDirection.forward) {
       sidebarModel.setSidebarVisibility(false);
    } 
    // Kalau user scroll ke atas (Reverse) -> Tunjuk Sidebar
    else if (notification.direction == ScrollDirection.reverse) {
       sidebarModel.setSidebarVisibility(true);
    }
    return true; // Benarkan event terus ke atas
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan state sidebar untuk kawalan visibility
    final sidebarModel = Provider.of<SidebarStateModel>(context);
    final user = Provider.of<UserModel>(context);
    
    // Logic Zikir Prompt (Jika Zikir belum selesai)
    final bool showZikirPrompt = !user.zikirDoneToday;

    return Scaffold(
      // Kita set transparent sebab DynamicBackground akan ambil alih tugas 'Wallpaper'
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // ===== 0. BACKGROUND LAYER (PALING BELAKANG) =====
          // Ini enjin penukar gambar Siang/Malam/Menu
          const Positioned.fill(
            child: DynamicBackground(), 
          ),

          // ===== 1. MAIN LAYOUT (Sidebar + Feed) =====
          // Kita bungkus semua dalam NotificationListener untuk detect scroll dari Feed
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) => _onScroll(notification, context),
            child: Stack( // Ubah Row jadi Stack supaya Feed boleh full screen
              children: [
                // FEED (Lapisan Bawah)
                // Kita letak Feed dulu supaya dia memenuhi ruang
                Positioned.fill(
                  child: sidebarModel.isClosed
                      ? AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          // Bila sidebar visible, kita tolak feed ke kanan sikit
                          // Bila sidebar hidden, feed rapat kiri (0) untuk Full Screen
                          padding: EdgeInsets.only(
                            left: sidebarModel.isVisible ? AppSizes.sidebarWidth : 0
                          ),
                          child: const DummyFeedPanel(), 
                        )
                      : const SizedBox.shrink(), // Hide bila Flyout buka
                ),

                // SIDEBAR (Lapisan Atas)
                // Sidebar terapung di atas Feed (sebab ia ada transparent)
                 const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Sidebar(),
                ),
              ],
            ),
          ),

          // ===== 2. FLYOUT PANEL (Sliding Overlay) =====
          // Panel menu tambahan bila tekan sidebar
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0,
            bottom: 0,
            child: const FlyoutPanel(),
          ),

          // ===== 3. ZIKIR PROMPT (Overlay) =====
          if (showZikirPrompt)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () {
                  user.recordZikir();
                },
              ),
            ),

          // ===== 4. PRAYER TIME OVERLAY (Bottom Bar) =====
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PrayerTimeOverlay(),
          ),

          // ===== 5. PARTICLE EFFECTS OVERLAY (Lottie) =====
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
