import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';
import 'metallic_gold.dart';

import 'living_tree.dart';

class HijrahTree extends StatefulWidget {
  final Function(int)? onLevelUp;
  final bool isExpanded;
  
  const HijrahTree({
    Key? key, 
    this.onLevelUp,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<HijrahTree> createState() => _HijrahTreeState();
}

class _HijrahTreeState extends State<HijrahTree> with TickerProviderStateMixin {
  late AnimationController _lottieController;

  Timer? _leafTimer;
  bool _showLottieEffect = false;
  bool _showXPCounter = false;
  int _lastKnownLevel = 0;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _leafTimer?.cancel();
    super.dispose();
  }

  void _handleTreeTap() {
    if (_showLottieEffect) return;

    HapticFeedback.heavyImpact();
    Provider.of<AudioService>(context, listen: false).playSiraman();

    setState(() {
      _showLottieEffect = true;
      _showXPCounter = true;
    });

    _lottieController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showLottieEffect = false);
    });

    _leafTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showXPCounter = false);
    });
  }

  // ✅ KEMASKINI MUKTAMAD: Menggunakan fail .mp4
  // Francois telah melaraskan ini untuk memanggil video 'Boomerang' Kapten
  String _getTreeAsset(int level) {
    if (level <= 1) return 'assets/videos/tree_v1.mp4'; 
    if (level <= 3) return 'assets/videos/tree_v2.mp4'; // Sediakan v2 nanti
    if (level <= 5) return 'assets/videos/tree_v3.mp4';
    if (level <= 8) return 'assets/videos/tree_v4.mp4';
    return 'assets/videos/tree_v1.mp4'; // Fallback ke video asal
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        if (user.treeLevel > _lastKnownLevel) {
          _lastKnownLevel = user.treeLevel;
          if (widget.onLevelUp != null) widget.onLevelUp!(user.treeLevel);
        }

        double progress = user.nextLevelPoints > 0
            ? user.totalPoints / user.nextLevelPoints
            : 0.0;

        final treeHeight = widget.isExpanded ? 480.0 : 320.0;
        final containerHeight = widget.isExpanded ? 550.0 : 400.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- AREA POKOK (VIDEO) ---
            SizedBox(
              height: containerHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // LAYER 1: POKOK HIDUP (VIDEO PLAYER)
                  Positioned(
                    bottom: 20,
                    child: LivingTree(
                      assetPath: _getTreeAsset(user.treeLevel),
                      height: treeHeight,
                      onTap: _handleTreeTap,
                    ),
                  ),

                  // LAYER 2: LOTTIE FX (EFEK SIRAMAN)
                  if (_showLottieEffect)
                    Positioned(
                      bottom: 0,
                      child: IgnorePointer(
                        child: SizedBox(
                          height: containerHeight,
                          width: containerHeight * 0.9,
                          child: Lottie.asset(
                            'assets/animations/embun_jiwa_siraman_lottie.json',
                            controller: _lottieController,
                            fit: BoxFit.cover,
                            onLoaded: (composition) {
                              _lottieController.duration = composition.duration;
                              _lottieController.forward(from: 0.0);
                            },
                          ),
                        ),
                      ),
                    ),

                  // LAYER 3: POPUP XP
                  if (_showXPCounter)
                    Positioned(
                      top: widget.isExpanded ? 60 : 40,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, val, child) {
                          return Opacity(
                            opacity: 1.0 - (val * 0.5),
                            child: Transform.translate(
                              offset: Offset(0, -60 * val),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryGold,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryGold.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.auto_awesome,
                                  size: 14, color: Colors.black),
                              SizedBox(width: 6),
                              Text(
                                "MashaAllah!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: widget.isExpanded ? 30 : 20),

            // --- AREA PROGRESS ---
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isExpanded ? AppSpacing.xl : AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MetallicGold(
                        child: Text(
                          "LVL ${user.treeLevel}",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: widget.isExpanded ? 20 : 16,
                          ),
                        ),
                      ),
                      Text(
                        "${user.totalPoints} / ${user.nextLevelPoints} XP",
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: widget.isExpanded ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: widget.isExpanded ? 18 : 14,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
