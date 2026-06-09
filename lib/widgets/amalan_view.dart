// lib/widgets/amalan_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'amalan_list.dart';

class AmalanView extends StatelessWidget {
  const AmalanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyContentProvider>();

    final int done  = daily.todayAmalanList.where((a) => a.isCompleted).length;
    final int total = daily.todayAmalanList.length;
    final double pct = total > 0 ? done / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── PROGRESS RING ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kAccentGreen.withOpacity(0.07),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kAccentGreen.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52, height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 4,
                      backgroundColor: kCardDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(kAccentGreen),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: const TextStyle(
                          color: kAccentGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$done daripada $total selesai',
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    'Amalan Sunnah Hari Ini',
                    style: TextStyle(
                        color: kTextSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── SENARAI AMALAN ─────────────────────────────────
        const AmalanList(),
      ],
    );
  }
}
