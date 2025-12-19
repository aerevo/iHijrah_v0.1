// lib/models/user_model.dart (FULL FIX: recordSelawat & nextLevelPoints ADDED)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== 1. BASIC INFO =====
  String name = 'Pengguna iHijrah';
  DateTime? birthdate;
  String? hijriDOB;
  String? avatarPath;
  String? gender;

  // ===== 2. LEVEL & POINTS SYSTEM =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== 3. DAILY TRACKING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};
  int selawatCountToday = 0;
  DateTime? lastResetDate;
  
  // State Zikir Harian
  bool _zikirDoneToday = false; 
  String _lastZikirDate = '';

  // ===== 4. SETTINGS (PRAYER & ALARM) =====
  int adhanModeIndex = 1; 
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // Getter Zikir
  bool get zikirDoneToday => _zikirDoneToday;

  // ✅ GETTER BARU (WAJIB ADA UNTUK HIJRAH TREE)
  // Logic: Level 1 target 100, Level 2 target 200, dst.
  int get nextLevelPoints => treeLevel * 100;

  // Constructor
  UserModel({
    this.name = 'Pengguna iHijrah',
    this.birthdate,
    this.hijriDOB,
    this.avatarPath,
    this.gender,
  });

  // =========================================================
  // FUNGSI LOAD
  // =========================================================
  static Future<UserModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel();

    // A. Load Basic Info
    user.name = prefs.getString('user_name') ?? 'Pengguna iHijrah';
    user.hijriDOB = prefs.getString('user_hijri_dob');
    user.avatarPath = prefs.getString('user_avatar_path');
    user.gender = prefs.getString('user_gender');
    
    String? dobIso = prefs.getString('user_birthdate');
    if (dobIso != null) {
      user.birthdate = DateTime.tryParse(dobIso);
    }

    // B. Load Points & Level
    user.treeLevel = prefs.getInt('user_tree_level') ?? 1;
    user.totalPoints = prefs.getInt('user_total_points') ?? 0;

    // C. Load Daily Logs
    String? fardhuJson = prefs.getString('daily_fardhu_log');
    if (fardhuJson != null) {
      user.dailyFardhuLog = Map<String, bool>.from(json.decode(fardhuJson));
    }
    
    String? amalanJson = prefs.getString('daily_amalan_log');
    if (amalanJson != null) {
      user.dailyAmalanLog = Map<String, bool>.from(json.decode(amalanJson));
    }

    user.selawatCountToday = prefs.getInt('selawat_count_today') ?? 0;

    // D. Load Settings
    user.adhanModeIndex = prefs.getInt('adhan_mode_index') ?? 1;
    user.isFajrAlarmEnabled = prefs.getBool('alarm_fajr') ?? true;
    user.isDhuhrAlarmEnabled = prefs.getBool('alarm_dhuhr') ?? true;
    user.isAsrAlarmEnabled = prefs.getBool('alarm_asr') ?? true;
    user.isMaghribAlarmEnabled = prefs.getBool('alarm_maghrib') ?? true;
    user.isIshaAlarmEnabled = prefs.getBool('alarm_isha') ?? true;

    // E. Logic Reset Harian & Zikir
    String? lastResetIso = prefs.getString('last_reset_date');
    if (lastResetIso != null) {
      user.lastResetDate = DateTime.tryParse(lastResetIso);
    }
    
    // Check Zikir Status
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastZikirStr = prefs.getString('user_last_zikir_date') ?? '';
    
    if (lastZikirStr == todayStr) {
      user._zikirDoneToday = prefs.getBool('user_zikir_done_today') ?? false;
    } else {
      user._zikirDoneToday = false;
    }
    user._lastZikirDate = lastZikirStr;

    // Reset harian jika perlu
    user._checkAndResetDailyData();

    return user;
  }

  // =========================================================
  // FUNGSI SAVE
  // =========================================================
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', name);
    if (hijriDOB != null) await prefs.setString('user_hijri_dob', hijriDOB!);
    if (avatarPath != null) await prefs.setString('user_avatar_path', avatarPath!);
    if (gender != null) await prefs.setString('user_gender', gender!);
    if (birthdate != null) await prefs.setString('user_birthdate', birthdate!.toIso8601String());

    await prefs.setInt('user_tree_level', treeLevel);
    await prefs.setInt('user_total_points', totalPoints);

    await prefs.setString('daily_fardhu_log', json.encode(dailyFardhuLog));
    await prefs.setString('daily_amalan_log', json.encode(dailyAmalanLog));
    await prefs.setInt('selawat_count_today', selawatCountToday);

    await prefs.setInt('adhan_mode_index', adhanModeIndex);
    await prefs.setBool('alarm_fajr', isFajrAlarmEnabled);
    await prefs.setBool('alarm_dhuhr', isDhuhrAlarmEnabled);
    await prefs.setBool('alarm_asr', isAsrAlarmEnabled);
    await prefs.setBool('alarm_maghrib', isMaghribAlarmEnabled);
    await prefs.setBool('alarm_isha', isIshaAlarmEnabled);

    if (lastResetDate != null) {
      await prefs.setString('last_reset_date', lastResetDate!.toIso8601String());
    }
  }

  // =========================================================
  // UPDATE PROFILE (ONBOARDING)
  // =========================================================
  Future<void> updateProfile({String? name, String? hijriDOB, String? avatarPath}) async {
    if (name != null) this.name = name;
    if (hijriDOB != null) this.hijriDOB = hijriDOB;
    if (avatarPath != null) this.avatarPath = avatarPath;
    
    await save();
    notifyListeners();
  }

  // =========================================================
  // RECORD ZIKIR (HOME PROMPT)
  // =========================================================
  Future<void> recordZikir() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    _zikirDoneToday = true;
    _lastZikirDate = today;

    addPoints(10); 

    await prefs.setString('user_last_zikir_date', today);
    await prefs.setBool('user_zikir_done_today', true);
    
    notifyListeners();
  }

  // =========================================================
  // ✅ RECORD SELAWAT (WAJIB ADA UNTUK POKOK)
  // =========================================================
  void recordSelawat() {
    selawatCountToday++;
    addPoints(5); // Dapat 5 point setiap kali selawat
    save();
    notifyListeners();
  }

  // =========================================================
  // POINTS & LOGIC LAIN
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
      // Boleh tambah sound play di sini nanti
    }
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
    // Reset jika tarikh last reset berbeza dengan hari ini
    if (lastResetDate == null || !_isSameDay(now, lastResetDate!)) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      
      lastResetDate = now;
      save();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
