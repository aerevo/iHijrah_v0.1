import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

// Model Mudah untuk Data
class SirahToday {
  final String tajuk;
  final String tahun;
  final String lokasi;
  final String pengajaran;

  SirahToday({required this.tajuk, required this.tahun, required this.lokasi, required this.pengajaran});
}

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

  // Data Sirah Hari Ini
  SirahToday? _todaySirah;
  SirahToday? get todaySirah => _todaySirah;

  // Senarai Amalan Hari Ini
  List<AmalanToday> _todayAmalanList = [];
  List<AmalanToday> get todayAmalanList => _todayAmalanList;

  // Cache Data Mentah
  Map<String, dynamic> _sirahData = {};
  List<dynamic> _amalanData = [];

  // Panggil ini di main.dart atau Home Screen
  Future<void> loadDailyContent() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load JSON Files
      final String sirahString = await rootBundle.loadString('assets/data/sirah_data.json');
      final String amalanString = await rootBundle.loadString('assets/data/amalan_sunnah.json');
      
      _sirahData = json.decode(sirahString);
      _amalanData = json.decode(amalanString);

      // 2. Kira Tarikh Semasa
      final now = DateTime.now();
      final HijriCalendar hijriNow = HijriCalendar.now();

      // 3. Proses Sirah (Format Key JSON: "MM-DD" contoh "01-01" untuk 1 Muharram)
      // Kita perlu padLeft supaya jadi "01" bukan "1"
      String monthKey = hijriNow.hMonth.toString().padLeft(2, '0');
      String dayKey = hijriNow.hDay.toString().padLeft(2, '0');
      String lookupKey = "$monthKey-$dayKey";

      if (_sirahData.containsKey(lookupKey)) {
        final data = _sirahData[lookupKey];
        _todaySirah = SirahToday(
          tajuk: data['peristiwa'] ?? "Tiada Peristiwa Khas",
          tahun: "Tahun ke-${data['tahun_hijrah']} H",
          lokasi: data['lokasi'] ?? "",
          pengajaran: data['pengajaran'] ?? "",
        );
      } else {
        // Fallback jika tiada sirah hari ini - Ambil satu secara rawak atau tunjuk default
        _todaySirah = SirahToday(
          tajuk: "Tiada peristiwa khusus dicatatkan pada tarikh ini dalam data.",
          tahun: "-",
          lokasi: "-",
          pengajaran: "Teruskan beramal soleh dan menghayati sirah Nabi SAW.",
        );
      }

      // 4. Proses Amalan (Logic Filter)
      _todayAmalanList = [];
      String dayName = DateFormat('EEEE', 'ms_MY').format(now); // Contoh: "Isnin" (Pastikan locale betul atau guna switch case)
      
      // Manual mapping sebab kadang locale tak setup
      int weekday = now.weekday; // 1 = Mon, 7 = Sun
      String dayNameMy = _getDayName(weekday); 

      for (var item in _amalanData) {
        String hariIsam = item['hari'] ?? "";
        bool include = false;
        String type = 'harian';

        // Logik Penapisan
        if (hariIsam.toLowerCase() == "setiap hari") {
          include = true;
          type = 'harian';
        } else if (hariIsam.toLowerCase() == "malam" && (now.hour >= 19 || now.hour < 6)) {
          // Tunjuk amalan malam
          include = true; 
          type = 'harian';
        } else if (hariIsam.toLowerCase() == dayNameMy.toLowerCase()) {
          // Isnin / Khamis / Jumaat
          include = true;
          type = 'mingguan';
        } 
        // TODO: Boleh tambah logik tarikh Hijrah spesifik (cth: 10 Zulhijjah) di sini nanti

        if (include) {
          _todayAmalanList.add(AmalanToday(
            id: item['id'],
            title: item['amalan'],
            source: item['sumber'] ?? "",
            type: type,
          ));
        }
      }

    } catch (e) {
      debugPrint("❌ Ralat Francois Load Data: $e");
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
      // Di sini boleh tambah kod untuk simpan ke SharedPreferences supaya tak hilang bila tutup app
    }
  }

  // Helper Hari Melayu
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
