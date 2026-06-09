// lib/widgets/calendar_view.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../screens/calendar_screen.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String today = HijriService.nowDisplay();
    final String? bulanIstimewa = HijriService.getBulanIstimewa();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Tarikh hari ini
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPrimaryGold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kPrimaryGold.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(today,
                      style: const TextStyle(
                          color: kGoldLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const Text('Hari Ini',
                      style: TextStyle(
                          color: kTextSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // Bulan istimewa
        if (bulanIstimewa != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: kAccentTeal.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: kAccentTeal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(bulanIstimewa,
                      style: const TextStyle(
                          color: kAccentTeal, fontSize: 11.5)),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Kalendar penuh
        const SizedBox(
          height: 480,
          child: CalendarScreen(),
        ),
      ],
    );
  }
}
