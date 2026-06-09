// lib/widgets/sirah_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class SirahCard extends StatelessWidget {
  const SirahCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyContentProvider>();
    final sirah    = provider.todaySirah;
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

    if (sirah == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardDark,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(color: kBorderSubtle),
        ),
        child: const Text(
          'Tiada data sirah untuk hari ini.',
          style: TextStyle(color: kTextSecondary, fontSize: 13),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: kBorderSubtle),
        boxShadow: [
          BoxShadow(
              color: kAccentTeal.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: kAccentTeal.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.cardRadiusLg)),
              border: const Border(
                  bottom: BorderSide(color: kBorderSubtle, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded,
                    color: kAccentTeal, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'SIRAH HARI INI',
                  style: TextStyle(
                    color: kAccentTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: kPrimaryGold.withOpacity(0.25)),
                  ),
                  child: Text(
                    sirah.tahun,
                    style: const TextStyle(
                        color: kPrimaryGold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Tajuk
                Text(
                  sirah.tajuk,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    fontFamily: 'Playfair',
                  ),
                ),

                const SizedBox(height: 6),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: kTextMuted, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      sirah.lokasi,
                      style: const TextStyle(
                          color: kTextMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Pengajaran
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius:
                        BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(color: kBorderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sirah.pengajaran,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
