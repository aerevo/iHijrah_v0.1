// lib/widgets/prayer_time_overlay.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/prayer_service.dart';
import '../utils/constants.dart';

/// Bottom overlay showing next prayer time & countdown
///
/// Features:
/// - Auto-updating countdown
/// - Premium glass morphism design
/// - Compact layout
class PrayerTimeOverlay extends StatelessWidget {
  const PrayerTimeOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerService>(
      builder: (context, service, _) {
        return Container(
          decoration: BoxDecoration(
            color: kCardDark.withOpacity(0.95),
            border: const Border(
              top: BorderSide(
                color: kPrimaryGold,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm + 4,
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Prayer name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "WAKTU SETERUSNYA",
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: AppFontSizes.xs,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.nextPrayerName ?? "...",
                    style: const TextStyle(
                      color: kPrimaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.lg,
                    ),
                  ),
                ],
              ),

              // Right: Countdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 4,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.formattedTimeUntilNextPrayer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.xl,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}