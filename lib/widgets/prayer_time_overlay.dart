// lib/widgets/prayer_time_overlay.dart (NANO CAPSULE STYLE)
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
      builder: (context, service, _) {
        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled, color: kPrimaryGold, size: 14),
                      
                      const SizedBox(width: 8),
                      
                      if (!service.isReady)
                        const Text(
                          "MEMUATKAN...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 1.0,
                            fontFamily: 'Poppins',
                          ),
                        )
                      else ...[
                        Text(
                          "${service.nextPrayerName?.toUpperCase() ?? 'RALAT'} ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 1.0,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        Text(
                          "• ${service.formattedTimeUntilNextPrayer}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}