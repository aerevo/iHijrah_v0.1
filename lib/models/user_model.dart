// lib/models/user_model.dart (FULL FIXED & MERGED)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== 1. BASIC & CORPORATE INFO =====
  String name = 'Pengguna iHijrah';
  String email = ''; 
  String gender = 'Lelaki'; 
  String avatarPath = 'assets/images/avatar_m1.png'; 
  String authMethod = 'Guest';
  DateTime? birthdate;
  String? hijriDOB;

  // ===== 2. LEVEL & POINTS SYSTEM =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== 3. DAILY TRACKING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};
  int selawatCountToday = 0;
  DateTime? lastResetDate;
  
  bool _zikirDoneToday = false; 
  String _lastZikirDate = '';

  // ===== 4. SETTINGS (PRAYER & ALARM) =====
  int adhanModeIndex = 1; 
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== GETTERS =====
  bool get zikirDoneToday => _zikirDoneToday;
  int get nextLevelPoints => treeLevel * 100;

  // =========================================================
  // SAVING & LOADING (SHARED PREFERENCES)
  // =========================================================

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'email': email,
      'gender': gender,
      'avatarPath': avatarPath,
      'authMethod': authMethod,
      'birthdate': birthdate?.toIso8601String(),
      'treeLevel': treeLevel,
      'totalPoints': totalPoints,
      'selawatCountToday': selawatCountToday,
      'lastResetDate': lastResetDate?.toIso8601String(),
      'zikirDoneToday': _zikirDoneToday,
      'lastZikirDate': _lastZikirDate,
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
      model.name = data['name'] ?? 'Pengguna iHijrah';
      model.email = data['email'] ?? '';
      model.gender = data['gender'] ?? 'Lelaki';
      model.avatarPath = data['avatarPath'] ?? 'assets/images/avatar_m1.png';
      model.authMethod = data['authMethod'] ?? 'Guest';
      if (data['birthdate'] != null) model.birthdate = DateTime.parse(data['birthdate']);
      model.treeLevel = data['treeLevel'] ?? 1;
      model.totalPoints = data['totalPoints'] ?? 0;
      model.selawatCountToday = data['selawatCountToday'] ?? 0;
      if (data['lastResetDate'] != null) model.lastResetDate = DateTime.parse(data['lastResetDate']);
      model._zikirDoneToday = data['zikirDoneToday'] ?? false;
      model._lastZikirDate = data['lastZikirDate'] ?? '';
      model.adhanModeIndex = data['adhanModeIndex'] ?? 1;
      model.isFajrAlarmEnabled = data['isFajrAlarmEnabled'] ?? true;
      model.isDhuhrAlarmEnabled = data['isDhuhrAlarmEnabled'] ?? true;
      model.isAsrAlarmEnabled = data['isAsrAlarmEnabled'] ?? true;
      model.isMaghribAlarmEnabled = data['isMaghribAlarmEnabled'] ?? true;
      model.isIshaAlarmEnabled = data['isIshaAlarmEnabled'] ?? true;
    }
    
    model._checkAndResetDailyData();
    return model;
  }

  // =========================================================
  // LOGIC & AMALAN METHODS
  // =========================================================

  void addPoints(int points) {
    totalPoints += points;
    _checkLevelUp();
    save();
    notifyListeners();
  }

  void _checkLevelUp() {
    int calculatedLevel = (totalPoints / 100).floor() + 1;
    if (calculatedLevel > 5) calculatedLevel = 5;
    if (calculatedLevel > treeLevel) {
      treeLevel = calculatedLevel;
    }
  }

  void recordSelawat() {
    selawatCountToday++;
    addPoints(1); // 1 Selawat = 1 XP
  }

  void recordZikir() {
    _zikirDoneToday = true;
    _lastZikirDate = DateTime.now().toIso8601String();
    addPoints(10); // Hadiah zikir
    save();
    notifyListeners();
  }

  bool isFardhuDoneToday(String prayerName) => dailyFardhuLog[prayerName] ?? false;

  void recordFardhu(String prayerName) {
    dailyFardhuLog[prayerName] = true;
    addPoints(20); // Solat fardu XP tinggi
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

  void _checkAndResetDailyData() {
    final now = DateTime.now();
    if (lastResetDate == null || !_isSameDay(now, lastResetDate!)) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      _zikirDoneToday = false;
      lastResetDate = now;
      save();
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
