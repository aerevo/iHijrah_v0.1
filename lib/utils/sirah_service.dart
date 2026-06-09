// lib/utils/sirah_service.dart
import 'package:flutter/foundation.dart';
import 'base_data_service.dart';
import 'constants.dart';
import 'hijri_service.dart';
import 'result.dart';

class SirahService {
  static const String _path = AppAssets.sirahData;

  static Future<Result<void, String>> load() async {
    try {
      await BaseDataService.load<Map<String, dynamic>>(_path);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Gagal memuatkan data Sirah: $e');
    }
  }

  /// Sirah untuk hari ini (key format: "MM-DD")
  static Future<Result<Map<String, dynamic>, String>> getSirahForToday() async {
    try {
      var data = BaseDataService.get<Map<String, dynamic>>(_path);

      // Cuba reload kalau cache kosong
      if (data.isEmpty) {
        final r = await load();
        if (r.isFailure) return Result.success(_defaultSirah());
        data = BaseDataService.get<Map<String, dynamic>>(_path);
        if (data.isEmpty) return Result.success(_defaultSirah());
      }

      final key = HijriService.todayHijriKey();
      if (data.containsKey(key)) {
        final entry = data[key] as Map<String, dynamic>?;
        if (entry != null && entry.isNotEmpty) {
          return Result.success(entry);
        }
      }

      return Result.success(_defaultSirah());
    } catch (e) {
      return Result.success(_defaultSirah());
    }
  }

  /// Sirah untuk tarikh tertentu
  static Future<Result<Map<String, dynamic>, String>> getSirahForDate(String hijriKey) async {
    try {
      final data = BaseDataService.get<Map<String, dynamic>>(_path);
      if (data.isEmpty) return Result.failure('Data Sirah tidak dimuatkan');

      final entry = data[hijriKey] as Map<String, dynamic>?;
      return Result.success(entry ?? _defaultSirah());
    } catch (e) {
      return Result.failure('Ralat: $e');
    }
  }

  static Map<String, dynamic> getAllSirah() =>
      BaseDataService.get<Map<String, dynamic>>(_path);

  static bool get isLoaded =>
      BaseDataService.get<Map<String, dynamic>>(_path).isNotEmpty;

  static int get entriesCount =>
      BaseDataService.get<Map<String, dynamic>>(_path).length;

  // ── DEFAULT ────────────────────────────────────────────────────
  static Map<String, dynamic> _defaultSirah() {
    final h = HijriService.nowHijri();
    return {
      'peristiwa': 'Peringatan Harian',
      'tahun_hijrah': h.hYear,
      'tahun_masihi': DateTime.now().year,
      'lokasi': 'Setiap tempat',
      'pengajaran':
          'Jadikan hari ini lebih baik daripada semalam. '
          '${h.hDay} ${HijriService.bulanMelayu(h.hMonth)} ${h.hYear}H.',
    };
  }
}
