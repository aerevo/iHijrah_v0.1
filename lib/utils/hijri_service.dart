// lib/utils/hijri_service.dart
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/foundation.dart';

class HijriService {

  // ── NAMA BULAN HIJRI (MELAYU) ──────────────────────────────
  static const List<String> _bulanMelayu = [
    'Muharram', 'Safar', 'Rabiulawal', 'Rabiulakhir',
    'Jamadilawal', 'Jamadilakhir', 'Rejab', 'Syaaban',
    'Ramadan', 'Syawal', 'Zulkaedah', 'Zulhijjah',
  ];

  static const List<String> _bulanArab = [
    'مُحَرَّم', 'صَفَر', 'رَبِيع الأَوَّل', 'رَبِيع الثَّانِي',
    'جُمَادَى الأُولَى', 'جُمَادَى الآخِرَة', 'رَجَب', 'شَعْبَان',
    'رَمَضَان', 'شَوَّال', 'ذُو القَعْدَة', 'ذُو الحِجَّة',
  ];

  static void _ensureLocale() => HijriCalendar.setLocal('en');

  // ── ASAS ─────────────────────────────────────────────────────
  static HijriCalendar nowHijri() {
    _ensureLocale();
    return HijriCalendar.now();
  }

  static HijriCalendar fromDate(DateTime date) {
    _ensureLocale();
    return HijriCalendar.fromDate(date);
  }

  // ── FORMAT DISPLAY ────────────────────────────────────────────
  /// "15 Ramadan 1446H"
  static String nowDisplay() {
    final h = nowHijri();
    return '${h.hDay} ${bulanMelayu(h.hMonth)} ${h.hYear}H';
  }

  /// "15 Ramadan 1446H" dari DateTime
  static String fromDateDisplay(DateTime date) {
    final h = fromDate(date);
    return '${h.hDay} ${bulanMelayu(h.hMonth)} ${h.hYear}H';
  }

  /// Nama bulan Melayu dari nombor (1-12)
  static String bulanMelayu(int month) {
    if (month < 1 || month > 12) return '';
    return _bulanMelayu[month - 1];
  }

  /// Nama bulan Arab dari nombor (1-12)
  static String bulanArab(int month) {
    if (month < 1 || month > 12) return '';
    return _bulanArab[month - 1];
  }

  /// Key untuk matching JSON: "05-15"
  static String todayHijriKey() {
    final h = nowHijri();
    return '${h.hMonth.toString().padLeft(2, '0')}-${h.hDay.toString().padLeft(2, '0')}';
  }

  /// Key untuk hadith special: "15 Ramadan"
  static String todayHijriTextKey() {
    final h = nowHijri();
    return '${h.hDay} ${bulanMelayu(h.hMonth)}';
  }

  // ── PARSE INPUT ───────────────────────────────────────────────
  static HijriCalendar? _parse(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'null') return null;
    try {
      if (dateString.contains('-') && dateString.contains('T') ||
          dateString.contains('-') && dateString.length >= 8) {
        return HijriCalendar.fromDate(DateTime.parse(dateString));
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        final h = HijriCalendar();
        h.hDay   = int.parse(parts[0]);
        h.hMonth = int.parse(parts[1]);
        h.hYear  = int.parse(parts[2]);
        return h;
      }
    } catch (e) {
      if (kDebugMode) print('HijriService parse error: $e');
    }
    return null;
  }

  // ── UMUR HIJRI ────────────────────────────────────────────────
  /// Pulangkan string "34 Tahun"
  static String calculateHijriAge(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return '--';
    try {
      final now = nowHijri();
      int age = now.hYear - dob.hYear;
      if (now.hMonth < dob.hMonth) age--;
      else if (now.hMonth == dob.hMonth && now.hDay < dob.hDay) age--;
      return '${age < 0 ? 0 : age} Tahun';
    } catch (_) { return '--'; }
  }

  /// Pulangkan int umur sahaja
  static int hijriAgeInt(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return 0;
    try {
      final now = nowHijri();
      int age = now.hYear - dob.hYear;
      if (now.hMonth < dob.hMonth) age--;
      else if (now.hMonth == dob.hMonth && now.hDay < dob.hDay) age--;
      return age < 0 ? 0 : age;
    } catch (_) { return 0; }
  }

  // ── HARI JADI ─────────────────────────────────────────────────
  /// Adakah hari ini hari jadi Hijri user?
  static bool isBirthdayToday(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return false;
    final now = nowHijri();
    return now.hDay == dob.hDay && now.hMonth == dob.hMonth;
  }

  /// Berapa hari lagi hari jadi Hijri?
  static int getDaysUntilNextBirthday(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return 0;
    try {
      final today = nowHijri();
      int nextYear = today.hYear;
      if (today.hMonth > dob.hMonth ||
          (today.hMonth == dob.hMonth && today.hDay >= dob.hDay)) {
        nextYear++;
      }
      final nextBday = HijriCalendar()
        ..hYear  = nextYear
        ..hMonth = dob.hMonth
        ..hDay   = dob.hDay;

      final todayGreg   = today.hijriToGregorian(today.hYear, today.hMonth, today.hDay);
      final bdayGreg    = nextBday.hijriToGregorian(nextBday.hYear, nextBday.hMonth, nextBday.hDay);
      return bdayGreg.difference(todayGreg).inDays;
    } catch (_) { return 0; }
  }

  /// "15 Ramadan" — tarikh hari jadi Hijri dalam format display
  static String birthdayDisplay(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return '--';
    return '${dob.hDay} ${bulanMelayu(dob.hMonth)}';
  }

  // ── FASA KENABIAN ─────────────────────────────────────────────
  static String propheticAgeComparison(String? dobString) {
    final dob = _parse(dobString);
    if (dob == null) return 'Belum disahkan.';
    try {
      final now = nowHijri();
      final age = now.hYear - dob.hYear;
      if (age < 25)  return 'Usia Belia — Masa untuk membina asas.';
      if (age < 40)  return 'Fasa Persediaan — Menuju kematangan.';
      if (age < 53)  return 'Fasa Dakwah Mekah (40-53H) — Usia Nabi menerima wahyu.';
      if (age <= 63) return 'Fasa Kenabian Madinah (53-63H) — Zaman kegemilangan.';
      return 'Fasa Warisan — Meninggalkan legasi.';
    } catch (_) { return 'Ralat kalkulasi.'; }
  }

  // ── BULAN ISTIMEWA ────────────────────────────────────────────
  /// Adakah bulan ini bulan istimewa?
  static String? getBulanIstimewa() {
    final now = nowHijri();
    switch (now.hMonth) {
      case 1:  return 'Muharram — Bulan Allah';
      case 7:  return 'Rejab — Bulan Israk Mikraj';
      case 8:  return 'Syaaban — Bulan Persiapan Ramadan';
      case 9:  return 'Ramadan — Bulan Al-Quran';
      case 10: return 'Syawal — Bulan Kemenangan';
      case 12: return 'Zulhijjah — Bulan Haji & Korban';
      default: return null;
    }
  }
}
