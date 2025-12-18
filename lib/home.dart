// lib/home.dart - ENHANCED AAA COORDINATION
import 'package:flutter/material.dart';
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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Particle Controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Fade-in Controller untuk smooth entry
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Start fade-in animation
    _fadeController.forward();
    
    // Play intro audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playIntroAudio();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sidebarModel = Provider.of<SidebarStateModel>(context);
    final user = Provider.of<UserModel>(context);
    
    final bool showZikirPrompt = !user.zikirDoneToday;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ===== BACKGROUND LAYER =====
            const Positioned.fill(
              child: DynamicBackground(),
            ),
            
            // ===== AMBIENT GLOW OVERLAY =====
            // Subtle animated glow untuk depth
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          kPrimaryGold.withOpacity(0.05 * _fadeController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // ===== MAIN LAYOUT =====
            Row(
              children: [
                // Sidebar
                const Sidebar(),
                
                // Feed Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: sidebarModel.isClosed
                      ? const DummyFeedPanel()
                      : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            
            // ===== FLYOUT PANEL =====
            Positioned(
              left: AppSizes.sidebarWidth,
              top: 0,
              bottom: 0,
              child: const FlyoutPanel(),
            ),
            
            // ===== ZIKIR PROMPT =====
            if (showZikirPrompt)
              Positioned.fill(
                child: ZikirPrompt(
                  zikirDone: user.zikirDoneToday,
                  onDone: () {
                    user.recordZikir();
                  },
                ),
              ),
            
            // ===== PRAYER TIME OVERLAY =====
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PrayerTimeOverlay(),
            ),
            
            // ===== PARTICLE EFFECTS =====
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
            
            // ===== FLOATING ACTION BUTTON (Optional) =====
            // Uncomment jika nak tambah FAB untuk quick actions
            /*
            Positioned(
              right: AppSpacing.lg,
              bottom: 100 + AppSpacing.lg,
              child: _buildFloatingActionButton(sidebarModel),
            ),
            */
          ],
        ),
      ),
    );
  }
  
  // Optional: Floating Action Button untuk quick menu toggle
  Widget _buildFloatingActionButton(SidebarStateModel sidebarModel) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: kGoldGradient,
        boxShadow: AppShadows.glow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => sidebarModel.toggleMenu(),
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(
              sidebarModel.isMenuOpen ? Icons.close : Icons.menu,
              color: kBackgroundDark,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ),
    );
  }
}
