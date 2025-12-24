// lib/utils/hijri_service.dart (FINAL FIX: SUPPORTS GREGORIAN & HIJRI INPUTS)

import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/foundation.dart';

class HijriService {
  
  // Setup Locale
  static void _ensureLocale() {
    HijriCalendar.setLocal('en'); // Atau 'ms' jika package support
  }

  static HijriCalendar nowHijri() {
    _ensureLocale();
    return HijriCalendar.now();
  }

  static HijriCalendar fromDate(DateTime date) {
    _ensureLocale();
    return HijriCalendar.fromDate(date);
  }

  static String nowDisplay() {
    final today = nowHijri();
    return "${today.hDay} ${today.getLongMonthName()} ${today.hYear}H";
  }

  static String todayHijriKey() {
    final today = nowHijri();
    final month = today.hMonth.toString().padLeft(2, '0');
    final day = today.hDay.toString().padLeft(2, '0');
    return "$month-$day";
  }

  static String todayHijriTextKey() {
    final today = nowHijri();
    return "${today.hDay} ${today.getLongMonthName()}".toLowerCase();
  }

  // =================================================================
  // ✅ HELPER PINTAR: CONVERT APA SAJA TARIKH KE HIJRI OBJECT
  // =================================================================
  static HijriCalendar? _parseInputToHijri(String dateString) {
    if (dateString.isEmpty || dateString == 'null') return null;

    try {
      // KES 1: Tarikh Masihi ISO (Contoh: "1990-05-20T00:00:00") - Dari Onboarding Baru
      if (dateString.contains('-')) {
        DateTime gregorian = DateTime.parse(dateString);
        return HijriCalendar.fromDate(gregorian);
      }
      
      // KES 2: Tarikh Hijrah Lama (Contoh: "12/09/1410") - Dari Data Lama
      else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        var hDate = HijriCalendar();
        hDate.hDay = int.parse(parts[0]);
        hDate.hMonth = int.parse(parts[1]);
        hDate.hYear = int.parse(parts[2]);
        return hDate;
      }
    } catch (e) {
      if (kDebugMode) print("Error parsing date: $e");
    }
    return null;
  }

  // =================================================================
  // 1. KIRA UMUR HIJRAH (Auto Convert)
  // =================================================================
  static String calculateHijriAge(String dobString) {
    final dobHijri = _parseInputToHijri(dobString);
    if (dobHijri == null) return "--"; // Jika gagal parse

    try {
      final now = nowHijri();
      int age = now.hYear - dobHijri.hYear;

      // Fine-tuning: Jika belum sampai bulan/hari lahir tahun ini, tolak 1 tahun
      if (now.hMonth < dobHijri.hMonth) {
        age--;
      } else if (now.hMonth == dobHijri.hMonth && now.hDay < dobHijri.hDay) {
        age--;
      }

      if (age < 0) age = 0;
      return "$age Tahun";
    } catch (e) {
      return "--";
    }
  }

  // =================================================================
  // 2. BANDINGAN UMUR NABI (Auto Convert)
  // =================================================================
  static String propheticAgeComparison(String? dobString) {
    if (dobString == null) return 'Belum disahkan.';
    
    final dobHijri = _parseInputToHijri(dobString);
    if (dobHijri == null) return 'Data tidak lengkap.';

    try {
      final now = nowHijri();
      final ageInYears = now.hYear - dobHijri.hYear;

      if (ageInYears < 40) return 'Fasa Persediaan (Sebelum Kenabian).';
      if (ageInYears < 53) return 'Fasa Dakwah Mekah (Usia 40-53).';
      if (ageInYears <= 63) return 'Fasa Kenabian Madinah (Usia 53-63).';
      return 'Fasa Warisan (Usia > 63).';
    } catch (e) {
      return 'Ralat kalkulasi.';
    }
  }

  // =================================================================
  // 3. HARI HINGGA HARI JADI SETERUSNYA (Auto Convert)
  // =================================================================
  static int getDaysUntilNextBirthday(String? dobString) {
    if (dobString == null) return 0;

    final dobHijri = _parseInputToHijri(dobString);
    if (dobHijri == null) return 0;

    try {
      final today = nowHijri();
      
      // Kira tahun birthday seterusnya
      int nextBdayYear = today.hYear;
      
      // Jika bulan dah lepas, atau bulan sama tapi hari dah lepas -> Tahun depan
      if (today.hMonth > dobHijri.hMonth || 
         (today.hMonth == dobHijri.hMonth && today.hDay >= dobHijri.hDay)) {
        nextBdayYear++;
      }

      // Buat object Hijri untuk birthday seterusnya
      final nextBday = HijriCalendar();
      nextBday.hYear = nextBdayYear;
      nextBday.hMonth = dobHijri.hMonth;
      nextBday.hDay = dobHijri.hDay;

      // Convert kedua-duanya ke Masihi untuk kira beza hari (Sebab Hijri susah kira duration)
      // *Nota: HijriCalendar tak ada method .difference(), kena guna DateTime conversion
      // API HijriCalendar agak terhad, jadi kita guna anggaran kasar atau conversion balik:
      
      // Cara selamat: Convert ke DateTime (Masihi) untuk kiraan tepat
      DateTime todayGreg = today.hijriToGregorian(today.hYear, today.hMonth, today.hDay);
      DateTime nextBdayGreg = nextBday.hijriToGregorian(nextBday.hYear, nextBday.hMonth, nextBday.hDay);

      return nextBdayGreg.difference(todayGreg).inDays;

    } catch (e) {
      return 0;
    }
  }
}
