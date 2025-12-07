// lib/widgets/about_view.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import 'metallic_gold.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Handle error silently
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MetallicGold(
            child: Text(
              "Aplikasi iHijrah", 
              style: TextStyle(
                color: kTextPrimary, 
                fontSize: AppFontSizes.xl, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair'
              )
            )
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Versi 1.0.0 (Gold & Dark Theme)", 
            style: TextStyle(color: kPrimaryGold.withOpacity(0.8), fontSize: AppFontSizes.sm)
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            "iHijrah ialah peneman ibadah harian yang membantu anda menjejak konsistensi melalui visualisasi Pokok Hijrah. Dicipta oleh Zyamina Studio.",
            style: TextStyle(color: kTextSecondary, height: 1.5, fontSize: AppFontSizes.md),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.star, color: kCardDark),
              label: const Text("Nilai Aplikasi", style: TextStyle(color: kCardDark, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentOlive,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.buttonHeightMd * 0.3), 
              ),
              onPressed: () => _launchURL('https://play.google.com/store/apps'),
            ),
          ),
        ],
      ),
    );
  }
}