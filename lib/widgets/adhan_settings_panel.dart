// lib/widgets/adhan_settings_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';

// Mode azan — inline enum, tak perlu fail berasingan
enum AdhanMode { off, vibrate, tone, full }

extension AdhanModeExt on AdhanMode {
  String get label {
    switch (this) {
      case AdhanMode.off:     return 'Senyap';
      case AdhanMode.vibrate: return 'Getar';
      case AdhanMode.tone:    return 'Nada';
      case AdhanMode.full:    return 'Azan Penuh';
    }
  }
  IconData get icon {
    switch (this) {
      case AdhanMode.off:     return Icons.notifications_off_rounded;
      case AdhanMode.vibrate: return Icons.vibration_rounded;
      case AdhanMode.tone:    return Icons.music_note_rounded;
      case AdhanMode.full:    return Icons.record_voice_over_rounded;
    }
  }
}

class AdhanSettingsPanel extends StatelessWidget {
  const AdhanSettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user  = context.watch<UserModel>();
    final audio = context.read<AudioService>();
    final mode  = AdhanMode.values[
        user.adhanModeIndex.clamp(0, AdhanMode.values.length - 1)];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Tajuk
          const Row(
            children: [
              Icon(Icons.volume_up_rounded,
                  color: kPrimaryGold, size: 18),
              SizedBox(width: 8),
              Text(
                'MOD AZAN',
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

          // Pilihan mod
          ...AdhanMode.values.map((m) {
            final bool sel = m == mode;
            return GestureDetector(
              onTap: () {
                user.setAdhanMode(m.index);
                if (m == AdhanMode.tone || m == AdhanMode.full) {
                  audio.playAdhan();
                }
              },
              child: AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sel
                      ? kPrimaryGold.withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  borderRadius:
                      BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                    color: sel
                        ? kPrimaryGold.withOpacity(0.5)
                        : kBorderSubtle,
                    width: sel ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m.icon,
                        size: 18,
                        color: sel ? kPrimaryGold : kTextMuted),
                    const SizedBox(width: 12),
                    Text(
                      m.label,
                      style: TextStyle(
                        color: sel ? kGoldLight : kTextSecondary,
                        fontSize: 13,
                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check_circle_rounded,
                          color: kPrimaryGold, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
