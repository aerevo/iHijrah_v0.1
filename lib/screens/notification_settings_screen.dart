// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/adhan_settings_panel.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── MOD AZAN ─────────────────────────────────────
          const AdhanSettingsPanel(),
          const SizedBox(height: 20),

          // ── NOTIFIKASI SOLAT ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius:
                  BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(color: kBorderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_rounded,
                        color: kPrimaryGold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'PERINGATAN SOLAT',
                      style: TextStyle(
                        color: kGoldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...[
                  'Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak'
                ].map((p) {
                  final bool on = _prayerEnabled(user, p);
                  return _prayerTile(
                    prayer:  p,
                    enabled: on,
                    onToggle: (v) => user.setPrayerAlarm(p, v),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── EMBUN JIWA ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius:
                  BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(color: kBorderSubtle),
            ),
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Embun Jiwa',
                          style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text('Peringatan zikir harian',
                          style: TextStyle(
                              color: kTextSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: kPrimaryGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _prayerEnabled(UserModel u, String p) {
    switch (p) {
      case 'Subuh':   return u.isFajrAlarmEnabled;
      case 'Zohor':   return u.isDhuhrAlarmEnabled;
      case 'Asar':    return u.isAsrAlarmEnabled;
      case 'Maghrib': return u.isMaghribAlarmEnabled;
      case 'Isyak':   return u.isIshaAlarmEnabled;
      default:        return false;
    }
  }

  Widget _prayerTile({
    required String  prayer,
    required bool    enabled,
    required void Function(bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.mosque_rounded,
              size: 16, color: kTextMuted),
          const SizedBox(width: 10),
          Text(prayer,
              style: const TextStyle(
                  color: kTextPrimary, fontSize: 13)),
          const Spacer(),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeColor: kPrimaryGold,
          ),
        ],
      ),
    );
  }
}
