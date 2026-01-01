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

// Model Amalan 
class AmalanToday {
  final String id;
  final String title;
  final String source;
  final String type; // 'khas' (Date specific), 'mingguan' (Day specific)
  final String reward; // Fadhilat/Ganjaran
  bool isCompleted;

  AmalanToday({
    required this.id, 
    required this.title, 
    required this.source, 
    required this.type,
    this.reward = "",
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

  // Notification Message (Pop Up Ringkas untuk Rutin)
  String? popupMessage; 

  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    _isLoading = true;
    popupMessage = null;
    notifyListeners();

    try {
      // 1. SYNC SIRAH (Kekal Sama)
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

      // 2. SYNC AMALAN (Logik Baru: Anti-Serabut)
      final String amalanResponse = await rootBundle.loadString('assets/data/amalan_sunnah.json');
      final List<dynamic> amalanData = json.decode(amalanResponse);

      _todayAmalanList = []; 

      // Data Tarikh & Hari
      DateTime now = DateTime.now();
      String dayNameMy = _getDayName(now.weekday); // Isnin, Selasa...
      
      // Data Hijrah (Mapping Nama Bulan)
      List<String> bulanHijrahMy = [
        "Muharram", "Safar", "Rabiulawal", "Rabiulakhir",
        "Jamadilawal", "Jamadilakhir", "Rejab", "Syaaban",
        "Ramadan", "Syawal", "Zulkaedah", "Zulhijjah"
      ];
      String hijriDateStr = "${_today.hDay} ${bulanHijrahMy[_today.hMonth - 1]}"; // Cth: 10 Muharram

      // === PENAPIS "SNIPER" FRANCOIS ===
      for (var item in amalanData) {
        String hariIsam = item['hari'].toString(); 
        bool include = false;
        String type = 'mingguan';

        // A. Cek Tarikh Spesifik (PRIORITI TERTINGGI)
        // Cth: "10 Muharram" atau "27 Rejab"
        if (hariIsam == hijriDateStr) {
          include = true;
          type = 'khas';
        } 
        
        // B. Cek Hari Mingguan (Isnin/Khamis/Jumaat SAHAJA)
        // Kita abaikan hari biasa yang tiada puasa sunat/amalan khas
        else if (hariIsam.toLowerCase() == dayNameMy.toLowerCase()) {
           // Hanya ambil jika Isnin/Khamis (Puasa) atau Jumaat (Kahfi/Mandi)
           if (['Isnin', 'Khamis', 'Jumaat'].contains(dayNameMy)) {
             include = true;
             type = 'mingguan';
           }
        }

        // C. SOROKKAN RUTIN ("Setiap hari" / "Malam")
        // Kita tak masukkan dalam list, TAPI kita boleh simpan sebagai 'popupMessage'
        // jika Kapten nak "sekadar lalu"
        else if (hariIsam == "Setiap hari" && popupMessage == null) {
           // Contoh: Set popup rawak untuk peringatan dhuha
           if (now.hour > 7 && now.hour < 12) {
             popupMessage = "Peringatan Dhuha: 2 rakaat yang mencukupkan rezeki.";
           }
        }

        if (include) {
          _todayAmalanList.add(AmalanToday(
            id: item['id'],
            title: item['amalan'],
            source: item['sumber'] ?? "",
            type: type,
            reward: item['huraian'] ?? "", // Papar huraian sebagai ganjaran/motivasi
          ));
        }
      }
      
      // Susun: Yang 'khas' (Rare) duduk atas sekali
      _todayAmalanList.sort((a, b) {
        if (a.type == 'khas' && b.type != 'khas') return -1;
        if (a.type != 'khas' && b.type == 'khas') return 1;
        return 0;
      });

      // Jika tiada amalan khas hari ni (List kosong), 
      // Tunjukkan mesej "Rehat" atau satu amalan rawak ringan supaya tak nampak bug
      if (_todayAmalanList.isEmpty) {
         _todayAmalanList.add(AmalanToday(
           id: 'rest_day',
           title: 'Tiada Amalan Khusus Hari Ini',
           source: 'Rehat & Fokus Ibadah Wajib',
           type: 'mingguan',
           reward: 'Fokus pada kualiti solat fardu anda hari ini.',
         ));
      }

    } catch (e) {
      debugPrint("❌ Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAmalan(String id) {
    // Logik tick/untick
    int index = _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted = !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }

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
