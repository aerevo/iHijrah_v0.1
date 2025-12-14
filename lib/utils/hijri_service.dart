// lib/utils/hijri_service.dart
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

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

  // ✅ FIXED LOGIC: Handle empty string & format error gracefully
  static String calculateHijriAge(String hijriDOB) {
    // Debug print untuk tengok apa data yang masuk
    if (kDebugMode) {
      print('🔍 DEBUG HijriAge Input: "$hijriDOB"');
    }

    if (hijriDOB.isEmpty) return "-- Tahun";
    if (hijriDOB == 'null') return "-- Tahun"; // Extra safety

    try {
      final parts = hijriDOB.split('/');
      
      // Jika format tak kena (bukan 3 bahagian), return error
      if (parts.length != 3) {
        print('⚠️ Format Tarikh Salah: $hijriDOB');
        return "-- Tahun";
      }

      final dobDay = int.parse(parts[0]);
      final dobMonth = int.parse(parts[1]);
      final dobYear = int.parse(parts[2]);
      final today = nowHijri();

      int ageYears = today.hYear - dobYear;
      int ageMonths = today.hMonth - dobMonth;
      int ageDays = today.hDay - dobDay;

      // Logic standard kira umur (adjust bulan/hari)
      if (ageDays < 0) {
        ageMonths--;
        final prevMonth = today.hMonth - 1 == 0 ? 12 : today.hMonth - 1;
        
        HijriCalendar prevDate = HijriCalendar();
        prevDate.hYear = today.hYear;
        prevDate.hMonth = prevMonth;
        
        // Handle lengthOfMonth dengan selamat
        ageDays += prevDate.lengthOfMonth; 
      }

      if (ageMonths < 0) {
        ageYears--;
        ageMonths += 12;
      }
      
      String result = "$ageYears Tahun $ageMonths Bulan";
      if (kDebugMode) print('✅ Calculated Age: $result');
      
      return result;

    } catch (e) {
      print('❌ Error Kira Umur: $e');
      return "-- Tahun";
    }
  }

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
