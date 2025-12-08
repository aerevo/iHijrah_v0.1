// lib/widgets/sirah_card.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../utils/sirah_service.dart';
import 'metallic_gold.dart';

class SirahCard extends StatelessWidget {
  const SirahCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>( // Ubah Result kepada Map direct atau handle result
      future: SirahService.getSirahForToday().then((res) => res.dataOr({})), // Helper untuk extract data
      builder: (context, snapshot) {

        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
             return Container(
               height: 120,
               decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
               child: const Center(child: CircularProgressIndicator(color: kPrimaryGold))
             );
        }

        // 2. Data Handling
        final sirahData = snapshot.data ?? {};
        final String title = sirahData['peristiwa'] ?? 'Peringatan Harian';
        final String content = sirahData['pengajaran'] ?? sirahData['event'] ?? 'Tiada peristiwa khas hari ini.';
        final String footer = sirahData['hadith'] ?? sirahData['pengajaran'] ?? '';

        // 3. Paparan Kad
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: kAccentOlive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kAccentOlive.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tajuk Emas Berkilau
              Row(
                children: [
                  const MetallicGold(child: Icon(Icons.menu_book, color: Colors.white, size: AppSizes.iconSm)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: MetallicGold(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair',
                          fontSize: AppFontSizes.lg
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Huraian
              Text(
                content,
                style: const TextStyle(color: kTextPrimary, height: 1.5, fontSize: AppFontSizes.sm + 1),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Footer / Sumber
              if (footer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    footer,
                    style: TextStyle(color: kPrimaryGold.withOpacity(0.8), fontStyle: FontStyle.italic, fontSize: AppFontSizes.xs),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}