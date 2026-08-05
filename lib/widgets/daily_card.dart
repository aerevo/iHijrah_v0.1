// lib/widgets/daily_card.dart  (V2 — Islamic Luxury Editorial)
//
// Rombak drpd shell gradient-rata + panel split (55/45) kepada foto
// FULL-BLEED + teks overlay bawah — bahasa visual SAMA macam FeedCard
// punya layout HERO (video), supaya jalur "HARI INI" & feed "KOMUNITI"
// rasa SATU sistem reka bentuk, bukan dua app berlainan.
//
// Takde foto unik ikut topik (hadith/amalan/sirah tiada assetPath),
// jadi guna SATU foto jenama (langit.png) merentasi ketiga-tiga jenis,
// dibezakan ikut TONA warna (gold/emerald/teal — sama makna semantik
// dgn kTypeVideo/kTypeArticle/dll di feed_card.dart), bukan tona rawak.
//
// Palette-aware PENUH (FeedPalette day/night) — versi lama guna const
// kCardDark/kTextPrimary yg tak reti tukar ikut Subuh/Maghrib, punca
// kad ni nampak tak sepadan dgn tema semasa di screenshot terdahulu.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_content_provider.dart';
import '../theme/feed_theme.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';
import 'premium_glass.dart';

// ── JENIS ─────────────────────────────────────────────────────
enum DailyCardType { hadith, amalan, sirah }

extension _Style on DailyCardType {
  Color get accent {
    switch (this) {
      case DailyCardType.hadith: return kPrimaryGold;
      case DailyCardType.amalan: return kAccentGreen;
      case DailyCardType.sirah:  return kAccentTeal;
    }
  }
  String get label {
    switch (this) {
      case DailyCardType.hadith: return 'HADITH HARIAN';
      case DailyCardType.amalan: return 'AMALAN HARI INI';
      case DailyCardType.sirah:  return 'SIRAH HARI INI';
    }
  }
  IconData get iconData {
    switch (this) {
      case DailyCardType.hadith: return Icons.menu_book_rounded;
      case DailyCardType.amalan: return Icons.spa_rounded;
      case DailyCardType.sirah:  return Icons.auto_stories_rounded;
    }
  }
}

// ── SHELL ─────────────────────────────────────────────────────
class _DailyShell extends StatelessWidget {
  final DailyCardType type;
  final FeedPalette palette;
  final bool isSpecial;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DailyShell({
    required this.type,
    required this.palette,
    required this.isSpecial,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = type.accent;

    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            boxShadow: palette.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto jenama universal, duotone ikut jenis (gaya Villa
              // Hermitage) — bukan foto lurus tanpa grading warna.
              Image.asset('assets/images/langit.png', fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withOpacity(0.50),
                      accent.withOpacity(0.12),
                      Colors.black.withOpacity(0.78),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),

              // Label jenis — atas kiri, kaca sebenar (PremiumGlass)
              Positioned(
                top: 12, left: 12,
                child: PopScaleIn(
                  delay: const Duration(milliseconds: 160),
                  child: PremiumGlass(
                    level: GlassLevel.badge,
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.iconData, size: 10, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(type.label,
                            style: const TextStyle(color: Colors.white, fontSize: 8,
                                fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                        if (isSpecial) ...[
                          const SizedBox(width: 3),
                          const Text('✦', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              if (trailing != null)
                Positioned(top: 10, right: 10, child: trailing!),

              // Teks — overlay terus atas foto, gaya sama dgn HERO
              // FeedCard (bukan panel putih terpisah lagi).
              Positioned(
                left: 14, right: 14, bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15.5, fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700, color: Colors.white, height: 1.3,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.82))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PUBLIC CARDS ──────────────────────────────────────────────
class DailyHadithCard extends StatelessWidget {
  final HadithToday hadith;
  final FeedPalette palette;
  const DailyHadithCard({Key? key, required this.hadith, required this.palette}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.hadith, palette: palette,
    isSpecial: hadith.isSpecial,
    title: hadith.text, subtitle: '— ${hadith.riwayat}',
  );
}

class DailyAmalanCard extends StatelessWidget {
  final AmalanToday amalan;
  final FeedPalette palette;
  final VoidCallback? onToggle;
  const DailyAmalanCard({Key? key, required this.amalan, required this.palette, this.onToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.amalan, palette: palette,
    isSpecial: amalan.type == 'khas',
    title: amalan.title, subtitle: amalan.source,
    trailing: GestureDetector(
      onTap: onToggle,
      child: PopScaleIn(
        delay: const Duration(milliseconds: 220),
        child: PremiumGlass(
          level: GlassLevel.badge,
          tint: amalan.isCompleted ? kAccentGreen : Colors.black,
          opacity: amalan.isCompleted ? 0.85 : 0.35,
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.all(5),
          child: Icon(
            amalan.isCompleted ? Icons.check_rounded : Icons.circle_outlined,
            color: Colors.white, size: 14,
          ),
        ),
      ),
    ),
  );
}

class DailySirahCard extends StatelessWidget {
  final SirahToday sirah;
  final FeedPalette palette;
  const DailySirahCard({Key? key, required this.sirah, required this.palette}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.sirah, palette: palette, isSpecial: false,
    title: sirah.tajuk, subtitle: sirah.pengajaran,
  );
}
