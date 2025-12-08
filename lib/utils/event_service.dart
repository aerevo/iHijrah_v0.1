// lib/utils/event_service.dart (UPGRADED 7.8/10)

import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'hijri_service.dart';
import 'result.dart';

/// Service untuk manage Islamic calendar events
///
/// Features:
/// - Load event data dari JSON
/// - Get event untuk hari ini (Hijri based)
/// - Get all events (untuk calendar view)
/// - Error handling dengan Result<T, E>
class EventService {
  static const String _path = AppAssets.eventData;

  // ===== INITIALIZATION =====

  /// Load event data dari JSON (call dalam main.dart)
  static Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (kDebugMode) {
        print('✅ Event data loaded');
      }

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load Event data: $e');
      }
      return Result.failure('Gagal memuatkan data peristiwa: $e');
    }
  }

  // ===== DATA RETRIEVAL =====

  /// Get event untuk hari ini sahaja
  ///
  /// Returns:
  /// - Event entry jika wujud
  /// - null jika tiada event hari ini
  static Future<Result<Map<String, dynamic>?, String>> getEventForToday() async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (data.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Event data is empty');
        }
        return Result.success(null);
      }

      // Dapatkan kunci tarikh hari ini (format: "1 muharram")
      final todayKey = HijriService.todayHijriTextKey();

      // Cari event yang match dengan hari ini
      for (var event in data) {
        final eventDate = (event['tarikh_hijrah'] as String? ?? '').toLowerCase();

        if (eventDate == todayKey) {
          if (kDebugMode) {
            print('📅 Event found: ${event['tajuk']}');
          }
          return Result.success(event);
        }
      }

      // Tiada event hari ini
      if (kDebugMode) {
        print('📅 No event today ($todayKey)');
      }

      return Result.success(null);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting event: $e');
      }
      return Result.failure('Ralat mendapatkan peristiwa: $e');
    }
  }

  /// Get semua events (untuk calendar screen)
  static Future<Result<List<Map<String, dynamic>>, String>> getAll() async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);

      if (data.isEmpty) {
        return Result.success([]);
      }

      if (kDebugMode) {
        print('📅 Loaded ${data.length} events');
      }

      return Result.success(data);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading all events: $e');
      }
      return Result.failure('Gagal memuatkan senarai peristiwa: $e');
    }
  }

  /// Get events untuk bulan tertentu (untuk optimized calendar)
  static Future<Result<List<Map<String, dynamic>>, String>> getEventsForMonth(int month) async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      // Filter events untuk bulan ini
      final monthEvents = allData.data!.where((event) {
        final dateStr = event['tarikh_hijrah'] as String? ?? '';
        // Format: "1 muharram", "10 ramadan", etc
        final parts = dateStr.toLowerCase().split(' ');

        if (parts.length >= 2) {
          final monthName = parts[1];
          return _isMonthMatch(monthName, month);
        }

        return false;
      }).toList();

      return Result.success(monthEvents);
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  /// Search events by keyword
  static Future<Result<List<Map<String, dynamic>>, String>> searchEvents(String keyword) async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      final lowerKeyword = keyword.toLowerCase();

      final results = allData.data!.where((event) {
        final tajuk = (event['tajuk'] as String? ?? '').toLowerCase();
        final keterangan = (event['keterangan'] as String? ?? '').toLowerCase();

        return tajuk.contains(lowerKeyword) || keterangan.contains(lowerKeyword);
      }).toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure('Ralat pencarian: $e');
    }
  }

  // ===== PRIVATE HELPERS =====

  /// Check if month name matches month number
  static bool _isMonthMatch(String monthName, int monthNumber) {
    final monthMap = {
      1: 'muharram',
      2: 'safar',
      3: 'rabiul awal',
      4: 'rabiul akhir',
      5: 'jamadil awal',
      6: 'jamadil akhir',
      7: 'rejab',
      8: 'syaaban',
      9: 'ramadan',
      10: 'syawal',
      11: 'zulkaedah',
      12: 'zulhijjah',
    };

    return monthMap[monthNumber] == monthName.toLowerCase();
  }

  // ===== UTILITY =====

  /// Check if data loaded
  static bool get isLoaded {
    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    return data.isNotEmpty;
  }

  /// Get total events count
  static int get eventsCount {
    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    return data.length;
  }

  // ===== DEBUG =====

  /// Print all events (for debugging)
  static void debugPrintAllEvents() {
    if (!kDebugMode) return;

    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    print('📅 Total events: ${data.length}');

    if (data.isNotEmpty) {
      print('First 5 events:');
      for (int i = 0; i < data.length && i < 5; i++) {
        final event = data[i];
        print('  ${i + 1}. ${event['tarikh_hijrah']}: ${event['tajuk']}');
      }
    }
  }

  /// Get events by importance (if your JSON has priority field)
  static Future<Result<List<Map<String, dynamic>>, String>> getImportantEvents() async {
    try {
      final allData = await getAll();

      if (allData.isFailure || allData.data == null) {
        return Result.success([]);
      }

      // Filter events yang ada field 'penting' atau 'priority'
      final important = allData.data!.where((event) {
        return event['penting'] == true || event['priority'] == 'high';
      }).toList();

      return Result.success(important);
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }
}