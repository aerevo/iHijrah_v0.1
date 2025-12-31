// lib/providers/daily_content_provider.dart
// (VERSI SYNC DUA HALA: SIRAH & AMALAN)

import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

// Model Sirah
class SirahToday {
  final String tajuk;
  final String tahun;
  final String lokasi;
  final String pengajaran;

  SirahToday({required this.tajuk, required this.tahun, required this.lokasi, required this.pengajaran});

  factory SirahToday.fromJson(Map<String, dynamic> json) {
    return SirahToday(
      tajuk: json['peristiwa'] ?? "Tiada Tajuk",
      tahun: "${json['tahun_hijrah']}H (${json['tahun_masihi']}M)",
      lokasi: json['lokasi'] ?? "Lokasi Tidak Dinyatakan",
      pengajaran: json['pengajaran'] ?? "Tiada pengajaran direkodkan.",
    );
  }
}

// Model Amalan (Kini dibaca dari JSON)
class AmalanToday {
  final String id;
  final String title;
  final String source;
  final String type; // 'harian', 'mingguan', 'khas'
  bool isCompleted;

  AmalanToday({
    required this.id, 
    required this.title, 
    required this.source, 
    required this.type,
    this.isCompleted = false,
  });
}

class DailyContentProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SirahToday? _todaySirah;
  SirahToday? get todaySirah => _todaySirah;

  List<AmalanToday> _todayAmalanList = [];
  List<AmalanToday> get todayAmalanList => _todayAmalanList;

  // Debug Message untuk On-Screen Logging
  String debugMessage = "";

  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    _isLoading = true;
    debugMessage = ""; // Reset error
    notifyListeners();

    try {
      // ==========================================
      // BAHAGIAN 1: SYNC SIRAH (Sedia Ada)
      // ==========================================
      final String sirahResponse = await rootBundle.loadString('assets/data/sirah_data.json');
      final Map<String, dynamic> sirahData = json.decode(sirahResponse);

      HijriCalendar _today = HijriCalendar.now();
      String sirahKey = "${_today.hDay.toString().padLeft(2, '0')}-${_today.hMonth.toString().padLeft(2, '0')}";

      if (sirahData.containsKey(sirahKey)) {
        _todaySirah = SirahToday.fromJson(sirahData[sirahKey]);
      } else {
        List<String> allKeys = sirahData.keys.toList();
        if (allKeys.isNotEmpty) {
          String randomKey = allKeys[Random().nextInt(allKeys.length)];
          _todaySirah = SirahToday.fromJson(sirahData[randomKey]);
        }
      }

      // ==========================================
      // BAHAGIAN 2: SYNC AMALAN (Baru!)
      // ==========================================
      final String amalanResponse = await rootBundle.loadString('assets/data/amalan_sunnah.json');
      final List<dynamic> amalanData = json.decode(amalanResponse);

      _todayAmalanList = []; // Kosongkan senarai lama

      // A. Dapatkan Info Hari Ini
      DateTime now = DateTime.now();
      String dayNameMy = _getDayName(now.weekday); // Isnin, Selasa...
      
      // B. Dapatkan Info Hijrah (Cth: "10 Muharram")
      // Nota: JSON Kapten guna ejaan Melayu, kita kena match kan.
      List<String> bulanHijrahMy = [
        "Muharram", "Safar", "Rabiulawal", "Rabiulakhir",
        "Jamadilawal", "Jamadilakhir", "Rejab", "Syaaban",
        "Ramadan", "Syawal", "Zulkaedah", "Zulhijjah"
      ];
      String hijriDateStr = "${_today.hDay} ${bulanHijrahMy[_today.hMonth - 1]}";

      // C. Lakukan Penapisan (Filtering)
      for (var item in amalanData) {
        String hariIsam = item['hari'].toString(); // Ambil field 'hari' dari JSON
        bool include = false;
        String type = 'harian';

        // Logik Penapis:
        if (hariIsam == "Setiap hari") {
          include = true;
          type = 'harian';
        } else if (hariIsam == hijriDateStr) {
          // Contoh: "10 Muharram" == "10 Muharram"
          include = true;
          type = 'khas'; // Amalan Khas (Paling Penting)
        } else if (hariIsam.toLowerCase() == "malam" && (now.hour >= 19 || now.hour < 6)) {
          // Tunjuk amalan malam jika waktu malam
          include = true; 
          type = 'harian';
        } else if (hariIsam.toLowerCase() == dayNameMy.toLowerCase()) {
          // Isnin / Khamis / Jumaat
          include = true;
          type = 'mingguan';
        } 

        if (include) {
          // Jika lulus tapisan, masukkan dalam list
          _todayAmalanList.add(AmalanToday(
            id: item['id'],
            title: item['amalan'],
            source: item['sumber'] ?? "",
            type: type,
          ));
        }
      }
      
      // Susun: Amalan Khas naik atas sekali
      _todayAmalanList.sort((a, b) {
        if (a.type == 'khas' && b.type != 'khas') return -1;
        if (a.type != 'khas' && b.type == 'khas') return 1;
        return 0;
      });

    } catch (e) {
      // ON-SCREEN LOGGING: Papar error di UI jika ada
      debugMessage = "Ralat Data: $e";
      
      // Fallback supaya UI tak kosong
      _todayAmalanList = [
        AmalanToday(id: 'err_1', title: 'Istighfar (Data Error)', source: 'Sunnah', type: 'harian'),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Toggle Checkbox Amalan
  void toggleAmalan(String id) {
    int index = _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted = !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }

  // Helper: Tukar nombor hari ke Bahasa Melayu
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Isnin";
      case 2: return "Selasa";
      case 3: return "Rabu";
      case 4: return "Khamis";
      case 5: return "Jumaat";
      case 6: return "Sabtu";
      case 7: return "Ahad";
      default: return "";
    }
  }
}
