// lib/home.dart (FIXED - IMPORT PATH BETUL)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// Models & Services (ROOT LEVEL, GUNA 'models/' DIRECT)
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

// Widgets (ROOT LEVEL, GUNA 'widgets/' DIRECT)
import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/hijrah_tree.dart';
import 'widgets/tracker_list.dart';
import 'widgets/feed_panel.dart';
import 'widgets/sirah_card.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/metallic_gold.dart';
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
    // Controller untuk Lottie Particles (Confetti)
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Mainkan audio intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playBismillah();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listener untuk trigger particle effect dari mana-mana widget
    final animModel = Provider.of<AnimationControllerModel>(context);
    if (animModel.shouldSprayParticles) {
      _particleController.forward(from: 0.0).then((_) {
        animModel.resetParticleSpray(); // Reset flag lepas main
      });
    }

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: Stack(
        children: [
          // 1. MAIN LAYOUT (Sidebar + Content)
          Row(
            children: [
              // A. Sidebar (Kiri - Fixed)
              const Sidebar(),

              // B. Body Content (Kanan - Expanded)
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      children: [
                        // Header: Waktu Solat
                        const PrayerTimeOverlay(),
                        const SizedBox(height: AppSpacing.lg),

                        // Section 1: Pokok Hijrah (Centerpiece)
                        const HijrahTree(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 2: Zikir Prompt (Jika belum buat)
                        Consumer<UserModel>(
                          builder: (ctx, user, _) => ZikirPrompt(
                            zikirDone: user.isOptionalComplete('Selawat 100x'),
                            onDone: () => user.toggleOptionalCompletion('Selawat 100x'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Section 3: Sirah Harian
                        const SirahCard(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 4: Tracker List (Checklist)
                        const TrackerList(),
                        const SizedBox(height: AppSpacing.xl),

                        // Section 5: Feed Komuniti
                        const FeedPanel(),
                        const SizedBox(height: 100), // Padding bawah
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. FLYOUT PANEL (Sliding Overlay)
          // Panel ini akan slide keluar dari tepi sidebar bila menu ditekan
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0,
            bottom: 0,
            child: const FlyoutPanel(),
          ),

          // 3. PARTICLE EFFECTS OVERLAY (Lottie)
          // Layer paling atas untuk kesan visual 'celebration'
          Positioned.fill(
            child: IgnorePointer( // Biar user boleh click through
              child: Lottie.asset(
                'assets/animations/confetti.json', // Pastikan fail ni ada atau ganti dengan dummy container
                controller: _particleController,
                repeat: false,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(), // Silent fail kalau asset tiada
              ),
            ),
          ),
        ],
      ),
    );
  }
}