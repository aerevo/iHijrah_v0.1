// lib/models/user_model.dart (Using SharedPreferences)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== BASIC INFO =====
  String name = 'Pengguna iHijrah';
  DateTime?  birthdate;
  String? hijriDOB;
  String? avatarPath;

  // ===== LEVEL & POINTS SYSTEM =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== DAILY TRACKING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};
  int selawatCountToday = 0;
  DateTime? lastResetDate;

  // ===== SETTINGS =====
  int adhanModeIndex = 1; // Default:  Full
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== CONSTRUCTOR =====
  UserModel();

  // ===== GETTERS (COMPUTED PROPERTIES) =====
  int get nextLevelPoints => treeLevel * 100;
  double get progressPercentage => totalPoints / nextLevelPoints;

  bool get hasCompletedDailyBasics {
    return selawatCountToday >= 1 &&
        dailyFardhuLog.values.where((v) => v).length >= 3;
  }

  int get fardhuCompletedToday {
    _checkDailyReset();
    return dailyFardhuLog.values. where((v) => v).length;
  }

  int get amalanCompletedToday {
    _checkDailyReset();
    return dailyAmalanLog.values.where((v) => v).length;
  }

  // ===== PRIVATE HELPERS =====
  void _checkDailyReset() {
    final today = DateTime.now();
    if (lastResetDate == null || ! _isSameDay(lastResetDate!, today)) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      lastResetDate = today;
      save();
    }
  }

  void setPrayerAlarm(String prayerName, bool isEnabled) {
    switch (prayerName) {
      case 'Subuh':
        isFajrAlarmEnabled = isEnabled;
        break;
      case 'Zohor':
        isDhuhrAlarmEnabled = isEnabled;
        break;
      case 'Asar':
        isAsrAlarmEnabled = isEnabled;
        break;
      case 'Maghrib':
        isMaghribAlarmEnabled = isEnabled;
        break;
      case 'Isyak':
        isIshaAlarmEnabled = isEnabled;
        break;
    }
    save();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _checkLevelUp() {
    int requiredPoints = nextLevelPoints;
    bool leveledUp = false;
    while (totalPoints >= requiredPoints) {
      treeLevel++;
      totalPoints -= requiredPoints;
      requiredPoints = nextLevelPoints;
      leveledUp = true;
    }
    if (leveledUp) {
      save();
    }
  }

  // ===== PUBLIC ACTIONS =====
  void recordFardhu(String prayerName) {
    _checkDailyReset();
    if (dailyFardhuLog[prayerName] == true) return;
    dailyFardhuLog[prayerName] = true;
    totalPoints += 20;
    _checkLevelUp();
    save();
  }

  bool isFardhuDoneToday(String prayerName) {
    _checkDailyReset();
    return dailyFardhuLog[prayerName] ??  false;
  }

  /// Check if a fardhu prayer is completed today
  bool isFardhuComplete(String prayerName) {
    _checkDailyReset();
    return dailyFardhuLog[prayerName] ?? false;
  }

  /// Toggle fardhu prayer completion status
  void toggleFardhuCompletion(String prayerName) {
    _checkDailyReset();
    final isCurrentlyDone = dailyFardhuLog[prayerName] ?? false;
    if (isCurrentlyDone) {
      // If already done, remove it (undo)
      dailyFardhuLog. remove(prayerName);
      totalPoints -= 20;
    } else {
      // If not done, mark as done
      dailyFardhuLog[prayerName] = true;
      totalPoints += 20;
    }
    // Ensure totalPoints doesn't go negative
    if (totalPoints < 0) totalPoints = 0;
    _checkLevelUp();
    save();
  }

  void recordAmalan(String amalanId) {
    _checkDailyReset();
    if (dailyAmalanLog[amalanId] == true) return;
    dailyAmalanLog[amalanId] = true;
    totalPoints += 10;
    _checkLevelUp();
    save();
  }

  bool isAmalanDoneToday(String amalanId) {
    _checkDailyReset();
    return dailyAmalanLog[amalanId] ??  false;
  }

  /// Check if an optional/amalan activity is completed today
  bool isOptionalComplete(String amalanId) {
    _checkDailyReset();
    return dailyAmalanLog[amalanId] ?? false;
  }

  /// Toggle optional/amalan activity completion status
  void toggleOptionalCompletion(String amalanId) {
    _checkDailyReset();
    final isCurrentlyDone = dailyAmalanLog[amalanId] ?? false;
    if (isCurrentlyDone) {
      // If already done, remove it (undo)
      dailyAmalanLog.remove(amalanId);
      totalPoints -= 10;
    } else {
      // If not done, mark as done
      dailyAmalanLog[amalanId] = true;
      totalPoints += 10;
    }
    // Ensure totalPoints doesn't go negative
    if (totalPoints < 0) totalPoints = 0;
    _checkLevelUp();
    save();
  }

  void recordSelawat() {
    _checkDailyReset();
    selawatCountToday++;
    totalPoints += 5;
    _checkLevelUp();
    save();
  }

  void setAdhanMode(int index) {
    if (index >= 0 && index < AdhanMode.values.length) {
      adhanModeIndex = index;
      save();
    }
  }

  void setBirthDate(DateTime masihiDate) {
    birthdate = masihiDate;
    final hijriDate = HijriService. fromDate(masihiDate);
    hijriDOB = '${hijriDate.hDay}/${hijriDate.hMonth}/${hijriDate.hYear}';
    save();
  }

  void updateProfile({required String newName, required DateTime newDate}) {
    name = newName;
    setBirthDate(newDate); // Reuse setBirthDate logic
    save();
  }

  void setAvatarPath(String?  path) {
    avatarPath = path;
    save();
  }

  // ===== DATA PERSISTENCE =====

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      if (birthdate != null) {
        await prefs.setString('birthdate', birthdate! .toIso8601String());
      }
      if (hijriDOB != null) {
        await prefs.setString('hijriDOB', hijriDOB!);
      }
      if (avatarPath != null) {
        await prefs.setString('avatarPath', avatarPath!);
      }
      await prefs.setInt('treeLevel', treeLevel);
      await prefs.setInt('totalPoints', totalPoints);
      await prefs.setString('dailyFardhuLog', jsonEncode(dailyFardhuLog));
      await prefs. setString('dailyAmalanLog', jsonEncode(dailyAmalanLog));
      await prefs.setInt('selawatCountToday', selawatCountToday);
      if (lastResetDate != null) {
        await prefs.setString('lastResetDate', lastResetDate!.toIso8601String());
      }
      await prefs.setInt('adhanModeIndex', adhanModeIndex);
      await prefs.setBool('isFajrAlarmEnabled', isFajrAlarmEnabled);
      await prefs. setBool('isDhuhrAlarmEnabled', isDhuhrAlarmEnabled);
      await prefs.setBool('isAsrAlarmEnabled', isAsrAlarmEnabled);
      await prefs.setBool('isMaghribAlarmEnabled', isMaghribAlarmEnabled);
      await prefs.setBool('isIshaAlarmEnabled', isIshaAlarmEnabled);

      print('✅ Data saved successfully via SharedPreferences');
      notifyListeners();
    } catch (e) {
      print('❌ Error saving data: $e');
      rethrow;
    }
  }

  static Future<UserModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel();

    user.name = prefs.getString('name') ?? 'Pengguna iHijrah';
    final birthdateStr = prefs.getString('birthdate');
    if (birthdateStr != null) {
      user.birthdate = DateTime.parse(birthdateStr);
    }
    user.hijriDOB = prefs.getString('hijriDOB');
    user.avatarPath = prefs. getString('avatarPath');
    user.treeLevel = prefs.getInt('treeLevel') ?? 1;
    user.totalPoints = prefs.getInt('totalPoints') ?? 0;

    final fardhuStr = prefs.getString('dailyFardhuLog');
    if (fardhuStr != null) {
      user.dailyFardhuLog = Map<String, bool>.from(jsonDecode(fardhuStr));
    }

    final amalanStr = prefs.getString('dailyAmalanLog');
    if (amalanStr != null) {
      user.dailyAmalanLog = Map<String, bool>. from(jsonDecode(amalanStr));
    }

    user.selawatCountToday = prefs.getInt('selawatCountToday') ?? 0;
    final lastResetStr = prefs. getString('lastResetDate');
    if (lastResetStr != null) {
      user.lastResetDate = DateTime.parse(lastResetStr);
    }
    user.adhanModeIndex = prefs.getInt('adhanModeIndex') ?? 1;
    user.isFajrAlarmEnabled = prefs. getBool('isFajrAlarmEnabled') ?? true;
    user.isDhuhrAlarmEnabled = prefs.getBool('isDhuhrAlarmEnabled') ?? true;
    user.isAsrAlarmEnabled = prefs.getBool('isAsrAlarmEnabled') ?? true;
    user.isMaghribAlarmEnabled = prefs.getBool('isMaghribAlarmEnabled') ?? true;
    user.isIshaAlarmEnabled = prefs.getBool('isIshaAlarmEnabled') ?? true;

    print('✅ User data loaded from SharedPreferences');
    return user;
  }
}