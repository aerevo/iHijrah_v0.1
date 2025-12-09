// lib/home.dart (AAA PREMIUM - FULL OVERWRITE)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';

// Utils
import 'utils/constants.dart';
import 'utils/audio_service.dart';

// Widgets (Components)
import 'widgets/sidebar.dart';
import 'widgets/flyout_panel.dart';
import 'widgets/hijrah_tree_aaa.dart'; // ✅ NEW AAA VERSION
import 'widgets/tracker_list.dart';
import 'widgets/feed_panel.dart';
import 'widgets/sirah_card.dart';
import 'widgets/zikir_prompt.dart';
import 'widgets/prayer_time_overlay.dart';
import 'widgets/gift_overlay.dart';
import 'widgets/atmospheric_sky.dart';
import 'widgets/embun_spirit_aaa.dart'; // ✅ NEW AAA MASCOT

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _showGiftOverlay = false;
  late AnimationController _pageController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Page entrance animation
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _pageController.forward();

    // Audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playBismillah();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _triggerGiftAnimation() {
    setState(() => _showGiftOverlay = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 0: ATMOSPHERIC SKY
          Positioned.fill(
            child: AtmosphericSky(
              child: Container(),
            ),
          ),

          // LAYER 1: MAIN LAYOUT
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Row(
              children: [
                // A. SIDEBAR
                const Sidebar(),

                // B. SCROLLABLE CONTENT
                Expanded(
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Main scroll view
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. PRAYER TIMES HUD
                              const PrayerTimeOverlay(),
                              const SizedBox(height: 30),

                              // 2. AAA CENTERPIECE: HIJRAH TREE + EMBUN SPIRIT
                              const Center(
                                child: HijrahTreeAAA(), // ✅ NEW PREMIUM TREE
                              ),

                              const SizedBox(height: 20),

                              // Embun Spirit Guardian (floating below tree)
                              const Center(
                                child: EmbunSpiritAAA(), // ✅ NEW AAA MASCOT
                              ),

                              const SizedBox(height: 35),

                              // 3. SPECIAL ACTION: ZIKIR PROMPT
                              Consumer<UserModel>(
                                builder: (ctx, user, _) => ZikirPrompt(
                                  zikirDone: user.isAmalanDoneToday('Selawat 100x'),
                                  onDone: () {
                                    user.recordAmalan('Selawat 100x');
                                    _triggerGiftAnimation();
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),

                              // 4. DASHBOARD WIDGETS
                              const SirahCard(),
                              const SizedBox(height: 25),

                              const TrackerList(),

                              const SizedBox(height: 25),
                              const FeedPanel(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LAYER 2: FLYOUT PANEL
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0,
            bottom: 0,
            child: const FlyoutPanel(),
          ),

          // LAYER 3: GIFT OVERLAY
          if (_showGiftOverlay)
            Positioned.fill(
              child: GiftOverlay(
                onAnimationComplete: () {
                  setState(() => _showGiftOverlay = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}