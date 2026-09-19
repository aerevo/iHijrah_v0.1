// lib/widgets/amalan_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'amalan_list.dart';

const List<String> _kFardhuPrayers = [
  'Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak',
];

class AmalanView extends StatelessWidget {
  const AmalanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyContentProvider>();
    final user  = context.watch<UserModel>();

    final int done  = daily.todayAmalanList.where((a) => a.isCompleted).length;
    final int total = daily.todayAmalanList.length;
    final double pct = total > 0 ? done / total : 0;

    final int fardhuDone = _kFardhuPrayers
        .where((p) => user.isFardhuDoneToday(p)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── SOLAT FARDU HARI INI ────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPrimaryGold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kPrimaryGold.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mosque_rounded, color: kPrimaryGold, size: 16),
                  const SizedBox(width: 8),
                  const Text('SOLAT FARDU HARI INI',
                      style: TextStyle(color: kGoldLight, fontSize: 11.5,
                          fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const Spacer(),
                  Text('$fardhuDone/5',
                      style: const TextStyle(color: kTextSecondary,
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              ..._kFardhuPrayers.map((p) {
                final bool doneP = user.isFardhuDoneToday(p);
                return GestureDetector(
                  onTap: () => user.recordFardhu(p),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: AppDurations.fast,
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: doneP ? kPrimaryGold : Colors.transparent,
                            border: Border.all(
                              color: doneP ? kPrimaryGold : kTextMuted.withOpacity(0.4),
                              width: 1.4,
                            ),
                          ),
                          child: doneP
                              ? const Icon(Icons.check_rounded, size: 13, color: Colors.black)
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 10),
                        Text(p,
                            style: TextStyle(
                              fontSize: 13,
                              color: doneP ? kPrimaryGold : kTextPrimary,
                              fontWeight: doneP ? FontWeight.w600 : FontWeight.w400,
                              decoration: doneP ? TextDecoration.lineThrough : null,
                              decorationColor: kPrimaryGold.withOpacity(0.5),
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

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
