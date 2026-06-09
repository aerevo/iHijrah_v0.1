// lib/utils/event_service.dart
import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'hijri_service.dart';
import 'result.dart';

class EventService {
  static const String _path = AppAssets.eventData;

  static Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<List<Map<String, dynamic>>>(_path);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Gagal memuatkan data peristiwa: $e');
    }
  }

  /// Event untuk hari ini berdasarkan tarikh Hijri
  static Future<Result<Map<String, dynamic>?, String>> getEventForToday() async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);
      if (data.isEmpty) return Result.success(null);

      final todayKey = HijriService.todayHijriTextKey().toLowerCase();

      for (final event in data) {
        final date = (event['tarikh_hijrah'] as String? ?? '').toLowerCase();
        if (date == todayKey) return Result.success(event);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Ralat mendapatkan peristiwa: $e');
    }
  }

  /// Semua event
  static Future<Result<List<Map<String, dynamic>>, String>> getAll() async {
    try {
      final data = await BaseDataService.load<List<Map<String, dynamic>>>(_path);
      return Result.success(data);
    } catch (e) {
      return Result.failure('Gagal memuatkan senarai peristiwa: $e');
    }
  }

  /// Event untuk bulan tertentu (1-12 Hijri)
  static Future<Result<List<Map<String, dynamic>>, String>> getForMonth(int month) async {
    try {
      final all = await getAll();
      if (all.isFailure || all.data == null) return Result.success([]);

      final monthName = HijriService.bulanMelayu(month).toLowerCase();
      final filtered = all.data!.where((e) {
        final parts = (e['tarikh_hijrah'] as String? ?? '').toLowerCase().split(' ');
        return parts.length >= 2 && parts[1] == monthName;
      }).toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  /// Carian mengikut kata kunci
  static Future<Result<List<Map<String, dynamic>>, String>> search(String keyword) async {
    try {
      final all = await getAll();
      if (all.isFailure || all.data == null) return Result.success([]);

      final kw = keyword.toLowerCase();
      final results = all.data!.where((e) {
        final tajuk      = (e['tajuk']      as String? ?? '').toLowerCase();
        final keterangan = (e['keterangan'] as String? ?? '').toLowerCase();
        return tajuk.contains(kw) || keterangan.contains(kw);
      }).toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure('Ralat pencarian: $e');
    }
  }

  static bool get isLoaded {
    final data = BaseDataService.get<List<Map<String, dynamic>>>(_path);
    return data.isNotEmpty;
  }
}
