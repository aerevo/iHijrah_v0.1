// lib/utils/sirah_service.dart (UPGRADED 7.8/10)

import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'hijri_service.dart';
import 'result.dart';

/// Service untuk manage Sirah Nabi data (peristiwa harian)
/// 
/// Features:
/// - Load JSON data on app start
/// - Get Sirah untuk hari ini (based on Hijri date)
/// - Fallback data bila tiada peristiwa khas
/// - Error handling dengan Result<T, E>
class SirahService {
  static const String _path = AppAssets.sirahData;

  // ===== INITIALIZATION =====

  /// Load Sirah data dari JSON (call dalam main.dart)
  static Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<Map<String, dynamic>>(_path);
      
      if (kDebugMode) {
        print('✅ Sirah data loaded');
      }
      
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load Sirah data: $e');
      }
      return Result.failure('Gagal memuatkan data Sirah: $e');
    }
  }

  // ===== DATA RETRIEVAL =====

  /// Get Sirah untuk hari ini (Hijri date based)
  /// 
  /// Returns:
  /// - Entry dari JSON jika wujud
  /// - Default Sirah jika tiada entry khas
  static Future<Result<Map<String, dynamic>, String>> getSirahForToday() async {
    try {
      final data = BaseDataService.get<Map<String, dynamic>>(_path);

      // Safety check: Jika cache kosong, cuba reload
      if (data.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Sirah cache empty, attempting reload...');
        }
        
        final loadResult = await load();
        if (loadResult.isFailure) {
          // Gagal reload, return default
          return Result.success(_defaultSirah());
        }

        final reloadedData = BaseDataService.get<Map<String, dynamic>>(_path);
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
      
      // Bila error, return default supaya app tak crash
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

  /// Check if data loaded
  static bool get isLoaded {
    final data = BaseDataService.get<Map<String, dynamic>>(_path);
    return data.isNotEmpty;
  }

  /// Get total entries count
  static int get entriesCount {
    final data = BaseDataService.get<Map<String, dynamic>>(_path);
    return data.length;
  }

  // ===== DEBUG =====

  /// Print all loaded Sirah dates (for debugging)
  static void debugPrintAllDates() {
    if (!kDebugMode) return;

    final data = BaseDataService.get<Map<String, dynamic>>(_path);
    print('📖 Loaded Sirah entries: ${data.length}');
    
    if (data.isNotEmpty) {
      print('First 5 dates:');
      int count = 0;
      for (var key in data.keys) {
        if (count >= 5) break;
        print('  - $key: ${data[key]['peristiwa'] ?? 'N/A'}');
        count++;
      }
    }
  }
}
