import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';

// ================= MODEL DATA =================

class SirahToday {
  final String tajuk;
  final String tahun;
  final String lokasi;
  final String pengajaran;

  SirahToday({
    required this.tajuk,
    required this.tahun,
    required this.lokasi,
    required this.pengajaran,
  });

  factory SirahToday.fromJson(Map<String, dynamic> json) {
    return SirahToday(
      tajuk: json['peristiwa'] ?? "Tiada Tajuk",
      tahun: "${json['tahun_hijrah']}H (${json['tahun_masihi']}M)",
      lokasi: json['lokasi'] ?? "Mekah/Madinah",
      pengajaran: json['pengajaran'] ?? "Tiada pengajaran direkodkan.",
    );
  }
}

class AmalanToday {
  final String id;
  final String title;
  final String source;
  final String type; // harian / mingguan
  bool isCompleted;

  AmalanToday({
    required this.id,
    required this.title,
    required this.source,
    required this.type,
    this.isCompleted = false,
  });
}

// ================= PROVIDER =================

class DailyContentProvider with ChangeNotifier {
  bool _isLoading = true;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  SirahToday? _todaySirah;
  SirahToday? get todaySirah => _todaySirah;

  List<AmalanToday> _todayAmalanList = [];
  List<AmalanToday> get todayAmalanList => _todayAmalanList;

  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ===================================================
      // 🔍 DEBUG AWAL – SAH FAIL & JSON
      // ===================================================
      debugPrint("🔍 [DEBUG] Cuba baca fail sirah_data.json...");
      final String response =
          await rootBundle.loadString('assets/data/sirah_data.json');
      debugPrint("✅ [DEBUG] Fail dibaca. Panjang: ${response.length}");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("✅ [DEBUG] JSON berjaya decode. Jumlah entri: ${data.length}");

      // ===================================================
      // 📅 TARIKH HIJRAH HARI INI
      // ===================================================
      HijriCalendar today = HijriCalendar.now();
      String searchKey =
          "${today.hDay.toString().padLeft(2, '0')}-${today.hMonth.toString().padLeft(2, '0')}";

      debugPrint("📅 [DEBUG] Tarikh Hijrah Hari Ini: $searchKey");

      if (data.containsKey(searchKey)) {
        _todaySirah = SirahToday.fromJson(data[searchKey]);
        debugPrint("✅ [DEBUG] Sirah hari ini ditemui: ${_todaySirah!.tajuk}");
      } else {
        List<String> allKeys = data.keys.toList();
        if (allKeys.isNotEmpty) {
          String randomKey =
              allKeys[Random().nextInt(allKeys.length)];
          _todaySirah = SirahToday.fromJson(data[randomKey]);
          debugPrint("🔀 [DEBUG] Tiada sirah hari ini. Ambil random: $randomKey");
        }
      }

      // ===================================================
      // 🌱 AMALAN HARIAN
      // ===================================================
      _todayAmalanList = [
        AmalanToday(
            id: '1',
            title: 'Solat Dhuha (2 Rakaat)',
            source: 'Hadis Riwayat Muslim',
            type: 'harian'),
        AmalanToday(
            id: '2',
            title: 'Baca Al-Quran (1 Muka Surat)',
            source: 'Al-Quran',
            type: 'harian'),
        AmalanToday(
            id: '3',
            title: 'Istighfar 100 Kali',
            source: 'Sunnah Nabi SAW',
            type: 'harian'),
        AmalanToday(
            id: '4',
            title: 'Sedekah Subuh',
            source: 'Amalan Murah Rezeki',
            type: 'harian'),
      ];

      // Tambahan khas hari Jumaat
      if (DateTime.now().weekday == 5) {
        _todayAmalanList.insert(
          0,
          AmalanToday(
            id: 'jumaat_1',
            title: 'Membaca Surah Al-Kahfi',
            source: 'Sunnah Hari Jumaat',
            type: 'mingguan',
          ),
        );
        debugPrint("🕌 [DEBUG] Hari Jumaat – Al-Kahfi ditambah");
      }
    } catch (e) {
      _errorMessage = "Gagal memuatkan data: $e";
      debugPrint("❌ [DEBUG] ERROR SEBENAR: $e");

      _todaySirah = SirahToday(
        tajuk: "Sirah Sedang Dikemaskini",
        tahun: "-",
        lokasi: "-",
        pengajaran:
            "Sila pastikan fail sirah_data.json wujud dan disenaraikan dalam pubspec.yaml.",
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAmalan(String id) {
    int index =
        _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted =
          !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }
}
