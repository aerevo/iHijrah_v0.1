// lib/widgets/daily_card.dart
// Kad harian — Apple Vision Pro Style (Dark Glassmorphism)
// Konsisten dengan FeedCard theme

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

const List<Shadow> _kShadow = [
  Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 1)),
  Shadow(color: Color(0x88000000), blurRadius: 20, offset: Offset(0, 3)),
];

enum DailyCardType { hadith, amalan, sirah }

extension _Style on DailyCardType {
  Color get accent {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFFF59E0B);  // Gold
      case DailyCardType.amalan: return const Color(0xFF4ADE80);  // Green
      case DailyCardType.sirah:  return const Color(0xFF38BDF8);  // Sky Blue
    }
  }

  Color get bgTop {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFF1E293B);  // Slate-800
      case DailyCardType.amalan: return const Color(0xFF1E293B);
      case DailyCardType.sirah:  return const Color(0xFF1E293B);
    }
  }

  Color get bgBot {
    switch (this) {
      case DailyCardType.hadith: return const Color(0xFF0F172A);  // Slate-900
      case DailyCardType.amalan: return const Color(0xFF0F172A);
      case DailyCardType.sirah:  return const Color(0xFF0F172A);
    }
  }

  String get label {
    switch (this) {
      case DailyCardType.hadith: return 'HADITH HARIAN';
      case DailyCardType.amalan: return 'AMALAN HARI INI';
      case DailyCardType.sirah:  return 'SIRAH HARI INI';
    }
  }

  IconData get icon {
    switch (this) {
      case DailyCardType.hadith: return Icons.auto_stories_rounded;
      case DailyCardType.amalan: return Icons.star_rounded;
      case DailyCardType.sirah:  return Icons.history_rounded;
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            if (isCenter)
              BoxShadow(
                color: accent.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    type.bgTop.withOpacity(0.95),
                    type.bgBot.withOpacity(0.85),
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle pattern overlay
                  Opacity(
                    opacity: 0.03,
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

                  // ── TYPE BADGE — top left ────────────────────────
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 12,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.label,
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              shadows: _kShadow,
                            ),
                          ),
                          if (isSpecial) ...[
                            const SizedBox(width: 4),
                            Text(
                              '✦',
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                shadows: _kShadow,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── META — top right ─────────────────────────────
                  Positioned(
                    top: 18,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meta,
                        style: TextStyle(
                          color: accent.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          shadows: _kShadow,
                        ),
                      ),
                    ),
                  ),

                  // ── CONTENT AREA — center ───────────────────────
                  Positioned(
                    top: 60,
                    left: 20,
                    right: 20,
                    bottom: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: isCenter ? 22 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.3,
                            shadows: _kShadow,
                          ),
                          maxLines: isCenter ? 4 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: accent.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            shadows: _kShadow,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // ── FOOTER — bottom ────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.15),
                              border: Border.all(
                                color: accent.withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              type.icon,
                              color: accent,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: Colors.white.withOpacity(0.5),
                                    shadows: _kShadow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (trailingWidget != null) trailingWidget!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
  const DailyHadithCard({
    Key? key,
    required this.hadith,
    required this.isCenter,
  }) : super(key: key);

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
  const DailyAmalanCard({
    Key? key,
    required this.amalan,
    required this.isCenter,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _DailyShell(
        type: DailyCardType.amalan,
        isCenter: isCenter,
        isSpecial: amalan.type == 'khas',
        title: amalan.title,
        subtitle: amalan.reward.isNotEmpty
            ? amalan.reward
            : amalan.source,
        meta: amalan.type == 'khas' ? 'Khas ✦' : 'Mingguan',
        author: amalan.source,
        trailingWidget: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
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
                    color: Colors.black, size: 18)
                : Icon(
                    Icons.add_rounded,
                    color: const Color(0xFF4ADE80).withOpacity(0.6),
                    size: 18,
                  ),
          ),
        ),
      );
}

class DailySirahCard extends StatelessWidget {
  final SirahToday sirah;
  final bool isCenter;
  const DailySirahCard({
    Key? key,
    required this.sirah,
    required this.isCenter,
  }) : super(key: key);

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
