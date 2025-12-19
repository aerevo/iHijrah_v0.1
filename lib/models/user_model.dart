// lib/models/user_model.dart (FIXED: RESTORED ALL ORIGINAL LOGIC)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Perlu untuk JSON encode/decode map

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
  
  // State Zikir Harian (Untuk prompt home screen)
  bool _zikirDoneToday = false; 
  String _lastZikirDate = '';

  // ===== 4. SETTINGS (PRAYER & ALARM) =====
  int adhanModeIndex = 1; // Default: Full
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // Getter
  bool get zikirDoneToday => _zikirDoneToday;

  // Constructor
  UserModel({
    this.name = 'Pengguna iHijrah',
    this.birthdate,
    this.hijriDOB,
    this.avatarPath,
    this.gender,
  });

  // =========================================================
  // FUNGSI LOAD (MEMUAT TURUN DATA DARI MEMORI)
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

    // C. Load Daily Logs (JSON)
    String? fardhuJson = prefs.getString('daily_fardhu_log');
    if (fardhuJson != null) {
      user.dailyFardhuLog = Map<String, bool>.from(json.decode(fardhuJson));
    }
    
    String? amalanJson = prefs.getString('daily_amalan_log');
    if (amalanJson != null) {
      user.dailyAmalanLog = Map<String, bool>.from(json.decode(amalanJson));
    }

    user.selawatCountToday = prefs.getInt('selawat_count_today') ?? 0;

    // D. Load Settings (Alarm)
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

    // Jalankan semakan reset harian (untuk log solat dll)
    user._checkAndResetDailyData();

    return user;
  }

  // =========================================================
  // FUNGSI SAVE (SIMPAN DATA KE MEMORI)
  // =========================================================
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    // Basic
    await prefs.setString('user_name', name);
    if (hijriDOB != null) await prefs.setString('user_hijri_dob', hijriDOB!);
    if (avatarPath != null) await prefs.setString('user_avatar_path', avatarPath!);
    if (gender != null) await prefs.setString('user_gender', gender!);
    if (birthdate != null) await prefs.setString('user_birthdate', birthdate!.toIso8601String());

    // Points
    await prefs.setInt('user_tree_level', treeLevel);
    await prefs.setInt('user_total_points', totalPoints);

    // Logs
    await prefs.setString('daily_fardhu_log', json.encode(dailyFardhuLog));
    await prefs.setString('daily_amalan_log', json.encode(dailyAmalanLog));
    await prefs.setInt('selawat_count_today', selawatCountToday);

    // Settings
    await prefs.setInt('adhan_mode_index', adhanModeIndex);
    await prefs.setBool('alarm_fajr', isFajrAlarmEnabled);
    await prefs.setBool('alarm_dhuhr', isDhuhrAlarmEnabled);
    await prefs.setBool('alarm_asr', isAsrAlarmEnabled);
    await prefs.setBool('alarm_maghrib', isMaghribAlarmEnabled);
    await prefs.setBool('alarm_isha', isIshaAlarmEnabled);

    // Last Reset
    if (lastResetDate != null) {
      await prefs.setString('last_reset_date', lastResetDate!.toIso8601String());
    }
  }

  // =========================================================
  // ✅ NEW: UPDATE PROFILE (FOR ONBOARDING)
  // =========================================================
  Future<void> updateProfile({String? name, String? hijriDOB, String? avatarPath}) async {
    if (name != null) this.name = name;
    if (hijriDOB != null) this.hijriDOB = hijriDOB;
    if (avatarPath != null) this.avatarPath = avatarPath;
    
    await save(); // Simpan kekal
    notifyListeners();
  }

  // =========================================================
  // ✅ NEW: RECORD ZIKIR (FOR HOME PROMPT)
  // =========================================================
  Future<void> recordZikir() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    _zikirDoneToday = true;
    _lastZikirDate = today;

    // Tambah Point sikit sebagai ganjaran (Gamification)
    addPoints(10); 

    await prefs.setString('user_last_zikir_date', today);
    await prefs.setBool('user_zikir_done_today', true);
    
    notifyListeners();
  }

  // =========================================================
  // LOGIC ASAL (YANG HILANG TADI)
  // =========================================================

  void addPoints(int points) {
    totalPoints += points;
    _checkLevelUp();
    save();
    notifyListeners();
  }

  void _checkLevelUp() {
    // Logic mudah level up: Setiap 100 point naik 1 level (Max 5)
    int calculatedLevel = (totalPoints / 100).floor() + 1;
    if (calculatedLevel > 5) calculatedLevel = 5;

    if (calculatedLevel > treeLevel) {
      treeLevel = calculatedLevel;
      // Di sini boleh tambah logic play sound 'level up' jika mahu
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
    // Reset pada pukul 3 pagi (contoh) atau bila hari bertukar
    // Kita guna logik simple: Jika tarikh hari ini != tarikh last reset
    
    if (lastResetDate == null || !_isSameDay(now, lastResetDate!)) {
      // Lakukan Reset
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      
      lastResetDate = now;
      save(); // Simpan state 'kosong' baru
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
