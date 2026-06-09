// lib/widgets/prayer_time_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/prayer_service.dart';
import '../utils/constants.dart';

class PrayerTimeOverlay extends StatelessWidget {
  const PrayerTimeOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerService>(
      builder: (_, service, __) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: kCardDark.withOpacity(0.88),
                border: const Border(
                  top: BorderSide(color: kPrimaryGold, width: 0.5),
                ),
              ),
              child: Row(
                children: [

                  // Ikon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kPrimaryGold.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mosque_rounded,
                        color: kPrimaryGold, size: 14),
                  ),

                  const SizedBox(width: 10),

                  // Label + nama solat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'WAKTU SETERUSNYA',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        service.nextPrayerName,
                        style: const TextStyle(
                          color: kPrimaryGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Countdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kPrimaryGold.withOpacity(0.2)),
                    ),
                    child: Text(
                      service.countdown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
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
}
