// lib/utils/hijri_service.dart (UPGRADED 7.8/10)

import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/foundation.dart';

/// Service untuk Hijri calendar calculations & conversions
/// 
/// Features:
/// - Convert Masihi to Hijri
/// - Calculate Hijri age
/// - Prophetic age comparison
/// - Days until next Hijri birthday
/// - Date formatting untuk UI
class HijriService {
  // ===== BASIC CONVERSIONS =====

  /// Get current Hijri date
  static HijriCalendar nowHijri() {
    return HijriCalendar.now();
  }

  /// Convert Masihi date to Hijri
  static HijriCalendar fromDate(DateTime date) {
    return HijriCalendar.fromGregorian(date);
  }

  /// Convert Masihi date to Hijri string (DD/MM/YYYY)
  static String convertToHijri(DateTime date) {
    final hijriDate = HijriCalendar.fromGregorian(date);
    return "${hijriDate.hDay}/${hijriDate.hMonth}/${hijriDate.hYear}";
  }

  /// Get current Hijri date as display string
  /// Format: "1 Muharram 1446H"
  static String nowDisplay() {
    final today = nowHijri();
    return "${today.hDay} ${today.getLongMonthName()} ${today.hYear}H";
  }

  // ===== DATE KEY FORMATTERS (FOR JSON LOOKUPS) =====

  /// Get today's Hijri date as text key untuk Event/Amalan Service
  /// Format: "1 muharram" (lowercase, no year)
  static String todayHijriTextKey() {
    final today = nowHijri();
    return "${today.hDay} ${today.getLongMonthName()}".toLowerCase();
  }

  /// Get today's Hijri date as numeric key untuk Sirah Service
  /// Format: "01-01" (MM-DD dengan leading zeros)
  static String todayHijriKey() {
    final today = nowHijri();
    final month = today.hMonth.toString().padLeft(2, '0');
    final day = today.hDay.toString().padLeft(2, '0');
    return "$month-$day";
  }

  /// Get Hijri key untuk tarikh tertentu
  static String getHijriKey(HijriCalendar date) {
    final month = date.hMonth.toString().padLeft(2, '0');
    final day = date.hDay.toString().padLeft(2, '0');
    return "$month-$day";
  }

  // ===== AGE CALCULATIONS =====

