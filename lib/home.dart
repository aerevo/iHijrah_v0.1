// lib/home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// Models & Services
import 'models/user_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/constants.dart';
import 'utils/audio_service.dart';

// Widgets (Hanya widget konten, SIDEBAR DIBUANG sebab EntryPoint dah handle)
import 'widgets/hijrah_tree.dart';
import 'widgets/tracker_list.dart';
import 'widgets/feed_panel.dart';
import 'widgets/sirah_card.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';
// import 'widgets/flyout_panel.dart'; // Jika perlu panel kanan, boleh un-comment

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
    // Setup Lottie Controller
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Audio Intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan AudioService wujud dalam provider sebelum panggil
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
    // Listener Particle
    final animModel = Provider.of<AnimationControllerModel>(context);
    if (animModel.shouldSprayParticles) {
      _particleController.forward(from: 0.0).then((_) {
        animModel.resetParticleSpray();
      });
    }

    return Scaffold(
      backgroundColor: kBackgroundDark, // Warna latar belakang Home
      body: Stack(
        children: [
          // 1. KANDUNGAN UTAMA (Tanpa Sidebar Statik)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                children: [
                  // Jarak untuk Butang Menu di atas (Supaya tak tertindih)
                  const SizedBox(height: 60), 

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
                  const SizedBox(height: 100), // Padding bawah
                ],
              ),
            ),
          ),

          // 2. PARTICLE EFFECTS (Layer Atas)
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
