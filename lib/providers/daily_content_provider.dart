// lib/providers/daily_content_provider.dart (BYPASS: GERENTI MUNCUL)

import 'package:flutter/material.dart';

// Model Mudah
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
  final String type; 
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

  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    // KITA PAKSA DATA MASUK (TAK PERLU BACA JSON)
    
    // 1. Data Sirah
    _todaySirah = SirahToday(
      tajuk: "Permulaan Wahyu Di Gua Hira'",
      tahun: "610 Masihi",
      lokasi: "Gua Hira', Mekah",
      pengajaran: "Pentingnya mengasingkan diri (Uzlah) untuk mencari ketenangan dan petunjuk Ilahi sebelum memikul tanggungjawab besar.",
    );

    // 2. Data Amalan
    _todayAmalanList = [
      AmalanToday(id: '1', title: 'Solat Dhuha (2 Rakaat)', source: 'Hadis Riwayat Muslim', type: 'harian'),
      AmalanToday(id: '2', title: 'Membaca Al-Quran (1 Muka)', source: '', type: 'harian'),
      AmalanToday(id: '3', title: 'Istighfar 100 Kali', source: 'Sunnah Nabi SAW', type: 'harian'),
      AmalanToday(id: '4', title: 'Sedekah Subuh', source: '', type: 'harian'),
    ];

    // Simulasi loading sekejap je (0.1 saat)
    await Future.delayed(const Duration(milliseconds: 100));
    
    _isLoading = false;
    notifyListeners();
  }

  // Toggle Checkbox
  void toggleAmalan(String id) {
    int index = _todayAmalanList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted = !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }
}
