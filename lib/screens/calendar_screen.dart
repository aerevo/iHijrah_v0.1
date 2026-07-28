// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../widgets/metallic_gold.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _viewYear;
  late int _viewMonth;

  static const List<String> _days  = ['Ahd','Isn','Sel','Rab','Kha','Jum','Sab'];

  @override
  void initState() {
    super.initState();
    final now = HijriService.nowHijri();
    _viewYear  = now.hYear;
    _viewMonth = now.hMonth;
  }

  void _prev() => setState(() {
    if (_viewMonth == 1) { _viewMonth = 12; _viewYear--; }
    else { _viewMonth--; }
  });

  void _next() => setState(() {
    if (_viewMonth == 12) { _viewMonth = 1; _viewYear++; }
    else { _viewMonth++; }
  });

  // Cari hari pertama bulan (0=Ahad..6=Sabtu)
  int _firstWeekday(int year, int month) {
    try {
      final h = HijriCalendar()
        ..hYear  = year
        ..hMonth = month
        ..hDay   = 1;
      final g = h.hijriToGregorian(year, month, 1);
      return g.weekday % 7; // Flutter: 1=Mon..7=Sun → kita nak 0=Sun
    } catch (_) { return 0; }
  }

  // Bilangan hari dalam bulan Hijri (29 atau 30)
  int _daysInMonth(int year, int month) {
    try {
      final last30 = HijriCalendar()
        ..hYear  = year
        ..hMonth = month
        ..hDay   = 30;
      // Cuba convert — kalau valid, bulan ada 30 hari
      last30.hijriToGregorian(year, month, 30);
      return 30;
    } catch (_) { return 29; }
  }

  @override
  Widget build(BuildContext context) {
    final now       = HijriService.nowHijri();
    final isNowView = now.hYear == _viewYear && now.hMonth == _viewMonth;
    final days      = _daysInMonth(_viewYear, _viewMonth);
    final offset    = _firstWeekday(_viewYear, _viewMonth);
    final total     = offset + days;
    final rows      = (total / 7).ceil();
    final cells     = rows * 7;

    return Column(
      children: [

        // ── NAVIGATION HEADER ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                onPressed: _prev,
                icon: const Icon(Icons.chevron_left_rounded,
                    color: kTextSecondary),
              ),
              Expanded(
                child: Center(
                  child: MetallicGold(
                    child: Text(
                      '${HijriService.bulanMelayu(_viewMonth)} $_viewYear H',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: AppFontSizes.lg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _next,
                icon: const Icon(Icons.chevron_right_rounded,
                    color: kTextSecondary),
              ),
            ],
          ),
        ),

        // ── NAMA HARI ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _days.map((d) => SizedBox(
              width: 36,
              child: Text(d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: kAccentOlive,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            )).toList(),
          ),
        ),

        const SizedBox(height: 6),

        // ── GRID HARI ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: cells,
            itemBuilder: (_, i) {
              if (i < offset || i >= offset + days) {
                return const SizedBox.shrink();
              }
              final day     = i - offset + 1;
              final isToday = isNowView && day == now.hDay;

              return Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? kPrimaryGold
                      : kCardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday
                        ? kPrimaryGold
                        : kBorderSubtle,
                    width: isToday ? 0 : 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isToday
                        ? kBackgroundDark
                        : kTextPrimary,
                    fontSize: 11,
                    fontWeight: isToday
                        ? FontWeight.w800
                        : FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── INFO FOOTER ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(
                  color: kPrimaryGold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: kPrimaryGold, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puasa sunat Ayyamul Bidh: 13, 14, 15 '
                    '${HijriService.bulanMelayu(_viewMonth)} $_viewYear H',
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 10.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
