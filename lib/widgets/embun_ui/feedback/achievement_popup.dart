// lib/widgets/embun_ui/feedback/achievement_popup.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';
import '../animations/shimmer_overlay.dart';

/// Achievement Popup - Popup bila unlock achievement
class AchievementPopup extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    Key? key,
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events,
    this.onDismiss,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.emoji_events,
  }) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => AchievementPopup(
        title: title,
        description: description,
        icon: icon,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryGold, kGoldDark],
              ),
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusXl),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryGold.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan shimmer
                ShimmerOverlay(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.xxl,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: AppFontSizes.md,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close button
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    child: const Text(
                      'ALHAMDULILLAH!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSizes.lg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}