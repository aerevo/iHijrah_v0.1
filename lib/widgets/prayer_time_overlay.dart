// lib/widgets/prayer_time_overlay.dart - PREMIUM BOTTOM BAR
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../utils/prayer_service.dart';
import '../utils/constants.dart';

class PrayerTimeOverlay extends StatefulWidget {
  const PrayerTimeOverlay({Key? key}) : super(key: key);

  @override
  State<PrayerTimeOverlay> createState() => _PrayerTimeOverlayState();
}

class _PrayerTimeOverlayState extends State<PrayerTimeOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerService>(
      builder: (context, service, _) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kCardDark.withOpacity(0.8),
                    kCardDark.withOpacity(0.95),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: kPrimaryGold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.lg,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Left: Prayer Info
                    Expanded(
                      child: _buildPrayerInfo(service),
                    ),
                    
                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kPrimaryGold.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    
                    // Right: Countdown
                    _buildCountdown(service),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPrayerInfo(PrayerService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: kPrimaryGold.withOpacity(0.8),
              size: AppSizes.iconSm,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              "WAKTU SETERUSNYA",
              style: TextStyle(
                color: kTextSecondary.withOpacity(0.8),
                fontSize: AppFontSizes.xxs,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            // Prayer Name
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: kGoldGradient.scale(0.3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                service.nextPrayerName ?? "...",
                style: const TextStyle(
                  color: kBackgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.lg,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Pulse indicator
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: kAccentEmerald,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kAccentEmerald.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCountdown(PrayerService service) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: kBackgroundDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kPrimaryGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "DALAM",
            style: TextStyle(
              color: kTextSecondary.withOpacity(0.6),
              fontSize: AppFontSizes.xxs,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            service.formattedTimeUntilNextPrayer,
            style: const TextStyle(
              color: kPrimaryGold,
              fontSize: AppFontSizes.xl,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
