// lib/widgets/profile_detail_view.dart (UPGRADED 7.8/10)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import 'metallic_gold.dart';

class ProfileDetailView extends StatelessWidget {
  const ProfileDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        // Kalkulasi Data
        final String fasaKenabian = HijriService.propheticAgeComparison(user.hijriDOB);
        final String umurHijrah = HijriService.calculateHijriAge(user.hijriDOB ?? '0/0/0');
        final int daysToBday = HijriService.getDaysUntilNextBirthday(user.hijriDOB);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER NAMA & AVATAR
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryGold, width: 2),
                    boxShadow: [
                      BoxShadow(color: kPrimaryGold.withOpacity(0.3), blurRadius: 10)
                    ]
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: kCardDark,
                    child: user.avatarPath != null
                        ? ClipOval(child: Image.file(File(user.avatarPath!), fit: BoxFit.cover, width: 70, height: 70))
                        : const Icon(Icons.person, size: 35, color: kPrimaryGold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: AppFontSizes.xxl,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair'
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: kPrimaryGold),
                          const SizedBox(width: 4),
                          Text(
                            'Level Rohani ${user.treeLevel}',
                            style: TextStyle(color: kPrimaryGold.withOpacity(0.8), fontSize: AppFontSizes.sm),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // SECTION HEADER
            const MetallicGold(
              child: Text("Perjalanan Hijrah",
                style: TextStyle(color: Colors.white, fontSize: AppFontSizes.lg, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
              )
            ),
            const SizedBox(height: AppSpacing.md),

            // DETAILS CARDS
            _buildDetailCard(
              title: 'Umur Hijrah',
              value: umurHijrah,
              icon: Icons.access_time,
              color: kPrimaryGold,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailCard(
              title: 'Fasa Kenabian',
              value: fasaKenabian,
              icon: Icons.wb_cloudy,
              color: kAccentOlive,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailCard(
              title: 'Hari ke Ulangtahun Hijrah',
              value: daysToBday > 0 ? '$daysToBday Hari Lagi' : '🎉 Hari Ini!',
              icon: Icons.cake,
              color: daysToBday == 0 ? kWarningRed : kTextSecondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.xs)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: AppFontSizes.md)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}