// lib/widgets/hadith_view.dart
//
// Skrin penuh untuk "Hadith Harian" — dibuka dari FlyoutPanel bila kad
// DailyHadithCard (di FeedPanel) ditekan. Struktur & gaya sengaja
// disalin drpd SirahView + SirahCard (header info + kad kandungan
// penuh, tiada maxLines/ellipsis) supaya konsisten dgn kad
// khazanah/misi harian yg dah sedia ada.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

class HadithView extends StatelessWidget {
  const HadithView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily  = context.watch<DailyContentProvider>();
    final hadith = daily.todayHadith;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── HEADER INFO ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPrimaryGold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: kPrimaryGold.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hadith Harian',
                      style: TextStyle(
                          color: kPrimaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                    if (hadith != null)
                      Text(
                        hadith.topik,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── KAD HADITH ─────────────────────────────────────
        if (daily.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: kPrimaryGold),
            ),
          )
        else if (hadith == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(color: kBorderSubtle),
            ),
            child: const Text(
              'Tiada data hadith untuk hari ini.',
              style: TextStyle(color: kTextSecondary, fontSize: 13),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(color: kBorderSubtle),
              boxShadow: [
                BoxShadow(
                    color: kPrimaryGold.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── HEADER KAD ─────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.cardRadiusLg)),
                    border: const Border(
                        bottom: BorderSide(color: kBorderSubtle, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: kPrimaryGold, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'HADITH HARIAN',
                        style: TextStyle(
                          color: kPrimaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      if (hadith.isSpecial)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kPrimaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: kPrimaryGold.withOpacity(0.25)),
                          ),
                          child: const Text(
                            '✦ Tarikh Khas',
                            style: TextStyle(
                                color: kPrimaryGold,
                                fontSize: 9,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── BODY ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Teks hadith PENUH — tiada maxLines/ellipsis,
                      // berbeza drpd DailyHadithCard (kad kecil di
                      // feed) yg had 3 baris sahaja.
                      Text(
                        hadith.text,
                        style: GoogleFonts.playfairDisplay(
                          color: kTextPrimary,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '— ${hadith.riwayat}',
                        style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _tag(hadith.topik),
                          _tag(hadith.kategori),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kBorderSubtle),
    ),
    child: Text(
      label,
      style: const TextStyle(color: kTextSecondary, fontSize: 11),
    ),
  );
}
