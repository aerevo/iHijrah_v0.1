// lib/models/user_model.dart (FULL FIXED & MERGED)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== 1. DATA PROFIL & KORPORAT =====
  String name = 'Hamba Allah';
  String email = '';
  String gender = 'Lelaki';
  String avatarPath = ''; 
  DateTime? birthdate;
  String? hijriDOB; // Diperlukan oleh splash_screen logic

  // ===== 2. DATA PROGRESS (XP & LEVEL) =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== 3. DATA TRACKING =====
  bool _zikirDoneToday = false;
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};

  // ===== 4. TETAPAN (ALARM & AZAN) =====
  int adhanModeIndex = 1;
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== GETTERS =====
  bool get zikirDoneToday => _zikirDoneToday;
  int get nextLevelPoints => treeLevel * 100;

  String get hijriAge {
    if (birthdate == null) return "0 Tahun";
    // Fix: Tukar DateTime ke String ISO sebelum hantar ke HijriService
    return HijriService.calculateHijriAge(birthdate!.toIso8601String()); 
  }

  // ===== METHODS (LOGIK AMALAN) =====
  void recordZikir() {
    _zikirDoneToday = true;
    totalPoints += 10;
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

  bool isFardhuDoneToday(String prayerName) => dailyFardhuLog[prayerName] ?? false;

  void recordFardhu(String prayerName) {
    dailyFardhuLog[prayerName] = true;
    totalPoints += 20;
    _checkLevelUp();
    save();
    notifyListeners();
  }

  // ===== METHODS (TETAPAN) =====
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

  // ===== STORAGE (LOCAL SAVE/LOAD) =====
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'email': email,
      'gender': gender,
      'avatarPath': avatarPath,
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
      model.avatarPath = data['avatarPath'] ?? '';
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
