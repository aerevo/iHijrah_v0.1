// lib/widgets/lock_overlay.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'shimmer_effect.dart';

/// Lock overlay untuk premium/locked features
/// 
/// Features:
/// - Blur underlying widget
/// - Shimmer lock icon
/// - Haptic feedback on tap
/// - Custom message
class LockOverlay extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;
  final VoidCallback? onTap;
  
  const LockOverlay({
    Key? key,
    required this.child,
    this.title = "Ciri Premium",
    this.message = "Ciri ini sedang dibangunkan untuk versi penuh.",
    this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context) {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    if (onTap != null) {
      onTap!();
    } else {
      // Default: Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kCardDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Blurred underlying widget
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(child: child),
        ),

        // 2. Lock overlay
        Positioned.fill(
          child: InkWell(
            onTap: () => _handleTap(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: kTextSecondary.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shimmer lock icon
                  ShimmerEffect(
                    child: Icon(
                      Icons.lock_outline,
                      color: kPrimaryGold,
                      size: AppSizes.iconXl,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.sm + 2),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: kPrimaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.lg,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Message
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kTextSecondary,
                        fontSize: AppFontSizes.xs + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}