// lib/widgets/hijrah_tree.dart (LINE 1-15)
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Imports existing
import '../models/user_model.dart';           // ✅ Naik satu level
import '../models/animation_controller_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';
import 'metallic_gold.dart';                  // ✅ Same level
import 'embun_ui/embun_ui.dart';              // ✅ Subfolder

class HijrahTree extends StatefulWidget {
  final Function(int)? onLevelUp;
  const HijrahTree({Key? key, this.onLevelUp}) : super(key: key);

  @override
  State<HijrahTree> createState() => _HijrahTreeState();
}

class _HijrahTreeState extends State<HijrahTree> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  // State Daun Gugur
  Timer? _leafTimer;
  bool _leafFalling = false;
  double _leafX = 0.0;
  double _leafAngle = 0.0;

  // State Level Tracking
  int _lastKnownLevel = 0;

  // ✅ STATE BARU (EMBUN UI)
  bool _showXPCounter = false;
  int _lastXpGain = 0;
  bool _isWatering = false;
  Timer? _wateringTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startLeafCycle();
  }

  void _initAnimations() {
    // Animasi Buai Pokok
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6)
    )..repeat(reverse: true);

    _swingAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOutSine)
    );

    // Animasi Ketuk
    _tapController = AnimationController(
      vsync: this,
      duration: AppDurations.fast
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut)
    );
  }

  void _startLeafCycle() {
    _leafTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _leafFalling = true;
          _leafX = (Random().nextDouble() * 100) - 50;
          _leafAngle = Random().nextDouble() * 2 * pi;
        });

        Future.delayed(AppDurations.leafFall, () {
          if (mounted) setState(() => _leafFalling = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _swingController.dispose();
    _tapController.dispose();
    _leafTimer?.cancel();

    // ✅ CLEANUP BARU
    _wateringTimer?.cancel();

    super.dispose();
  }

  String _getTreeAsset(int level) {
    if (level <= 1) return 'assets/images/pokok_level1.png';
    if (level == 2) return 'assets/images/pokok_level2.png';
    if (level == 3) return 'assets/images/pokok_level3.png';
    return 'assets/images/pokok_level5.png';
  }

  void _handleTreeTap() {
    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    _showSelawatDialog(context);
  }

  // --- LOGIC BARU: EXECUTE EFFECTS ---
  void _executeSelawatEffects(BuildContext context, AudioService audio) {
    final user = Provider.of<UserModel>(context, listen: false);
    final animModel = Provider.of<AnimationControllerModel>(context, listen: false);

    // 1. Show watering effect
    setState(() {
      _isWatering = true;
      _lastXpGain = 20; // XP gained
    });

    // 2. Audio sequence
    audio.playSiraman();
    Future.delayed(const Duration(milliseconds: 800), () {
      audio.playAlhamdulillah();
    });

    // 3. Record action
    user.recordSelawat();

    // 4. Show XP counter animation
    setState(() => _showXPCounter = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showXPCounter = false);
    });

    // 5. Particle spray
    animModel.triggerParticleSpray();

    // 6. Check if leveled up
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_lastKnownLevel < user.treeLevel) {
        _lastKnownLevel = user.treeLevel;
        // Show level up celebration
        LevelUpOverlay.show(
          context,
          newLevel: user.treeLevel,
        );
      }
    });

    // 7. Stop watering effect
    _wateringTimer?.cancel();
    _wateringTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isWatering = false);
    });

    // 8. Success feedback
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        SuccessToast.show(
          context,
          message: 'Alhamdulillah! +20 XP',
          icon: Icons.water_drop,
        );
      }
    });
  }

  // --- UI: DIALOG PREMIUM ---
  void _showSelawatDialog(BuildContext context) {
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.playHi();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: AppDurations.normal,
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5 * anim1.value, sigmaY: 5 * anim1.value),
          child: Transform.scale(
            scale: Curves.easeOutBack.transform(anim1.value),
            child: Opacity(
              opacity: anim1.value,
              child: AlertDialog(
                backgroundColor: kCardDark.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusXl),
                  side: const BorderSide(color: kPrimaryGold, width: 1)
                ),
                title: const MetallicGold(
                  child: Text('Siraman Rohani',
                    style: TextStyle(fontFamily: 'Playfair', fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center
                  )
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.water_drop, size: AppSizes.iconXl, color: Colors.cyanAccent),
                    SizedBox(height: AppSpacing.md),
                    Text('Assalamualaikum, dah selawat ke belum hari ini?',
                      style: TextStyle(color: kTextPrimary, fontSize: AppFontSizes.md),
                      textAlign: TextAlign.center
                    ),
                  ],
                ),
                actions: [
                  // BUTTON BELUM (PULSE)
                  PulseButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      audioService.playInsyaallah();
                    },
                    backgroundColor: Colors.transparent,
                    child: const Text(
                      'Belum',
                      style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.md),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // BUTTON SUDAH (CELEBRATION)
                  CelebrationButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _executeSelawatEffects(context, audioService);
                    },
                    backgroundColor: kPrimaryGold,
                    child: const Text(
                      'SUDAH',
                      style: TextStyle(
                        color: kBackgroundDark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        if (user.treeLevel > _lastKnownLevel) {
          _lastKnownLevel = user.treeLevel;
        }

        final double progress = (user.nextLevelPoints > 0)
            ? user.totalPoints / user.nextLevelPoints
            : 0.0;
        final bool isLowSelawat = user.selawatCountToday < 1;
        final String treeAsset = _getTreeAsset(user.treeLevel);

        return Column(
          children: [
            SizedBox(
              height: AppSizes.treeContainer,
              width: AppSizes.treeContainer,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                   // 1. Glow Belakang Pokok
                  Positioned(
                    bottom: 50,
                    child: Container(
                      width: AppSizes.treeGlow,
                      height: AppSizes.treeGlow,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryGold.withOpacity(0.15),
                            blurRadius: 60,
                            spreadRadius: 20
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ WATER DROPS EFFECT
                  if (_isWatering)
                    Positioned.fill(
                      child: FloatingParticles(
                        count: 15,
                        color: Colors.blue.shade300,
                        size: 6,
                      ),
                    ),

                  // ✅ XP COUNTER TERBANG
                  if (_showXPCounter)
                    Positioned(
                      top: 50,
                      child: XPCounter(
                        value: _lastXpGain,
                        prefix: '+',
                      ),
                    ),

                  // 2. Daun Gugur
                  AnimatedPositioned(
                    duration: AppDurations.leafFall,
                    curve: Curves.easeInQuad,
                    top: _leafFalling ? AppSizes.treeContainer : 80,
                    left: (AppSizes.treeContainer / 2) + _leafX,
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      opacity: _leafFalling ? 0.8 : 0.0,
                      child: Transform.rotate(
                        angle: _leafFalling ? _leafAngle : 0.0,
                        child: const Icon(Icons.eco, color: kAccentOlive, size: 18),
                      ),
                    ),
                  ),

                  // 3. Pokok Utama
                  GestureDetector(
                    onTap: _handleTreeTap,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_swingAnimation, _tapAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _tapAnimation.value,
                          child: Transform.rotate(
                            angle: _swingAnimation.value,
                            child: SizedBox(
                              height: AppSizes.treeImage,
                              width: AppSizes.treeImage,
                              child: Image.asset(treeAsset, fit: BoxFit.contain),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // PROGRESS BAR UPGRADED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MetallicGold(
                        child: Text("Level ${user.treeLevel}",
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                      ),
                      Text("${user.totalPoints} / ${user.nextLevelPoints} XP",
                        style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm)
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ✅ ANIMATED PROGRESS BAR BARU
                  AnimatedProgressBar(
                    progress: progress,
                    height: 12,
                    backgroundColor: Colors.white10,
                    foregroundColor: isLowSelawat ? kWarningRed : kPrimaryGold,
                    showShimmer: progress > 0.8, // Shimmer bila hampir level up
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}