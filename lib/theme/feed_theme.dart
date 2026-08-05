// lib/theme/feed_theme.dart
//
// PALET SIANG/MALAM — "Islamic Luxury Editorial"
// ============================================================
// Siang = editorial krim (rujukan: Dribbble "Radiant") — kandungan
//         besar, minimum chrome, latar krim, badge disorok.
// Malam = luxury dark (rujukan: Dribbble "Villa Hermitage") — kad
//         gelap, garis emas nipis, glass, badge kembali kelihatan.
//
// PENTING — waktu tukar diikat pada Subuh/Maghrib SEBENAR
// (PrayerService, bukan jam sistem/dark-mode Android) — supaya ia
// sentiasa selari dengan waktu solat pengguna sendiri, bukan tengahari
// gelap sebab dia set dark-mode manual.
//
// `DayNightTheme` di bawah yang buat auto-transition tu "wired betul2":
// dia dengar PrayerService (yg dah tick setiap minit), pastu animate
// AnimationController.forward()/reverse() bila status Subuh↔Maghrib
// bertukar. FeedPalette.t (0=malam,1=siang) sampai ke setiap FeedCard
// SUDAH diselang-seli setiap frame semasa transition — jadi warna,
// shadow DAN kelihatan/hilang badge semua fade sekali, bukan snap.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../utils/prayer_service.dart';

@immutable
class FeedPalette {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color accent;
  final List<BoxShadow> cardShadow;

  /// 0.0 = malam penuh, 1.0 = siang penuh. Nilai di antara = sedang
  /// bertukar (Subuh/Maghrib baru lepas) — guna ni utk fade badge dsb,
  /// bukan boolean, supaya semua elemen crossfade serentak & lembut.
  final double t;

  const FeedPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.accent,
    required this.cardShadow,
    required this.t,
  });

  static const FeedPalette day = FeedPalette(
    background:    Color(0xFFF7F3EA),
    surface:       Color(0xFFFFFFFF),
    surfaceAlt:    Color(0xFFF1ECDF),
    textPrimary:   Color(0xFF201C14),
    textSecondary: Color(0xFF5C5646),
    textMuted:     Color(0xFF9C9584),
    divider:       Color(0x14201C14),
    accent:        kPrimaryGold,
    cardShadow: [
      BoxShadow(color: Color(0x14201C14), blurRadius: 24, offset: Offset(0, 10)),
    ],
    t: 1.0,
  );

  static const FeedPalette night = FeedPalette(
    background:    Color(0xFF13110D),
    surface:       Color(0xFF1C1913),
    surfaceAlt:    Color(0xFF211D16),
    textPrimary:   Color(0xFFF3EEE2),
    textSecondary: Color(0xFFB8AF9C),
    textMuted:     Color(0xFF7C7669),
    divider:       Color(0x33E8C46B), // hairline emas nipis
    accent:        kGoldLight,
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 14)),
    ],
    t: 0.0,
  );

  static FeedPalette lerp(FeedPalette a, FeedPalette b, double t) {
    return FeedPalette(
      background:    Color.lerp(a.background, b.background, t)!,
      surface:       Color.lerp(a.surface, b.surface, t)!,
      surfaceAlt:    Color.lerp(a.surfaceAlt, b.surfaceAlt, t)!,
      textPrimary:   Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textMuted:     Color.lerp(a.textMuted, b.textMuted, t)!,
      divider:       Color.lerp(a.divider, b.divider, t)!,
      accent:        Color.lerp(a.accent, b.accent, t)!,
      cardShadow: [
        BoxShadow(
          color: Color.lerp(a.cardShadow.first.color, b.cardShadow.first.color, t)!,
          blurRadius: _lerpD(a.cardShadow.first.blurRadius, b.cardShadow.first.blurRadius, t),
          offset: Offset.lerp(a.cardShadow.first.offset, b.cardShadow.first.offset, t)!,
        ),
      ],
      t: t,
    );
  }

  static double _lerpD(double a, double b, double t) => a + (b - a) * t;
}

/// Bekalkan [FeedPalette] yang beranimasi lembut kepada `builder`,
/// diikat pada PrayerService.isDayTime sebenar. Letak SEKALI di
/// home.dart, bukan berulang — anak widget terima palette siap lerp.
class DayNightTheme extends StatefulWidget {
  final Widget Function(BuildContext context, FeedPalette palette) builder;
  const DayNightTheme({Key? key, required this.builder}) : super(key: key);

  @override
  State<DayNightTheme> createState() => _DayNightThemeState();
}

class _DayNightThemeState extends State<DayNightTheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool? _lastIsDay;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _applySystemChrome(bool isDay) {
    // Status bar & nav bar Android/iOS pun ikut tema — kalau tak, ikon
    // jam/bateri jadi gelap-atas-gelap masa malam (tak boleh baca).
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDay ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDay ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          isDay ? const Color(0xFFF7F3EA) : const Color(0xFF13110D),
      systemNavigationBarIconBrightness:
          isDay ? Brightness.dark : Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDay = context.watch<PrayerService>().isDayTime;

    if (_lastIsDay == null) {
      // Frame pertama — terus set kedudukan betul, TIADA animasi (elak
      // kelipan warna masa app baru dibuka).
      _ctrl.value = isDay ? 1.0 : 0.0;
      _lastIsDay = isDay;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _applySystemChrome(isDay));
    } else if (_lastIsDay != isDay) {
      // Subuh atau Maghrib baru berlaku — animate lembut ke tema baharu.
      _lastIsDay = isDay;
      isDay ? _ctrl.forward() : _ctrl.reverse();
      _applySystemChrome(isDay);
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final double t = Curves.easeInOutCubic.transform(_ctrl.value);
        return widget.builder(
            context, FeedPalette.lerp(FeedPalette.night, FeedPalette.day, t));
      },
    );
  }
}
