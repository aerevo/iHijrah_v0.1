// lib/utils/sirah_service.dart (FIXED: EXTENDS CHANGENOTIFIER)
import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'hijri_service.dart';
import 'result.dart';

/// Service untuk manage Sirah Nabi data (peristiwa harian)
class SirahService extends ChangeNotifier {
  static const String _path = AppAssets.sirahData;

  // ===== INITIALIZATION =====
  /// Load Sirah data dari JSON (call dalam main.dart)
  Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<Map<String, dynamic>>(_path);
      if (kDebugMode) {
        print('✅ Sirah data loaded');
      }
      notifyListeners(); // Notify listeners bila data siap
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load Sirah data: $e');
      }
      return Result.failure('Gagal memuatkan data Sirah: $e');
    }
  }

  // ===== DATA RETRIEVAL (Instance Methods if needed via Provider, but keeping Statics for utility) =====

  /// Get Sirah untuk hari ini (Hijri date based)
  static Future<Result<Map<String, dynamic>, String>> getSirahForToday() async {
    try {
      final data = BaseDataService.get<Map<String, dynamic>>(_path);

      // Safety check: Jika cache kosong, cuba reload (Static call)
      if (data.isEmpty) {
        // Note: Can't call instance method load() here easily without refactoring,
        // assuming main.dart calls load() or BaseDataService handles it.
        final reloadedData = await BaseDataService.load<Map<String, dynamic>>(_path);
         if (reloadedData.isEmpty) {
          return Result.success(_defaultSirah());
        }
      }

      // Dapatkan kunci tarikh Hijri hari ini (format: "MM-DD")
      final todayKey = HijriService.todayHijriKey();

      // Cari entry yang match
      if (data.containsKey(todayKey)) {
        final entry = data[todayKey] as Map<String, dynamic>?;
        if (entry != null && entry.isNotEmpty) {
          if (kDebugMode) {
            print('📖 Sirah found for $todayKey');
          }
          return Result.success(entry);
        }
      }

      // Tiada entry khas, return default
      if (kDebugMode) {
        print('📖 No special Sirah for $todayKey, using default');
      }
      return Result.success(_defaultSirah());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting Sirah: $e');
      }
      return Result.success(_defaultSirah());
    }
  }

  /// Get Sirah untuk tarikh tertentu (optional - untuk calendar view)
  static Future<Result<Map<String, dynamic>, String>> getSirahForDate(String hijriKey) async {
    try {
      final data = BaseDataService.get<Map<String, dynamic>>(_path);
      if (data.isEmpty) {
        return Result.failure('Data Sirah tidak dimuatkan');
      }

      if (data.containsKey(hijriKey)) {
        final entry = data[hijriKey] as Map<String, dynamic>?;
        if (entry != null && entry.isNotEmpty) {
          return Result.success(entry);
        }
      }
      return Result.success(_defaultSirah());
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  /// Get all Sirah entries (untuk testing/debug)
  static Map<String, dynamic> getAllSirah() {
    return BaseDataService.get<Map<String, dynamic>>(_path);
  }

  // ===== PRIVATE HELPERS =====
  /// Data default bila tiada peristiwa khas
  static Map<String, dynamic> _defaultSirah() {
    final hijriToday = HijriService.nowHijri();
    return {
      'title': 'Peringatan Umum',
      'peristiwa': 'Peringatan Harian',
      'event': 'Tiada peristiwa Sirah besar direkodkan hari ini '
          '(${hijriToday.hDay} ${hijriToday.getLongMonthName()}).',
      'hadith': 'Hari yang baik untuk memperbanyakkan amal soleh dan Selawat.',
      'pengajaran': 'Setiap hari adalah peluang untuk mendekatkan diri kepada Allah SWT. '
          'Jadikan hari ini lebih baik daripada semalam.',
      'date_key': HijriService.todayHijriKey(),
    };
  }

  // ===== UTILITY =====
  static bool get isLoaded {
    final data = BaseDataService.get<Map<String, dynamic>>(_path);
    return data.isNotEmpty;
  }
}
