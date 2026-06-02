// lib/home.dart
// [FIX 5] PrayerTimeOverlay dibuang — FeedPanel isi penuh skrin

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
      backgroundColor: const Color(0xFF14121A),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 2. BACKGROUND OVERLAY — grey gelap, ringan tanpa image
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF14121A),
              ),
            ),
          ),

          // 3. FEED — penuh skrin
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

          // 4. FLYOUT
          Positioned(
            left: AppSizes.sidebarWidth,
            top: 0, bottom: 0,
            child: const FlyoutPanel(),
          ),

          // 5. ZIKIR PROMPT
          if (!user.zikirDoneToday)
            Positioned.fill(
              child: ZikirPrompt(
                zikirDone: user.zikirDoneToday,
                onDone: () => user.recordZikir(),
              ),
            ),

          // 6. CONFETTI
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
