import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';

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
      lokasi: json['lokasi'] ?? "Lokasi Tiada",
      pengajaran: json['pengajaran'] ?? "Tiada pengajaran.",
    );
  }
}

class AmalanToday {
  final String id;
  final String title;
  final String source;
  final String type;
  bool isCompleted;
  AmalanToday({required this.id, required this.title, required this.source, required this.type, this.isCompleted = false});
}

class DailyContentProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

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
      // 1. CUBA BACA FAIL
      final String response = await rootBundle.loadString('assets/data/sirah_data.json');
      final Map<String, dynamic> data = json.decode(response);

      // 2. LOGIK TARIKH
      HijriCalendar _today = HijriCalendar.now();
      String searchKey = "${_today.hDay.toString().padLeft(2, '0')}-${_today.hMonth.toString().padLeft(2, '0')}";

      if (data.containsKey(searchKey)) {
        _todaySirah = SirahToday.fromJson(data[searchKey]);
      } else {
        // FALLBACK RANDOM JIKA TARIKH TIADA
        List<String> allKeys = data.keys.toList();
        String randomKey = allKeys[Random().nextInt(allKeys.length)];
        _todaySirah = SirahToday.fromJson(data[randomKey]);
      }

    } catch (e) {
      // ✅ [KAPTEN PERHATIKAN INI] Francois tunjuk error terus kat skrin fon Kapten
      String errorMesage = e.toString();
      
      _todaySirah = SirahToday(
        tajuk: "PUNCA RALAT DIKESAN",
        tahun: "X",
        lokasi: "X",
        pengajaran: "Francois dapati: $errorMesage",
      );
    }

    _todayAmalanList = [
      AmalanToday(id: '1', title: 'Solat Dhuha (2 Rakaat)', source: 'Sunnah', type: 'harian'),
      AmalanToday(id: '2', title: 'Istighfar 100x', source: 'Sunnah', type: 'harian'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void toggleAmalan(String id) {
    int index = _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted = !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }
}
