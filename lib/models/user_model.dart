import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // Data Profil
  String name = 'Hamba Allah';
  String email = '';
  String gender = 'Lelaki';
  String avatarPath = ''; 
  DateTime? birthdate;
  String? hijriDOB; // ✅ Tambah balik variable ni (Sebab splash_screen panggil)

  // Data Progress
  int treeLevel = 1;
  int totalPoints = 0;

  // Data Tracking
  bool _zikirDoneToday = false;
  Map<String, bool> dailyFardhuLog = {};
  
  // Settings Alarms
  int adhanModeIndex = 1;
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== GETTERS =====
  bool get zikirDoneToday => _zikirDoneToday;
  int get nextLevelPoints => treeLevel * 100; // ✅ Tambah balik

  String get hijriAge {
    if (birthdate == null) return "0 Tahun";
    return HijriService.calculateHijriAge(birthdate!); 
  }

  // ===== METHODS =====
  void recordZikir() {
    _zikirDoneToday = true;
    totalPoints += 10;
    save();
    notifyListeners();
  }

  void setAdhanMode(int modeIndex) {
    adhanModeIndex = modeIndex;
    save();
    notifyListeners();
  }

  void setPrayerAlarm(String prayerName, bool isEnabled) {
    switch (prayerName) {
      case 'Subuh': isFajrAlarmEnabled = isEnabled; break;
      case 'Zohor': isDhuhrAlarmEnabled = isEnabled; break;
      case 'Asar': isAsrAlarmEnabled = isEnabled; break;
      case 'Maghrib': isMaghribAlarmEnabled = isEnabled; break;
      case 'Isyak': isIshaAlarmEnabled = isEnabled; break;
    }
    save();
    notifyListeners();
  }

  bool isFardhuDoneToday(String prayerName) => dailyFardhuLog[prayerName] ?? false;

  // ===== STORAGE =====
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'email': email,
      'gender': gender,
      'birthdate': birthdate?.toIso8601String(),
      'hijriDOB': hijriDOB,
      'totalPoints': totalPoints,
      'treeLevel': treeLevel,
      'zikirDoneToday': _zikirDoneToday,
      'adhanModeIndex': adhanModeIndex,
      'isFajrAlarmEnabled': isFajrAlarmEnabled,
      'isDhuhrAlarmEnabled': isDhuhrAlarmEnabled,
      'isAsrAlarmEnabled': isAsrAlarmEnabled,
      'isMaghribAlarmEnabled': isMaghribAlarmEnabled,
      'isIshaAlarmEnabled': isIshaAlarmEnabled,
    };
    await prefs.setString('user_data', json.encode(data));
  }

  static Future<UserModel> load() async {
    final model = UserModel();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw != null) {
      final data = json.decode(raw);
      model.name = data['name'] ?? 'Hamba Allah';
      model.email = data['email'] ?? '';
      model.gender = data['gender'] ?? 'Lelaki';
      model.hijriDOB = data['hijriDOB'];
      if (data['birthdate'] != null) model.birthdate = DateTime.parse(data['birthdate']);
      model.totalPoints = data['totalPoints'] ?? 0;
      model.treeLevel = data['treeLevel'] ?? 1;
      model._zikirDoneToday = data['zikirDoneToday'] ?? false;
      model.adhanModeIndex = data['adhanModeIndex'] ?? 1;
      model.isFajrAlarmEnabled = data['isFajrAlarmEnabled'] ?? true;
      model.isDhuhrAlarmEnabled = data['isDhuhrAlarmEnabled'] ?? true;
      model.isAsrAlarmEnabled = data['isAsrAlarmEnabled'] ?? true;
      model.isMaghribAlarmEnabled = data['isMaghribAlarmEnabled'] ?? true;
      model.isIshaAlarmEnabled = data['isIshaAlarmEnabled'] ?? true;
    }
    return model;
  }
}
