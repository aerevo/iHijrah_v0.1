// lib/screens/notification_settings_screen.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../widgets/adhan_settings_panel.dart';
import '../utils/constants.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tetapan Notifikasi",
            style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.bold, fontSize: AppFontSizes.md),
          ),
          const SizedBox(height: AppSpacing.md),

          // Panel Azan
          const AdhanSettingsPanel(),

          const SizedBox(height: AppSpacing.lg),

          // Toggle Lain (Dummy visual)
          _buildToggleTile("Peringatan Pagi & Petang", true),
          _buildToggleTile("Info Sirah Harian", true),
          _buildToggleTile("Bunyi Kesan Khas", false),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: kTextPrimary)),
      value: value,
      onChanged: (val) {},
      activeColor: kAccentOlive,
      contentPadding: EdgeInsets.zero,
    );
  }
}