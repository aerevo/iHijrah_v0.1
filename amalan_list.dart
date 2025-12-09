// lib/widgets/amalan_list.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../../utils/constants.dart';

class AmalanList extends StatelessWidget {
  const AmalanList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Senarai Amalan Tetap (Boleh dipindahkan ke constants/service jika perlu pada masa depan)
    final List<Map<String, dynamic>> amalanHarian = [
      {'id': 'dhuha', 'name': 'Solat Sunat Dhuha', 'icon': Icons.wb_sunny},
      {'id': 'quran', 'name': 'Baca Al-Quran (1 Muka)', 'icon': Icons.menu_book},
      {'id': 'sedekah', 'name': 'Sedekah Subuh / Harian', 'icon': Icons.volunteer_activism},
      {'id': 'tahajjud', 'name': 'Bangun Tahajjud', 'icon': Icons.nightlight_round},
      {'id': 'witir', 'name': 'Solat Witir', 'icon': Icons.stars},
    ];

    return Consumer<UserModel>(
      builder: (context, user, child) {
        // Kira progress
        int completedCount = 0;
        for (var a in amalanHarian) {
          if (user.isAmalanDoneToday(a['id'])) completedCount++;
        }

        double progress = completedCount / amalanHarian.length;

        return Card(
          color: kCardDark,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: BorderSide(color: kTextSecondary.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            // HEADER TILE
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            leading: CircleAvatar(
              backgroundColor: kPrimaryGold.withOpacity(0.1),
              radius: 22,
              child: const Icon(Icons.library_add_check, color: kPrimaryGold, size: AppSizes.iconMd),
            ),
            title: const Text(
              "Senarai Semak Sunnah",
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair',
                fontSize: AppFontSizes.lg
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  completedCount == amalanHarian.length
                   ? "Tahniah! Semua lengkap."
                   : "$completedCount daripada ${amalanHarian.length} selesai",
                  style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm),
                ),
                const SizedBox(height: 8),

                // Mini Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.black26,
                    valueColor: const AlwaysStoppedAnimation(kAccentOlive),
                  ),
                )
              ],
            ),
            iconColor: kPrimaryGold,
            collapsedIconColor: kTextSecondary,

            // ISI KANDUNGAN
            children: amalanHarian.map((amalan) {
              final isDone = user.isAmalanDoneToday(amalan['id']);

              return Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
                  leading: Icon(
                    amalan['icon'],
                    color: isDone ? kPrimaryGold : kTextSecondary,
                    size: AppSizes.iconSm,
                  ),
                  title: Text(
                    amalan['name'],
                    style: TextStyle(
                      color: isDone ? kPrimaryGold : kTextSecondary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      fontSize: AppFontSizes.md
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: isDone,
                      activeColor: kPrimaryGold,
                      checkColor: kBackgroundDark,
                      side: BorderSide(color: kTextSecondary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (bool? val) {
                        if (val == true) {
                          user.recordAmalan(amalan['id']);
                        }
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}