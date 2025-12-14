// lib/widgets/adhan_settings_panel.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/settings_enums.dart'; // Pastikan enum ini wujud
import '../utils/audio_service.dart';
import 'metallic_gold.dart';

class AdhanSettingsPanel extends StatelessWidget {
  const AdhanSettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: Colors.white10),
      ),
      child: Consumer<UserModel>(
        builder: (context, user, child) {
          final AdhanMode currentMode = AdhanMode.values[user.adhanModeIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TAJUK EMAS BERKILAU
              const MetallicGold(
                child: Text(
                  "Kawalan Audio Azan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.xl,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair'
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // PILIHAN 1: MATI (OFF)
              _buildRadioTile(
                context,
                user: user,
                mode: AdhanMode.off,
                currentMode: currentMode,
                title: 'Mati (Senyap)',
                subtitle: 'Tiada bunyi Azan dimainkan.',
              ),

              // PILIHAN 2: HIDUP PENUH (FULL)
              _buildRadioTile(
                context,
                user: user,
                mode: AdhanMode.full,
                currentMode: currentMode,
                title: 'Hidup Penuh',
                subtitle: 'Azan dimainkan sepenuhnya (seperti biasa).',
              ),

              // PILIHAN 3: MAIN RINGKAS (SHORT)
              _buildRadioTile(
                context,
                user: user,
                mode: AdhanMode.short,
                currentMode: currentMode,
                title: 'Main Ringkas (15 Saat)',
                subtitle: 'Azan dimainkan sekejap sahaja untuk notifikasi.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required UserModel user,
    required AdhanMode mode,
    required AdhanMode currentMode,
    required String title,
    required String subtitle,
  }) {
    return RadioListTile<AdhanMode>(
      title: Text(title, style: const TextStyle(color: kTextPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: kTextSecondary.withOpacity(0.7), fontSize: AppFontSizes.xs)),
      value: mode,
      groupValue: currentMode,
      activeColor: kPrimaryGold,
      tileColor: Colors.transparent,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (newMode) {
        if (newMode != null) {
          user.setAdhanMode(newMode.index);

          // Ujian Segera: Mainkan audio (kecuali 'off') untuk demo bila Azan berbunyi
          if (newMode != AdhanMode.off) {
             Provider.of<AudioService>(context, listen: false).playAdhan(context);
          }
        }
      },
    );
  }
}