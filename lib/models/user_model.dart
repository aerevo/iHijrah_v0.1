// lib/models/user_model.dart (DATA CORE - FIXED & UPDATED)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== BASIC INFO =====
  String name = 'Pengguna iHijrah';
  DateTime? birthdate;
  String? hijriDOB;
  String? avatarPath;

  // ===== SETTINGS =====
  int adhanModeIndex = 1; // ✅ FIXED: Default 1 (Full) atau ikut enum

  // ===== PENGGERA SOLAT (TOGGLES) =====
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== LEVEL & GAMIFICATION =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== LOGGING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {}; // Ditambah untuk tracking amalan sunat
  DateTime? lastResetDate;

  // ===== GETTERS HELPER =====
  int get fardhuCompletedToday => dailyFardhuLog.length; // Simplified count logic
  int get nextLevelPoints => treeLevel * 1000; // Contoh logic level up
  double get progressPercentage => (totalPoints % 1000) / 1000.0;

  // ===== FUNGSI UTAMA: LOAD DATA =====
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Basic Info
      name = prefs.getString('name') ?? 'Pengguna iHijrah';
      final birthdateStr = prefs.getString('birthdate');
      if (birthdateStr != null) {
        birthdate = DateTime.parse(birthdateStr);
      }
      hijriDOB = prefs.getString('hijriDOB');
      avatarPath = prefs.getString('avatarPath');

      // Settings
      adhanModeIndex = prefs.getInt('adhanModeIndex') ?? 1;
      isFajrAlarmEnabled = prefs.getBool('isFajrAlarmEnabled') ?? true;
      isDhuhrAlarmEnabled = prefs.getBool('isDhuhrAlarmEnabled') ?? true;
      isAsrAlarmEnabled = prefs.getBool('isAsrAlarmEnabled') ?? true;
      isMaghribAlarmEnabled = prefs.getBool('isMaghribAlarmEnabled') ?? true;
      isIshaAlarmEnabled = prefs.getBool('isIshaAlarmEnabled') ?? true;

      // Gamification
      treeLevel = prefs.getInt('treeLevel') ?? 1;
      totalPoints = prefs.getInt('totalPoints') ?? 0;

      // Logs
      final fardhuStr = prefs.getString('dailyFardhuLog');
      if (fardhuStr != null) {
        dailyFardhuLog = Map<String, bool>.from(jsonDecode(fardhuStr));
      }

      final amalanStr = prefs.getString('dailyAmalanLog');
      if (amalanStr != null) {
        dailyAmalanLog = Map<String, bool>.from(jsonDecode(amalanStr));
      }

      final lastResetStr = prefs.getString('lastResetDate');
      if (lastResetStr != null) {
        lastResetDate = DateTime.parse(lastResetStr);
      }

      _checkDailyReset();
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error Loading User Data: $e");
    }
  }

  // ===== UPDATE PROFILE =====
  void updateProfile({required String newName, required DateTime newDate}) {
    name = newName;
    birthdate = newDate;
    final hijriDate = HijriService.fromDate(newDate);
    hijriDOB = '${hijriDate.hDay}/${hijriDate.hMonth}/${hijriDate.hYear}';
    save();
    notifyListeners();
  }

  void setBirthDate(DateTime date) {
    updateProfile(newName: name, newDate: date);
  }

  // ===== SETTINGS ACTIONS =====
  void setAdhanMode(int index) {
    adhanModeIndex = index;
    save();
    notifyListeners();
  }

  void setPrayerAlarm(String prayerName, bool isEnabled) {
    switch (prayerName.toLowerCase()) {
      case 'subuh': isFajrAlarmEnabled = isEnabled; break;
      case 'zohor': isDhuhrAlarmEnabled = isEnabled; break;
      case 'asar': isAsrAlarmEnabled = isEnabled; break;
      case 'maghrib': isMaghribAlarmEnabled = isEnabled; break;
      case 'isyak': isIshaAlarmEnabled = isEnabled; break;
    }
    save();
    notifyListeners();
  }

  // ===== GAMIFICATION ACTIONS =====
  void recordFardhu(String prayerName) {
    if (!dailyFardhuLog.containsKey(prayerName)) {
      dailyFardhuLog[prayerName] = true;
      addPoints(50); // Tambah 50 XP
      save();
      notifyListeners();
    }
  }

  bool isFardhuDoneToday(String prayerName) {
    return dailyFardhuLog.containsKey(prayerName);
  }

  void recordAmalan(String amalanId) {
    if (!dailyAmalanLog.containsKey(amalanId)) {
      dailyAmalanLog[amalanId] = true;
      addPoints(20); // Tambah 20 XP
      save();
      notifyListeners();
    }
  }

  bool isAmalanDoneToday(String amalanId) {
    return dailyAmalanLog.containsKey(amalanId);
  }

  void addPoints(int points) {
    totalPoints += points;
    // Simple level up logic
    if (totalPoints >= treeLevel * 1000) {
      treeLevel++;
    }
  }

  // ===== DATA PERSISTENCE (SAVE) =====
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    if (birthdate != null) {
      await prefs.setString('birthdate', birthdate!.toIso8601String());
    }
    if (hijriDOB != null) {
      await prefs.setString('hijriDOB', hijriDOB!);
    }
    if (avatarPath != null) {
      await prefs.setString('avatarPath', avatarPath!);
    }

    // Settings
    await prefs.setInt('adhanModeIndex', adhanModeIndex);
    await prefs.setBool('isFajrAlarmEnabled', isFajrAlarmEnabled);
    await prefs.setBool('isDhuhrAlarmEnabled', isDhuhrAlarmEnabled);
    await prefs.setBool('isAsrAlarmEnabled', isAsrAlarmEnabled);
    await prefs.setBool('isMaghribAlarmEnabled', isMaghribAlarmEnabled);
    await prefs.setBool('isIshaAlarmEnabled', isIshaAlarmEnabled);

    // Stats
    await prefs.setInt('treeLevel', treeLevel);
    await prefs.setInt('totalPoints', totalPoints);
    await prefs.setString('dailyFardhuLog', jsonEncode(dailyFardhuLog));
    await prefs.setString('dailyAmalanLog', jsonEncode(dailyAmalanLog));

    if (lastResetDate != null) {
      await prefs.setString('lastResetDate', lastResetDate!.toIso8601String());
    }

    notifyListeners();
  }

  // Internal Helper: Reset Harian
  void _checkDailyReset() {
    final today = DateTime.now();
    if (lastResetDate == null || !_isSameDay(lastResetDate!, today)) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      lastResetDate = today;
      save();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
