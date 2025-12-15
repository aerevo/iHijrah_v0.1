// lib/home.dart (CLEANED FEED AREA)
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
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';

// ✅ IMPORT BARU
import 'widgets/dummy_feed_panel.dart'; // Import Panel Bersih

// ❌ OLD WIDGETS REMOVED: hijrah_tree.dart, tracker_list.dart, feed_panel.dart, sirah_card.dart, metallic_gold.dart

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
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });
  }
  
  // ✅ PENTING: Kita perlukan dispose untuk controller
  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  // Fungsi untuk trigger confetti (biasanya dipanggil dari UserModel bila level up)
  void _startParticleAnimation(AnimationControllerModel animModel) {
    if (animModel.shouldSprayParticles) {
      _particleController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SidebarStateModel>(context);
    final animModel = Provider.of<AnimationControllerModel>(context);

    // Trigger animasi selepas render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startParticleAnimation(animModel);
    });
    
    // Safety check untuk memastikan ZikirPrompt dipaparkan
    final user = Provider.of<UserModel>(context);
    final bool showZikirPrompt = user.name.isNotEmpty && !user.zikirDoneToday;

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: Stack(
        children: [
          // 1. MAIN CONTENT AREA (Sidebar + Feed)
          Row(
            children: [
              // Sidebar (Kekal di kiri)
              const Sidebar(),

              // FEED CONTENT AREA (KONTEN DUMMY)
              Expanded(
                child: Container(
                  // Biar Feed Panel sahaja yang berada di sini.
                  // Semua content lama dibuang.
                  // KITA GUNA DUMMY FEED JIKA FLYOUT TUTUP
                  child: model.isClosed 
                      ? const DummyFeedPanel() // ✅ KONTEN BARU, BERSIH
                      : const SizedBox.shrink(), // HIDE FEED BILA FLYOUT BUKA (optimizasi)
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
          
          // 3. ZIKIR PROMPT (Overlay)
          if (showZikirPrompt)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () {
                  user.recordZikir();
                },
              ),
            ),

          // 4. PRAYER TIME OVERLAY (Bottom Bar)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PrayerTimeOverlay(),
          ),

          // 5. PARTICLE EFFECTS OVERLAY (Lottie)
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
