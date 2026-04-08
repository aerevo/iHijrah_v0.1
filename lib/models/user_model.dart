// lib/models/user_model.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

// ═══════════════════════════════════════════════════════════════
// POST MODEL — Data struktur untuk setiap kad dalam wheel feed
// ═══════════════════════════════════════════════════════════════
class PostModel {
  final String id;
  final String type;       // 'video' | 'quote' | 'article' | 'event'
  final String title;
  final String content;
  final String author;
  final String authorAge;  // Umur Hijrah penulis
  final String time;
  final int likes;
  final String? assetPath;

  const PostModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.author,
    this.authorAge = '',
    this.time = '',
    this.likes = 0,
    this.assetPath,
  });
}

// ═══════════════════════════════════════════════════════════════
// USER MODEL
// ═══════════════════════════════════════════════════════════════
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

  bool _zikirDoneToday = false;
  String _lastZikirDate = '';

  // ===== 4. SETTINGS =====
  int adhanModeIndex = 1;
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  bool get zikirDoneToday => _zikirDoneToday;
  int get nextLevelPoints => treeLevel * 100;

  UserModel({
    this.name = 'Pengguna iHijrah',
    this.birthdate,
    this.hijriDOB,
    this.avatarPath,
    this.gender,
  });

  // =========================================================
  // LOAD
  // =========================================================
  static Future<UserModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel();

    user.name = prefs.getString('user_name') ?? 'Pengguna iHijrah';
    user.hijriDOB = prefs.getString('user_hijri_dob');
    user.avatarPath = prefs.getString('user_avatar_path');
    user.gender = prefs.getString('user_gender');

    String? dobIso = prefs.getString('user_birthdate');
    if (dobIso != null) user.birthdate = DateTime.tryParse(dobIso);

    user.treeLevel = prefs.getInt('user_tree_level') ?? 1;
    user.totalPoints = prefs.getInt('user_total_points') ?? 0;

    String? fardhuJson = prefs.getString('daily_fardhu_log');
    if (fardhuJson != null) user.dailyFardhuLog = Map<String, bool>.from(json.decode(fardhuJson));

    String? amalanJson = prefs.getString('daily_amalan_log');
    if (amalanJson != null) user.dailyAmalanLog = Map<String, bool>.from(json.decode(amalanJson));

    user.selawatCountToday = prefs.getInt('selawat_count_today') ?? 0;

    user.adhanModeIndex = prefs.getInt('adhan_mode_index') ?? 1;
    user.isFajrAlarmEnabled = prefs.getBool('alarm_fajr') ?? true;
    user.isDhuhrAlarmEnabled = prefs.getBool('alarm_dhuhr') ?? true;
    user.isAsrAlarmEnabled = prefs.getBool('alarm_asr') ?? true;
    user.isMaghribAlarmEnabled = prefs.getBool('alarm_maghrib') ?? true;
    user.isIshaAlarmEnabled = prefs.getBool('alarm_isha') ?? true;

    String? lastResetIso = prefs.getString('last_reset_date');
    if (lastResetIso != null) user.lastResetDate = DateTime.tryParse(lastResetIso);

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastZikirStr = prefs.getString('user_last_zikir_date') ?? '';
    if (lastZikirStr == todayStr) {
      user._zikirDoneToday = prefs.getBool('user_zikir_done_today') ?? false;
    } else {
      user._zikirDoneToday = false;
    }
    user._lastZikirDate = lastZikirStr;
    user._checkAndResetDailyData();

    return user;
  }

  // =========================================================
  // SAVE
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
  // UPDATE PROFILE
  // =========================================================
  Future<void> updateProfile({String? name, String? hijriDOB, String? avatarPath}) async {
    if (name != null) this.name = name;
    if (hijriDOB != null) this.hijriDOB = hijriDOB;
    if (avatarPath != null) this.avatarPath = avatarPath;
    await save();
    notifyListeners();
  }

  void setBirthDate(DateTime date) {
    birthdate = date;
    save();
    notifyListeners();
  }

  // =========================================================
  // RECORD ZIKIR
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
  // RECORD SELAWAT
  // =========================================================
  void recordSelawat() {
    selawatCountToday++;
    addPoints(5);
    save();
    notifyListeners();
  }

  // =========================================================
  // POINTS
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
    if (calculatedLevel > treeLevel) treeLevel = calculatedLevel;
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
      lastResetDate = now;
      save();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
