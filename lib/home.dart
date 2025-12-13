// lib/home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// Models & Services
import 'models/user_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

// Import Sidebar BARU (yang ada Profile & Umur Hijrah)
import 'components/side_menu.dart'; 

// Widgets Kandungan
import 'widgets/hijrah_tree.dart';
import 'widgets/tracker_list.dart';
import 'widgets/feed_panel.dart';
import 'widgets/sirah_card.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';

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
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<AudioService>(context, listen: false).playBismillah();
      } catch (e) {
        debugPrint("Audio Service Error: $e");
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animModel = Provider.of<AnimationControllerModel>(context);
    
    if (animModel.shouldSprayParticles) {
      _particleController.forward(from: 0.0).then((_) {
        animModel.resetParticleSpray();
      });
    }

    return Scaffold(
      backgroundColor: kBackgroundDark,
      // KITA GUNA ROW (Macam asal Kapten)
      // Sidebar Kiri | Konten Kanan
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------
          // 1. SIDEBAR (Kiri - Tetap/Fixed)
          // Kita guna 'SideMenu' baru yang ada Nama & Umur Hijrah
          // ---------------------------------------------
          const SizedBox(
            width: 288, 
            child: SideMenu(), 
          ),

          // ---------------------------------------------
          // 2. KONTEN UTAMA (Kanan - Expanded)
          // ---------------------------------------------
          Expanded(
            child: Stack(
              children: [
                // Scrollable Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      children: [
                        // Header: Waktu Solat
                        const PrayerTimeOverlay(),
                        const SizedBox(height: AppSpacing.lg),

                        // Section 1: Pokok Hijrah
                        const HijrahTree(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 2: Zikir Prompt
                        Consumer<UserModel>(
                          builder: (ctx, user, _) => ZikirPrompt(
                            zikirDone: user.isAmalanDoneToday('Selawat 100x'),
                            onDone: () => user.recordAmalan('Selawat 100x'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Section 3: Sirah Harian
                        const SirahCard(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 4: Tracker List
                        const TrackerList(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 5: Feed Komuniti
                        const FeedPanel(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Particle Effect Overlay
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
          ),
        ],
      ),
    );
  }
}
