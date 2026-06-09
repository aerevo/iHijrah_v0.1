// lib/widgets/sirah_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'sirah_card.dart';

class SirahView extends StatelessWidget {
  const SirahView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyContentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── HEADER INFO ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kAccentTeal.withOpacity(0.07),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kAccentTeal.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khazanah Sirah Nabawiyah',
                      style: TextStyle(
                          color: kAccentTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                    if (daily.todaySirah != null)
                      Text(
                        daily.todaySirah!.tajuk,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── KAD SIRAH ──────────────────────────────────────
        const SirahCard(),
      ],
    );
  }
}