  /// Calculate Hijri age dari DOB string
  /// 
  /// Parameter hijriDOB format: "DD/MM/YYYY" (contoh: "15/3/1420")
  /// Returns: "25 Tahun 6 Bulan"
  static String calculateHijriAge(String hijriDOB) {
    if (hijriDOB.isEmpty) return "-- Tahun -- Bulan";

    try {
      final parts = hijriDOB.split('/');
      if (parts.length != 3) return "Format salah";

      final dobDay = int.parse(parts[0]);
      final dobMonth = int.parse(parts[1]);
      final dobYear = int.parse(parts[2]);

      final today = nowHijri();
      
      int ageYears = today.hYear - dobYear;
      int ageMonths = today.hMonth - dobMonth;
      int ageDays = today.hDay - dobDay;

      // Adjust untuk negative days
      if (ageDays < 0) {
        ageMonths--;
        // To get the length of the previous month, we can create a new Hijri object
        // for the previous month and get its length.
        final prevMonthDate = HijriCalendar()
          ..hYear = today.hYear
          ..hMonth = today.hMonth - 1
          ..hDay = 1;
        ageDays += prevMonthDate.lengthOfMonth;
      }

      // Adjust untuk negative months
      if (ageMonths < 0) {
        ageYears--;
        ageMonths += 12;
      }

      return "$ageYears Tahun $ageMonths Bulan";
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error calculating Hijri age: $e");
      }
      return "-- Tahun -- Bulan";
    }
  }

  /// Get age in years only (untuk simple display)
  static int getAgeInYears(String hijriDOB) {
    if (hijriDOB.isEmpty) return 0;

    try {
      final parts = hijriDOB.split('/');
      if (parts.length != 3) return 0;

      final dobYear = int.parse(parts[2]);
      final today = nowHijri();

      return today.hYear - dobYear;
    } catch (e) {
      return 0;
    }
  }

  // ===== PROPHETIC AGE COMPARISON =====

  /// Compare user's Hijri age dengan usia Nabi SAW
  /// 
  /// Returns fase kehidupan based on Prophetic timeline:
  /// - Before 40: Fasa Persediaan (sebelum Kenabian)
  /// - 40-53: Fasa Dakwah Mekah
  /// - 53-63: Fasa Kenabian Madinah
  /// - After 63: Fasa Warisan
  static String propheticAgeComparison(String? hijriDOB) {
    if (hijriDOB == null || hijriDOB.isEmpty) {
      return 'Belum disahkan.';
    }

    try {
      final ageInYears = getAgeInYears(hijriDOB);

      if (ageInYears < 40) {
        return 'Fasa Persediaan (Sebelum Kenabian).';
      } else if (ageInYears >= 40 && ageInYears < 53) {
        return 'Fasa Dakwah Mekah (Usia 40-53).';
      } else if (ageInYears >= 53 && ageInYears <= 63) {
        return 'Fasa Kenabian Madinah (Usia 53-63).';
      } else {
        return 'Fasa Warisan (Usia > 63).';
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in prophetic comparison: $e");
      }
      return 'Ralat kalkulasi fasa.';
    }
  }

  // ===== BIRTHDAY CALCULATIONS =====

  /// Get days until next Hijri birthday
  /// Returns: Number of days (0 if today is birthday)
  static int getDaysUntilNextBirthday(String? hijriDOB) {
    if (hijriDOB == null || hijriDOB.isEmpty) return 0;

    try {
      final parts = hijriDOB.split('/');
      if (parts.length != 3) return 0;

      final dobDay = int.parse(parts[0]);
      final dobMonth = int.parse(parts[1]);

      final today = nowHijri();
      
      // Determine next birthday year
      int nextYear = today.hYear;
      if (today.hMonth > dobMonth || 
          (today.hMonth == dobMonth && today.hDay >= dobDay)) {
        nextYear++;
      }

      // Create next birthday date object
      final nextBday = HijriCalendar()
        ..hYear = nextYear
        ..hMonth = dobMonth
        ..hDay = dobDay;

      // Calculate the difference in days using Julian Day numbers for accuracy
      final difference = nextBday.julianDay - today.julianDay;

      // Ensure the result is not negative
      return difference < 0 ? 0 : difference;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error calculating days to birthday: $e");
      }
      return 0;
    }
  }

  /// Check if today is user's Hijri birthday
  static bool isTodayBirthday(String? hijriDOB) {
    return getDaysUntilNextBirthday(hijriDOB) == 0;
  }

  // ===== DATE FORMATTING =====

  /// Format Hijri date untuk display
  /// Options: short, medium, long
  static String formatHijriDate(HijriCalendar date, {String format = 'medium'}) {
    switch (format) {
      case 'short':
        return "${date.hDay}/${date.hMonth}/${date.hYear}";
      case 'long':
        return "${date.hDay} ${date.getLongMonthName()} ${date.hYear} Hijrah";
      case 'medium':
      default:
        return "${date.hDay} ${date.getLongMonthName()} ${date.hYear}H";
    }
  }

  /// Get month name dalam Bahasa Melayu
  static String getMonthNameMalay(int month) {
    const monthNames = {
      1: 'Muharram',
      2: 'Safar',
      3: 'Rabiul Awal',
      4: 'Rabiul Akhir',
      5: 'Jamadil Awal',
      6: 'Jamadil Akhir',
      7: 'Rejab',
      8: 'Syaaban',
      9: 'Ramadan',
      10: 'Syawal',
      11: 'Zulkaedah',
      12: 'Zulhijjah',
    };

    return monthNames[month] ?? 'Unknown';
  }

  // ===== UTILITY =====

  /// Check if two Hijri dates are same day
  static bool isSameDay(HijriCalendar a, HijriCalendar b) {
    return a.hYear == b.hYear && 
           a.hMonth == b.hMonth && 
           a.hDay == b.hDay;
  }

  /// Get current Islamic year
  static int getCurrentYear() {
    return nowHijri().hYear;
  }

  /// Get days in current Hijri month
  static int getDaysInCurrentMonth() {
    final today = nowHijri();
    return today.lengthOfMonth;
  }

  // ===== DEBUG =====

  /// Print current Hijri & Gregorian dates (for debugging)
  static void debugPrintDates() {
    if (!kDebugMode) return;

    final hijri = nowHijri();
    final gregorian = DateTime.now();

    print('📅 Current Dates:');
    print('   Hijri: ${formatHijriDate(hijri, format: 'long')}');
    print('   Gregorian: ${gregorian.day}/${gregorian.month}/${gregorian.year}');
    print('   Key (MM-DD): ${todayHijriKey()}');
    print('   Text Key: ${todayHijriTextKey()}');
  }
}