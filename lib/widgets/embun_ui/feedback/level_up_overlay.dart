// lib/widgets/embun_ui/feedback/level_up_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';
import '../animations/confetti_burst.dart';

/// Level Up Overlay - Fullscreen celebration bila level up
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onComplete;
  
  const LevelUpOverlay({
    Key? key,
    required this.newLevel,
    this.onComplete,
  }) : super(key: key);
  
  static void show(
    BuildContext context, {
    required int newLevel,
    VoidCallback? onComplete,
  }) {
    HapticFeedback.heavyImpact();
    
    // Repeat haptic
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => LevelUpOverlay(
        newLevel: newLevel,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete?.call();
        },
      ),
    );
    
    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        onComplete?.call();
      }
    });
  }
  
  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> 
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Pulse animation (continuous)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleController.forward();
    _rotationController.forward();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti background
          const Positioned.fill(
            child: ConfettiBurst(particleCount: 50),
          ),
          
          // Main content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "LEVEL UP" text
                    const Text(
                      'LEVEL UP!',
                      style: TextStyle(
                        color: kPrimaryGold,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair',
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Level number dengan pulse
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [kPrimaryGold, kGoldDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryGold.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.newLevel}',
                            style: const TextStyle(
                              color: kBackgroundDark,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Subtitle
                    Text(
                      'MasyaAllah! Tahniah! 🎉',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: AppFontSizes.xl,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    Text(
                      'Istiqamah anda sungguh membanggakan!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: AppFontSizes.md,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tap to dismiss hint
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Ketik untuk sambung',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: AppFontSizes.sm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}