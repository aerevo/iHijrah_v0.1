// lib/widgets/daily_card.dart
// Gaya sama dengan FeedCard — gambar atas (gradient), info bawah

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';

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
  List<Color> get gradColors {
    switch (this) {
      case DailyCardType.hadith: return [const Color(0xFF8A6215), const Color(0xFFD9A62A)];
      case DailyCardType.amalan: return [const Color(0xFF0B5C3E), const Color(0xFF159E71)];
      case DailyCardType.sirah:  return [const Color(0xFF0F5A73), const Color(0xFF2AA7C4)];
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
  final bool   isCenter;
  final bool   isSpecial;
  final String title;
  final String subtitle;
  final String meta;
  final String author;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DailyShell({
    required this.type,
    required this.isCenter,
    required this.isSpecial,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.author,
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
          color: kCardDark,
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [

            // ── BAHAGIAN ATAS — Gradient + konten (55%) ────
            Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: type.gradColors,
                      ),
                    ),
                  ),

                  // Halus glow accent di sudut
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fade bawah
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kCardDark.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Label type — kiri atas (pop-in lembut)
                  Positioned(
                    top: 14, left: 14,
                    child: PopScaleIn(
                      delay: const Duration(milliseconds: 160),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accent.withOpacity(0.4), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.label,
                              style: TextStyle(
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            if (isSpecial) ...[
                              const SizedBox(width: 4),
                              Text('✦',
                                  style: TextStyle(
                                      color: accent, fontSize: 8)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Meta — kanan atas (sorok bila kad kecil, tiada ruang cukup)
                  if (isCenter)
                    Positioned(
                      top: 16, right: 14,
                      child: Text(
                        meta,
                        style: TextStyle(
                          color: accent.withOpacity(0.65),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Ikon besar tengah
                  Center(
                    child: Icon(
                      type.iconData,
                      size: isCenter ? 56 : 44,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Garis
            Container(height: 0.5, color: kBorderSubtle),

            // ── BAHAGIAN BAWAH — Teks (45%) ────────────────
            Expanded(
              flex: 45,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: kCardDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Tajuk/teks utama
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isCenter ? 16 : 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Sumber
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: accent.withOpacity(0.75),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Footer
                    Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.12),
                            border: Border.all(
                                color: accent.withOpacity(0.35), width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              type.iconData,
                              size: 13,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'Hari ini',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ],
                ),
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
  final bool isCenter;
  const DailyHadithCard({Key? key, required this.hadith, required this.isCenter}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.hadith, isCenter: isCenter,
    isSpecial: hadith.isSpecial,
    title: hadith.text, subtitle: '— ${hadith.riwayat}',
    meta: hadith.topik, author: hadith.kategori,
  );
}

class DailyAmalanCard extends StatelessWidget {
  final AmalanToday amalan;
  final bool isCenter;
  final VoidCallback? onToggle;
  const DailyAmalanCard({Key? key, required this.amalan, required this.isCenter, this.onToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.amalan, isCenter: isCenter,
    isSpecial: amalan.type == 'khas',
    title: amalan.title, subtitle: amalan.source,
    meta: amalan.type == 'khas' ? 'Tarikh Khas ✦' : 'Mingguan',
    author: amalan.source,
    trailing: GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: amalan.isCompleted
              ? kAccentGreen : kAccentGreen.withOpacity(0.1),
          border: Border.all(
            color: kAccentGreen.withOpacity(amalan.isCompleted ? 1 : 0.4),
            width: 1.5,
          ),
        ),
        child: amalan.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.black, size: 15)
            : null,
      ),
    ),
  );
}

class DailySirahCard extends StatelessWidget {
  final SirahToday sirah;
  final bool isCenter;
  const DailySirahCard({Key? key, required this.sirah, required this.isCenter}) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
    type: DailyCardType.sirah, isCenter: isCenter, isSpecial: false,
    title: sirah.tajuk, subtitle: sirah.pengajaran,
    meta: sirah.tahun, author: sirah.lokasi,
  );
}
