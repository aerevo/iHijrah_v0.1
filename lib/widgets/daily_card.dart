// lib/widgets/daily_card.dart
// Kad harian full-screen — sama gaya dengan FeedCard

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

const List<Shadow> _kShadow = [
  Shadow(color: Color(0xCC000000), blurRadius: 8,  offset: Offset(0, 1)),
  Shadow(color: Color(0x88000000), blurRadius: 20, offset: Offset(0, 3)),
];

enum DailyCardType { hadith, amalan, sirah }

extension _Style on DailyCardType {
  Color get accent {
    switch (this) {
      case DailyCardType.hadith: return kPrimaryGold;
      case DailyCardType.amalan: return const Color(0xFF4ADE80);
      case DailyCardType.sirah:  return const Color(0xFF38BDF8);
    }
  }

  Color get bgTop {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFF1A1200);
      case DailyCardType.amalan: return const Color(0xFF001A0A);
      case DailyCardType.sirah:  return const Color(0xFF001018);
    }
  }

  Color get bgBot {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFF0A0800);
      case DailyCardType.amalan: return const Color(0xFF000D04);
      case DailyCardType.sirah:  return const Color(0xFF00080F);
    }
  }

  String get label {
    switch (this) {
      case DailyCardType.hadith: return '📖  HADITH HARIAN';
      case DailyCardType.amalan: return '⭐  AMALAN HARI INI';
      case DailyCardType.sirah:  return '📜  SIRAH HARI INI';
    }
  }
}

// ── SHELL ─────────────────────────────────────────────────────
class _DailyShell extends StatelessWidget {
  final DailyCardType type;
  final bool isCenter;
  final bool isSpecial;
  final String title;
  final String subtitle;
  final String meta;
  final String author;
  final Widget? trailingWidget;

  const _DailyShell({
    required this.type,
    required this.isCenter,
    required this.isSpecial,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.author,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = type.accent;

    return RepaintBoundary(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── BACKGROUND ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [type.bgTop, type.bgBot],
                ),
              ),
            ),

            // Subtle pattern overlay
            Opacity(
              opacity: 0.04,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.5),
                    radius: 1.2,
                    colors: [accent, Colors.transparent],
                  ),
                ),
              ),
            ),

            // ── GRADIENT OVERLAY bawah ───────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),

            // ── TYPE BADGE — top left ────────────────────────
            Positioned(
              top: 16,
              left: 16,
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
                        shadows: _kShadow,
                      ),
                    ),
                    if (isSpecial) ...[
                      const SizedBox(width: 4),
                      Text('✦',
                          style: TextStyle(
                              color: accent, fontSize: 8,
                              shadows: _kShadow)),
                    ],
                  ],
                ),
              ),
            ),

            // ── META — top right ─────────────────────────────
            Positioned(
              top: 18,
              right: 16,
              child: Text(
                meta,
                style: TextStyle(
                  color: accent.withOpacity(0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  shadows: _kShadow,
                ),
              ),
            ),

            // ── CAPTION BLOCK — bottom ───────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isCenter ? 20 : 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                        shadows: _kShadow,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: accent.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        shadows: _kShadow,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Footer
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.15),
                            border: Border.all(
                              color: accent.withOpacity(0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              type == DailyCardType.hadith
                                  ? '📖'
                                  : type == DailyCardType.amalan
                                      ? '⭐'
                                      : '📜',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                author,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: _kShadow,
                                ),
                              ),
                              Text(
                                'Hari ini',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color:
                                      Colors.white.withOpacity(0.45),
                                  shadows: _kShadow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trailingWidget != null) trailingWidget!,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PUBLIC CARDS ──────────────────────────────────────────────

class DailyHadithCard extends StatelessWidget {
  final HadithToday hadith;
  final bool isCenter;
  const DailyHadithCard(
      {Key? key, required this.hadith, required this.isCenter})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
        type: DailyCardType.hadith,
        isCenter: isCenter,
        isSpecial: hadith.isSpecial,
        title: hadith.text,
        subtitle: '— ${hadith.riwayat}',
        meta: hadith.topik,
        author: hadith.kategori,
      );
}

class DailyAmalanCard extends StatelessWidget {
  final AmalanToday amalan;
  final bool isCenter;
  final VoidCallback? onToggle;
  const DailyAmalanCard(
      {Key? key,
      required this.amalan,
      required this.isCenter,
      this.onToggle})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
        type: DailyCardType.amalan,
        isCenter: isCenter,
        isSpecial: amalan.type == 'khas',
        title: amalan.title,
        subtitle: amalan.reward.isNotEmpty ? amalan.reward : amalan.source,
        meta: amalan.type == 'khas' ? 'Tarikh Khas ✦' : 'Mingguan',
        author: amalan.source,
        trailingWidget: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amalan.isCompleted
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFF4ADE80).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF4ADE80)
                    .withOpacity(amalan.isCompleted ? 1 : 0.4),
                width: 1.5,
              ),
            ),
            child: amalan.isCompleted
                ? const Icon(Icons.check_rounded,
                    color: Colors.black, size: 16)
                : null,
          ),
        ),
      );
}

class DailySirahCard extends StatelessWidget {
  final SirahToday sirah;
  final bool isCenter;
  const DailySirahCard(
      {Key? key, required this.sirah, required this.isCenter})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
        type: DailyCardType.sirah,
        isCenter: isCenter,
        isSpecial: false,
        title: sirah.tajuk,
        subtitle: sirah.pengajaran,
        meta: sirah.tahun,
        author: sirah.lokasi,
      );
}
