// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../widgets/adhan_settings_panel.dart';
import '../utils/constants.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prayer names list
    final prayerNames = ['Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tetapan Notifikasi",
            style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.bold, fontSize: AppFontSizes.md),
          ),
          const SizedBox(height: AppSpacing.md),

          // Adhan Audio Settings Panel
          const AdhanSettingsPanel(),

          const SizedBox(height: AppSpacing.lg),

          const Text(
            "Penggera Waktu Solat",
            style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.bold, fontSize: AppFontSizes.md),
          ),
          const SizedBox(height: AppSpacing.md),

          // Prayer Alarm Toggles
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: kCardDark.withOpacity(0.7),
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(color: Colors.white10),
            ),
            child: Consumer<UserModel>(
              builder: (context, user, child) {
                return Column(
                  children: prayerNames.map((prayerName) {
                    bool currentValue;
                    switch (prayerName) {
                      case 'Subuh':
                        currentValue = user.isFajrAlarmEnabled;
                        break;
                      case 'Zohor':
                        currentValue = user.isDhuhrAlarmEnabled;
                        break;
                      case 'Asar':
                        currentValue = user.isAsrAlarmEnabled;
                        break;
                      case 'Maghrib':
                        currentValue = user.isMaghribAlarmEnabled;
                        break;
                      case 'Isyak':
                        currentValue = user.isIshaAlarmEnabled;
                        break;
                      default:
                        currentValue = true;
                    }
                    return _buildToggleTile(
                      title: 'Penggera Azan $prayerName',
                      value: currentValue,
                      onChanged: (newValue) {
                        user.setPrayerAlarm(prayerName, newValue);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: kTextPrimary)),
      value: value,
      onChanged: onChanged,
      activeColor: kAccentOlive,
      contentPadding: EdgeInsets.zero,
    );
  }
}
