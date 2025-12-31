import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart'; // Pastikan package 'hijri' ada dalam pubspec.yaml

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
    required this.pengajaran
  });

  // Kilang untuk proses data dari JSON
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
  final String type; // 'harian', 'mingguan'
  bool isCompleted;

  AmalanToday({
    required this.id, 
    required this.title, 
    required this.source, 
    required this.type,
    this.isCompleted = false,
  });
}

// ================= PROVIDER UTAMA =================

class DailyContentProvider with ChangeNotifier {
  bool _isLoading = true;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  SirahToday? _todaySirah;
  SirahToday? get todaySirah => _todaySirah;

  List<AmalanToday> _todayAmalanList = [];
  List<AmalanToday> get todayAmalanList => _todayAmalanList;

  // Constructor: Terus panggil fungsi load bila class ini dicipta
  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ---------------------------------------------
      // 1. PROSES SIRAH (DARI JSON)
      // ---------------------------------------------
      
      // Baca fail JSON dari assets
      final String response = await rootBundle.loadString('assets/data/sirah_data.json');
      final Map<String, dynamic> data = json.decode(response);

      // Dapatkan tarikh Hijrah hari ini
      HijriCalendar _today = HijriCalendar.now();
      
      // Format kunci carian: "DD-MM" (Contoh: "01-01" untuk 1 Muharram)
      String searchKey = "${_today.hDay.toString().padLeft(2, '0')}-${_today.hMonth.toString().padLeft(2, '0')}";
      
      debugPrint("📅 [Francois] Mencari Sirah untuk Tarikh Hijrah: $searchKey");

      if (data.containsKey(searchKey)) {
        // A. JUMPA! Guna data hari ini
        _todaySirah = SirahToday.fromJson(data[searchKey]);
        debugPrint("✅ [Francois] Sirah Hari Ini Ditemui: ${_todaySirah!.tajuk}");
      } else {
        // B. TAK JUMPA -> AMBIL RANDOM (Supaya User Tak Nampak Kosong)
        List<String> allKeys = data.keys.toList();
        if (allKeys.isNotEmpty) {
          String randomKey = allKeys[Random().nextInt(allKeys.length)];
          _todaySirah = SirahToday.fromJson(data[randomKey]);
          debugPrint("🔀 [Francois] Tiada peristiwa hari ini. Papar Random: $randomKey");
        }
      }

      // ---------------------------------------------
      // 2. PROSES AMALAN (HARDCODED STABIL)
      // ---------------------------------------------
      // Nota: Kita tetapkan ini secara manual dulu untuk elak loading lama.
      // Nanti boleh upgrade ke JSON juga.
      
      _todayAmalanList = [
        AmalanToday(id: '1', title: 'Solat Dhuha (2 Rakaat)', source: 'Hadis Riwayat Muslim', type: 'harian'),
        AmalanToday(id: '2', title: 'Baca Al-Quran (1 Muka Surat)', source: 'Al-Quran', type: 'harian'),
        AmalanToday(id: '3', title: 'Istighfar 100 Kali', source: 'Sunnah Nabi SAW', type: 'harian'),
        AmalanToday(id: '4', title: 'Sedekah Subuh', source: 'Amalan Murah Rezeki', type: 'harian'),
      ];

      // Logik Tambahan: Jika Hari Jumaat, tambah Al-Kahfi
      if (DateTime.now().weekday == 5) { // 5 = Jumaat
        _todayAmalanList.insert(0, AmalanToday(
          id: 'jumaat_1',
          title: 'Membaca Surah Al-Kahfi',
          source: 'Sunnah Hari Jumaat',
          type: 'mingguan',
        ));
      }

    } catch (e) {
      _errorMessage = "Gagal memuatkan data: $e";
      debugPrint("❌ [Francois] Error Loading Data: $e");
      
      // FALLBACK TERAKHIR (JIKA JSON ROSAK/HILANG)
      _todaySirah = SirahToday(
        tajuk: "Sirah Sedang Dikemaskini",
        tahun: "-",
        lokasi: "-",
        pengajaran: "Sila pastikan fail sirah_data.json wujud di folder assets.",
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fungsi Toggle Checkbox (Tanda siap)
  void toggleAmalan(String id) {
    int index = _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted = !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }
}
