// lib/home.dart
// [FIX] Background Deep Spatial Premium (Tidak Suram/Kelam) + Glassmorphism Ready

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

  @override
  Widget build(BuildContext context) {
    final sidebarModel = Provider.of<SidebarStateModel>(context);
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── 1. BACKGROUND: DEEP SPATIAL (Premium, Tidak Suram) ──────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                // Gradient asas yang KAYA (Rich Slate), BUKAN hitam mati atau kelabu suram
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // Slate 800 (Cukup gelap untuk kaca, tapi ada warna)
                    Color(0xFF0F172A), // Slate 900
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Cahaya Ambient Emas di penjuru atas (Simbol cahaya ilmu/murni)
                  Positioned(
                    top: -100,
                    left: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.12), // Emas lembut
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Cahaya Ambient Biru di penjuru bawah (Simbol ketenangan/tech)
                  Positioned(
                    bottom: -150,
                    right: -150,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.10), // Biru lembut
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. FEED: PENUH SKRIN ────────────────────────────────────────
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: sidebarModel.isClosed
                      ? AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.only(
                            left: sidebarModel.isVisible ? AppSizes.sidebarWidth : 0,
                          ),
                          child: FeedPanel(
                            onScrollDirection: (scrollingDown) {
                              final sidebar = Provider.of<SidebarStateModel>(
                                  context, listen: false);
                              if (scrollingDown && sidebar.isVisible) {
                                sidebar.setSidebarVisibility(false);
                              } else if (!scrollingDown && !sidebar.isVisible) {
                                sidebar.setSidebarVisibility(true);
                              }
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Positioned(left: 0, top: 0, bottom: 0, child: Sidebar()),
              ],
            ),
          ),

          // ── 3. FLYOUT ───────────────────────────────────────────────────
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0, bottom: 0,
            child: const FlyoutPanel(),
          ),

          // ── 4. ZIKIR PROMPT ─────────────────────────────────────────────
          if (!user.zikirDoneToday)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () => user.recordZikir(),
              ),
            ),

          // ── 5. CONFETTI ─────────────────────────────────────────────────
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
