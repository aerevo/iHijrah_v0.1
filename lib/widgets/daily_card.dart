// lib/widgets/daily_card.dart
// Kad harian — dark gold theme, lain dari FeedCard (putih)

import 'package:flutter/material.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

// ── JENIS KAD HARIAN ─────────────────────────────────────────
enum DailyCardType { hadith, amalan, sirah }

// ── WARNA IKUT JENIS ─────────────────────────────────────────
extension _DailyCardStyle on DailyCardType {
  Color get accent {
    switch (this) {
      case DailyCardType.hadith: return kPrimaryGold;
      case DailyCardType.amalan: return const Color(0xFF4ADE80); // emerald
      case DailyCardType.sirah:  return const Color(0xFF38BDF8); // teal
    }
  }

  Color get bg {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFF1A1500);
      case DailyCardType.amalan: return const Color(0xFF001A0A);
      case DailyCardType.sirah:  return const Color(0xFF001018);
    }
  }

  IconData get icon {
    switch (this) {
      case DailyCardType.hadith: return Icons.menu_book_rounded;
      case DailyCardType.amalan: return Icons.star_rounded;
      case DailyCardType.sirah:  return Icons.history_edu_rounded;
    }
  }

  String get label {
    switch (this) {
      case DailyCardType.hadith: return 'Hadith Harian';
      case DailyCardType.amalan: return 'Amalan Hari Ini';
      case DailyCardType.sirah:  return 'Sirah Hari Ini';
    }
  }
}

// ── KAD HADITH ───────────────────────────────────────────────
class DailyHadithCard extends StatelessWidget {
  final HadithToday hadith;
  final bool isCenter;

  const DailyHadithCard({
    Key? key,
    required this.hadith,
    this.isCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const type = DailyCardType.hadith;
    return _DailyCardShell(
      type: type,
      isCenter: isCenter,
      isSpecial: hadith.isSpecial,
      topRight: hadith.topik,
      title: hadith.text,
      subtitle: '— ${hadith.riwayat}',
      tag: hadith.kategori,
    );
  }
}

// ── KAD AMALAN ───────────────────────────────────────────────
class DailyAmalanCard extends StatelessWidget {
  final AmalanToday amalan;
  final bool isCenter;
  final VoidCallback? onToggle;

  const DailyAmalanCard({
    Key? key,
    required this.amalan,
    this.isCenter = false,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const type = DailyCardType.amalan;
    return _DailyCardShell(
      type: type,
      isCenter: isCenter,
      isSpecial: amalan.type == 'khas',
      topRight: amalan.type == 'khas' ? 'Tarikh Khas ✦' : 'Mingguan',
      title: amalan.title,
      subtitle: amalan.reward.isNotEmpty ? amalan.reward : amalan.source,
      tag: amalan.source,
      trailingWidget: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: amalan.isCompleted
                ? type.accent
                : type.accent.withOpacity(0.1),
            border: Border.all(
              color: type.accent.withOpacity(amalan.isCompleted ? 1 : 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            amalan.isCompleted ? Icons.check_rounded : null,
            color: Colors.black,
            size: 16,
          ),
        ),
      ),
    ),
    );
  }
}

// ── KAD SIRAH ────────────────────────────────────────────────
class DailySirahCard extends StatelessWidget {
  final SirahToday sirah;
  final bool isCenter;

  const DailySirahCard({
    Key? key,
    required this.sirah,
    this.isCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const type = DailyCardType.sirah;
    return _DailyCardShell(
      type: type,
      isCenter: isCenter,
      isSpecial: false,
      topRight: sirah.tahun,
      title: sirah.tajuk,
      subtitle: sirah.pengajaran,
      tag: sirah.lokasi,
    );
  }
}

// ── SHELL UTAMA (semua kad kongsi ni) ─────────────────────────
class _DailyCardShell extends StatelessWidget {
  final DailyCardType type;
  final bool isCenter;
  final bool isSpecial;
  final String topRight;
  final String title;
  final String subtitle;
  final String tag;
  final Widget? trailingWidget;

  const _DailyCardShell({
    required this.type,
    required this.isCenter,
    required this.isSpecial,
    required this.topRight,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = type.accent;
    final Color bg     = type.bg;

    return RepaintBoundary(
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isCenter ? bg : Color.fromARGB(
          (bg.alpha * 0.6).round(), bg.red, bg.green, bg.blue),
        border: Border.all(
          color: isCenter
              ? accent.withOpacity(0.55)
              : accent.withOpacity(0.15),
          width: isCenter ? 1.2 : 0.6,
        ),
        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 5),
                ),
              ]
            : const [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── ACCENT LINE KIRI ──────────────────────────
            Container(
              width: 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isCenter
                      ? [accent, accent.withOpacity(0.2)]
                      : [accent.withOpacity(0.3), accent.withOpacity(0.05)],
                ),
              ),
            ),

            // ── KANDUNGAN ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // [1] HEADER — label + tarikh/jenis
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accent.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon, size: 10, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                type.label,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
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
                        const Spacer(),
                        Text(
                          topRight,
                          style: TextStyle(
                            color: accent.withOpacity(
                                isCenter ? 0.6 : 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (trailingWidget != null) ...[
                          const SizedBox(width: 8),
                          trailingWidget!,
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // [2] TEKS UTAMA
                    Text(
                      title,
                      style: TextStyle(
                        color: isCenter
                            ? kTextPrimary
                            : kTextPrimary.withOpacity(0.55),
                        fontSize: isCenter ? 12.5 : 11,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                      maxLines: isCenter ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // [3] SUBTITLE — sumber/pengajaran
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: accent.withOpacity(isCenter ? 0.65 : 0.35),
                        fontSize: 9.5,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                      maxLines: isCenter ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // [4] TAG BAWAH
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: kTextSecondary.withOpacity(
                              isCenter ? 0.6 : 0.3),
                          fontSize: 8.5,
                          letterSpacing: 0.2,
                        ),
                      ),
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
