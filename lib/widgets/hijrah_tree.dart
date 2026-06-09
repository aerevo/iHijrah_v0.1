// lib/widgets/hijrah_tree.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';
import 'living_tree.dart';
import 'metallic_gold.dart';

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

class _HijrahTreeState extends State<HijrahTree>
    with TickerProviderStateMixin {

  late AnimationController _lottieCtrl;
  Timer?  _xpTimer;
  bool    _showFx      = false;
  bool    _showXP      = false;
  int     _lastLevel   = 0;

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    _xpTimer?.cancel();
    super.dispose();
  }

  String _treeAsset(int level) {
    if (level <= 1) return AppAssets.treeV1;
    if (level <= 3) return AppAssets.treeV2;
    if (level <= 6) return AppAssets.treeV3;
    return AppAssets.treeV4;
  }

  void _onTap() {
    if (_showFx) return;
    HapticFeedback.heavyImpact();
    Provider.of<AudioService>(context, listen: false).playSiraman();

    setState(() { _showFx = true; _showXP = true; });

    _lottieCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _showFx = false);
    });

    _xpTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showXP = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (ctx, user, _) {
        // Trigger level-up callback
        if (user.treeLevel > _lastLevel) {
          _lastLevel = user.treeLevel;
          widget.onLevelUp?.call(user.treeLevel);
        }

        final double progress = user.nextLevelPoints > 0
            ? user.progressPoints / 100.0
            : 0.0;

        final double treeH     = widget.isExpanded ? 480.0 : 320.0;
        final double containerH= widget.isExpanded ? 550.0 : 400.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ── POKOK ────────────────────────────────────────
            SizedBox(
              height: containerH,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [

                  // Video pokok
                  Positioned(
                    bottom: 20,
                    child: LivingTree(
                      assetPath: _treeAsset(user.treeLevel),
                      height: treeH,
                      onTap: _onTap,
                    ),
                  ),

                  // Lottie siraman
                  if (_showFx)
                    Positioned(
                      bottom: 0,
                      child: IgnorePointer(
                        child: SizedBox(
                          height: containerH,
                          width:  containerH * 0.9,
                          child: Lottie.asset(
                            'assets/animations/embun_jiwa_siraman_lottie.json',
                            controller: _lottieCtrl,
                            fit: BoxFit.cover,
                            onLoaded: (c) {
                              _lottieCtrl.duration = c.duration;
                              _lottieCtrl.forward(from: 0);
                            },
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // XP popup
                  if (_showXP)
                    Positioned(
                      top: widget.isExpanded ? 60 : 40,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (_, val, child) => Opacity(
                          opacity: 1.0 - val * 0.5,
                          child: Transform.translate(
                            offset: Offset(0, -60 * val),
                            child: child,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryGold,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryGold.withOpacity(0.6),
                                blurRadius: 15, spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 14, color: Colors.black),
                              SizedBox(width: 6),
                              Text('MashaAllah!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: widget.isExpanded ? 30 : 20),

            // ── PROGRESS ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isExpanded
                    ? AppSpacing.xl
                    : AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MetallicGold(
                        child: Text(
                          'LVL ${user.treeLevel}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: widget.isExpanded ? 20 : 16,
                          ),
                        ),
                      ),
                      Text(
                        '${user.progressPoints} / 100 XP',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: widget.isExpanded ? 14 : 12,
                          fontWeight: FontWeight.w700,
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
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            kPrimaryGold),
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
