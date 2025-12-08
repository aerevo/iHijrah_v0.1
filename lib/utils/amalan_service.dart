// lib/utils/amalan_service.dart (UPGRADED 7.8/10)

import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'result.dart';

/// Service untuk manage Amalan Sunnah data (daily recommendations)
///
/// Features:
/// - Load amalan data dari JSON
/// - Filter by day (Jumaat, Isnin, etc)
/// - Filter by special dates (10 Muharram, Ramadan, etc)
/// - Daily amalan that apply every day
class AmalanService {
  static const String _path = AppAssets.amalanSunnahData;

  // ===== INITIALIZATION =====

  /// Load amalan data dari JSON (call dalam main.dart)
  static Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (kDebugMode) {
        print('✅ Amalan data loaded');
      }

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load Amalan data: $e');
      }
      return Result.failure('Gagal memuatkan data amalan: $e');
    }
  }

  // ===== DATA RETRIEVAL =====

  /// Get amalan untuk hari tertentu
  ///
  /// Parameters:
  /// - dayName: Nama hari dalam Inggeris (Monday, Friday, etc)
  /// - dayNumber: Nombor hari (1-30)
  /// - textKey: Tarikh Hijri text (contoh: "10 muharram")
  ///
  /// Returns:
  /// - List of amalan yang sesuai untuk hari ini
  static Future<Result<List<Map<String, dynamic>>, String>> getForDay(
    String dayName,
    int dayNumber,
    String textKey,
  ) async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (data.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Amalan data is empty');
        }
        return Result.success([]);
      }

      final dayNameLower = dayName.toLowerCase();
      final textKeyLower = textKey.toLowerCase();

      List<Map<String, dynamic>> filteredAmalan = [];

      for (var amalan in data) {
        final hari = (amalan['hari'] as String? ?? '').toLowerCase();

        bool shouldAdd = false;

        // A. Amalan Harian (setiap hari)
        if (hari == 'setiap hari' || hari == 'harian' || hari == 'daily') {
          shouldAdd = true;
        }
        // B. Amalan Mingguan (contoh: Jumaat)
        else if (hari == dayNameLower || hari == _translateDay(dayNameLower)) {
          shouldAdd = true;
        }
        // C. Amalan Tarikh Khas (contoh: 10 Muharram, 15 Syaaban)
        else if (hari == textKeyLower) {
          shouldAdd = true;
        }

        if (shouldAdd) {
          filteredAmalan.add(amalan);
        }
      }

      if (kDebugMode) {
        print('📿 Found ${filteredAmalan.length} amalan for $dayNameLower / $textKeyLower');
      }

      return Result.success(filteredAmalan);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting amalan: $e');
      }
      return Result.failure('Ralat mendapatkan amalan: $e');
    }
  }

  /// Get all amalan (untuk reference/settings)
  static Future<Result<List<Map<String, dynamic>>, String>> getAll() async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (kDebugMode) {
        print('📿 Loaded ${data.length} amalan');
      }

      return Result.success(data);
    } catch (e) {
      return Result.failure('Gagal memuatkan senarai amalan: $e');
    }
  }

  /// Get daily amalan (yang apply setiap hari)
  static Future<Result<List<Map<String, dynamic>>, String>> getDailyAmalan() async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      final daily = allData.data!.where((amalan) {
        final hari = (amalan['hari'] as String? ?? '').toLowerCase();
        return hari == 'setiap hari' || hari == 'harian' || hari == 'daily';
      }).toList();

      return Result.success(daily);
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  /// Get amalan by category (if JSON has category field)
  static Future<Result<List<Map<String, dynamic>>, String>> getByCategory(String category) async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      final categoryLower = category.toLowerCase();

      final filtered = allData.data!.where((amalan) {
        final amalanCategory = (amalan['kategori'] as String? ?? '').toLowerCase();
        return amalanCategory == categoryLower;
      }).toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  /// Search amalan by keyword
  static Future<Result<List<Map<String, dynamic>>, String>> search(String keyword) async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      final lowerKeyword = keyword.toLowerCase();

      final results = allData.data!.where((amalan) {
        final name = (amalan['name'] as String? ?? '').toLowerCase();
        final desc = (amalan['keterangan'] as String? ?? '').toLowerCase();

        return name.contains(lowerKeyword) || desc.contains(lowerKeyword);
      }).toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure('Ralat pencarian: $e');
    }
  }

  // ===== PRIVATE HELPERS =====

  /// Translate day name dari English ke Malay (jika perlu)
  static String _translateDay(String dayEnglish) {
    final dayMap = {
      'monday': 'isnin',
      'tuesday': 'selasa',
      'wednesday': 'rabu',
      'thursday': 'khamis',
      'friday': 'jumaat',
      'saturday': 'sabtu',
      'sunday': 'ahad',
    };

    return dayMap[dayEnglish.toLowerCase()] ?? dayEnglish;
  }

  // ===== UTILITY =====

  /// Check if data loaded
  static bool get isLoaded {
    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    return data.isNotEmpty;
  }

  /// Get total amalan count
  static int get amalanCount {
    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    return data.length;
  }

  /// Get amalan categories (unique list)
  static Future<Result<List<String>, String>> getCategories() async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      final categories = <String>{};
      for (var amalan in allData.data!) {
        final category = amalan['kategori'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return Result.success(categories.toList()..sort());
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  // ===== DEBUG =====

  /// Print all amalan (for debugging)
  static void debugPrintAllAmalan() {
    if (!kDebugMode) return;

    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    print('📿 Total amalan: ${data.length}');

    if (data.isNotEmpty) {
      print('First 5 amalan:');
      for (int i = 0; i < data.length && i < 5; i++) {
        final amalan = data[i];
        print('  ${i + 1}. ${amalan['name']} (${amalan['hari']})');
      }
    }
  }

  /// Get amalan statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return {'total': 0, 'daily': 0, 'weekly': 0, 'special': 0};
      }

      int daily = 0;
      int weekly = 0;
      int special = 0;

      for (var amalan in allData.data!) {
        final hari = (amalan['hari'] as String? ?? '').toLowerCase();

        if (hari.contains('setiap') || hari == 'harian') {
          daily++;
        } else if (_isWeekday(hari)) {
          weekly++;
        } else {
          special++;
        }
      }

      return {
        'total': allData.data!.length,
        'daily': daily,
        'weekly': weekly,
        'special': special,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static bool _isWeekday(String hari) {
    const weekdays = ['isnin', 'selasa', 'rabu', 'khamis', 'jumaat', 'sabtu', 'ahad',
                      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return weekdays.contains(hari.toLowerCase());
  }
}