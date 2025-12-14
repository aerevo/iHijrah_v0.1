// lib/utils/hijri_service.dart (DEBUG VERSION)
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/foundation.dart';

class HijriService {
  static void _ensureLocale() {
    HijriCalendar.setLocal('en');
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

  static String calculateHijriAge(String hijriDOB) {
    // 🔍 DEBUG: Lihat apa data yang masuk
    if (kDebugMode) {
      print('🔍 DEBUG HijriAge: Input DOB = "$hijriDOB"');
    }

    if (hijriDOB.isEmpty) return "-- Tahun";
    
    try {
      final parts = hijriDOB.split('/');
      if (parts.length != 3) {
        print('⚠️ Format Tarikh Salah: $hijriDOB');
        return "Format Salah";
      }

      final dobDay = int.parse(parts[0]);
      final dobMonth = int.parse(parts[1]);
      final dobYear = int.parse(parts[2]);
      final today = nowHijri();

      int ageYears = today.hYear - dobYear;
      int ageMonths = today.hMonth - dobMonth;
      int ageDays = today.hDay - dobDay;

      if (ageDays < 0) {
        ageMonths--;
        final prevMonth = today.hMonth - 1 == 0 ? 12 : today.hMonth - 1;
        HijriCalendar prevDate = HijriCalendar();
        prevDate.hYear = today.hYear;
        prevDate.hMonth = prevMonth;
        ageDays += prevDate.lengthOfMonth;
      }

      if (ageMonths < 0) {
        ageYears--;
        ageMonths += 12;
      }
      
      String result = "$ageYears Tahun $ageMonths Bulan";
      print('✅ Umur Berjaya Dikira: $result');
      return result;

    } catch (e) {
      print('❌ Error Kira Umur: $e');
      return "-- Tahun";
    }
  }
  
  // ... (Kekalkan fungsi propheticAgeComparison, getDaysUntilNextBirthday, getDaysInCurrentMonth seperti sedia ada)
  static String propheticAgeComparison(String? hijriDOB) {
    if (hijriDOB == null || hijriDOB.isEmpty) return 'Belum disahkan.';
    try {
      final parts = hijriDOB.split('/');
      final dobYear = int.parse(parts[2]);
      final ageInYears = nowHijri().hYear - dobYear;

      if (ageInYears < 40) return 'Fasa Persediaan (Sebelum Kenabian).';
      if (ageInYears < 53) return 'Fasa Dakwah Mekah (Usia 40-53).';
      if (ageInYears <= 63) return 'Fasa Kenabian Madinah (Usia 53-63).';
      return 'Fasa Warisan (Usia > 63).';
    } catch (e) {
      return 'Ralat kalkulasi.';
    }
  }

  static int getDaysUntilNextBirthday(String? hijriDOB) {
    if (hijriDOB == null || hijriDOB.isEmpty) return 0;
    try {
      final parts = hijriDOB.split('/');
      final dobDay = int.parse(parts[0]);
      final dobMonth = int.parse(parts[1]);
      final today = nowHijri();

      int nextYear = today.hYear;
      if (today.hMonth > dobMonth || (today.hMonth == dobMonth && today.hDay >= dobDay)) {
        nextYear++;
      }

      final nextBday = HijriCalendar()
        ..hYear = nextYear
        ..hMonth = dobMonth
        ..hDay = dobDay;

      final todayG = DateTime.now();
      final nextBdayG = nextBday.hijriToGregorian(nextYear, dobMonth, dobDay);

      return nextBdayG.difference(todayG).inDays;
    } catch (e) {
      return 0;
    }
  }

  static int getDaysInCurrentMonth() {
    final today = nowHijri();
    return today.lengthOfMonth;
  }
}
