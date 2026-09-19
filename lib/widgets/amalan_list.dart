// lib/widgets/amalan_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

class AmalanList extends StatelessWidget {
  const AmalanList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyContentProvider>();
    final user     = context.watch<UserModel>();
    final list     = provider.todayAmalanList;
    final loading  = provider.isLoading;

    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
              strokeWidth: 2, color: kPrimaryGold),
        ),
      );
    }

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardDark,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: kBorderSubtle),
        ),
        child: const Row(
          children: [
            Text('🌿', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tiada amalan khusus hari ini.\nFokus pada kualiti solat fardu anda.',
                style: TextStyle(
                    color: kTextSecondary, fontSize: 12, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((amalan) {
        // Sumber kebenaran sebenar ialah UserModel (persist + XP).
        // amalan.isCompleted (provider) turut disemak sbg fallback drpd
        // sesi yg sama, tapi dailyAmalanLog yg bertahan lepas app ditutup.
        final bool done =
            user.isAmalanDoneToday(amalan.id) || amalan.isCompleted;

        void onToggle() {
          provider.toggleAmalan(amalan.id);
          user.toggleAmalanDone(amalan.id);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: done
                ? kPrimaryGold.withOpacity(0.08)
                : kCardDark,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: done
                  ? kPrimaryGold.withOpacity(0.35)
                  : kBorderSubtle,
              width: done ? 1.2 : 0.8,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 2),
            leading: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? kPrimaryGold
                      : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? kPrimaryGold
                        : kTextMuted.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.black)
                    : const SizedBox.shrink(),
              ),
            ),
            title: Text(
              amalan.title,
              style: TextStyle(
                color: done
                    ? kPrimaryGold
                    : kTextPrimary,
                fontSize: 13,
                fontWeight: done
                    ? FontWeight.w600
                    : FontWeight.w400,
                decoration: done
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: kPrimaryGold.withOpacity(0.5),
              ),
            ),
            subtitle: amalan.source.isNotEmpty
                ? Text(
                    amalan.source,
                    style: const TextStyle(
                        color: kTextMuted, fontSize: 10),
                  )
                : null,
            trailing: amalan.type == 'khas'
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: kPrimaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kPrimaryGold.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'KHAS',
                      style: TextStyle(
                          color: kPrimaryGold,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5),
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
