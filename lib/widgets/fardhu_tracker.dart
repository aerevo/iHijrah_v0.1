// lib/widgets/fardhu_tracker.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/animation_controller_model.dart';
import '../utils/constants.dart';

/// Fardhu prayer tracker dengan interactive buttons
/// 
/// Features:
/// - 5 prayer buttons (Subuh, Zohor, Asar, Maghrib, Isyak)
/// - Scale animation on press
/// - Glow effect when completed
/// - Haptic feedback
/// - XP reward tracking
class FardhuTracker extends StatelessWidget {
  const FardhuTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prayers = ['Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fardhu Harian',
              style: TextStyle(
                fontSize: AppFontSizes.xl,
                fontFamily: 'Playfair',
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            Consumer<UserModel>(
              builder: (ctx, user, _) {
                int doneCount = 0;
                for (var p in prayers) {
                  if (user.isFardhuDoneToday(p)) doneCount++;
                }
                return Text(
                  "$doneCount/5 Selesai",
                  style: const TextStyle(
                    color: kPrimaryGold,
                    fontSize: AppFontSizes.sm,
                  ),
                );
              },
            )
          ],
        ),
        
        const SizedBox(height: AppSpacing.md - 1),
        
        // Prayer buttons
        SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((p) => _buildPrayerButton(context, p)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerButton(BuildContext context, String prayerName) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        final isDone = user.isFardhuDoneToday(prayerName);

        return Expanded(
          child: _InteractivePrayerBtn(
            label: prayerName,
            isDone: isDone,
            onTap: () {
              if (!isDone) {
                user.recordFardhu(prayerName);
                Provider.of<AnimationControllerModel>(context, listen: false)
                    .triggerParticleSpray();
                HapticFeedback.mediumImpact();
              }
            },
          ),
        );
      },
    );
  }
}

// ===== INTERACTIVE BUTTON WITH ANIMATION =====

class _InteractivePrayerBtn extends StatefulWidget {
  final String label;
  final bool isDone;
  final VoidCallback onTap;

  const _InteractivePrayerBtn({
    required this.label,
    required this.isDone,
    required this.onTap,
  });

  @override
  State<_InteractivePrayerBtn> createState() => _InteractivePrayerBtnState();
}

class _InteractivePrayerBtnState extends State<_InteractivePrayerBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: widget.isDone ? kPrimaryGold : kCardDark,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(
            color: widget.isDone 
                ? kPrimaryGold 
                : kTextSecondary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: widget.isDone
              ? [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isDone ? Icons.check_circle : Icons.circle_outlined,
              color: widget.isDone ? kBackgroundDark : kTextSecondary,
              size: 22,
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isDone ? kBackgroundDark : kTextSecondary,
                fontSize: AppFontSizes.xs,
                fontWeight: widget.isDone ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}