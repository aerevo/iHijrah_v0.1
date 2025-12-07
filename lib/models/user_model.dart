// lib/models/user_model.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends ChangeNotifier with HiveObjectMixin {
  // ===== BASIC INFO =====
  @HiveField(0)
  String name = 'Pengguna iHijrah';

  @HiveField(1)
  DateTime? birthdate;

  @HiveField(11)
  String? hijriDOB;

  @HiveField(12)
  String? avatarPath;

  // ===== LEVEL & POINTS SYSTEM =====
  @HiveField(2)
  int treeLevel = 1;

  @HiveField(3)
  int totalPoints = 0;

  // ===== DAILY TRACKING =====
  @HiveField(4)
  Map<String, bool> dailyFardhuLog = {};

  @HiveField(5)
  Map<String, bool> dailyAmalanLog = {};

  @HiveField(6)
  int selawatCountToday = 0;

  @HiveField(7)
  DateTime? lastResetDate;

  // ===== SETTINGS =====
  @HiveField(10)
  int adhanModeIndex = 1; // Default: Full

  // ===== GETTERS (COMPUTED PROPERTIES) =====
  
  /// XP yang diperlukan untuk naik level seterusnya
  int get nextLevelPoints => treeLevel * 100;

  /// Progress percentage (0.0 - 1.0)
  double get progressPercentage => totalPoints / nextLevelPoints;

  /// Check if user has completed daily basics
  bool get hasCompletedDailyBasics {
    return selawatCountToday >= 1 && 
           dailyFardhuLog.values.where((v) => v).length >= 3;
  }

  /// Get total fardhu completed today
  int get fardhuCompletedToday {
    _checkDailyReset();
    return dailyFardhuLog.values.where((v) => v).length;
  }

  /// Get total amalan completed today
  int get amalanCompletedToday {
    _checkDailyReset();
    return dailyAmalanLog.values.where((v) => v).length;
  }

  // ===== PRIVATE HELPERS =====

  /// Reset data harian jika tarikh berubah
  void _checkDailyReset() {
    final today = DateTime.now();
    if (lastResetDate == null || !_isSameDay(lastResetDate!, today)) {
      // Hari baru! Reset counters
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      lastResetDate = today;
      save();
      notifyListeners();
    }
  }

  /// Check if two dates are same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Level up logic dengan animation trigger support
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
      notifyListeners();
    }
  }

  // ===== PUBLIC ACTIONS (UI CALLS THESE) =====

  /// Rekod solat fardhu (dengan XP reward)
  void recordFardhu(String prayerName) {
    _checkDailyReset();
    
    // Prevent double recording
    if (dailyFardhuLog[prayerName] == true) return;
    
    dailyFardhuLog[prayerName] = true;
    totalPoints += 20; // 20 XP untuk Fardhu
    _checkLevelUp();
    save();
    notifyListeners();
  }

  /// Check if fardhu done today
  bool isFardhuDoneToday(String prayerName) {
    _checkDailyReset();
    return dailyFardhuLog[prayerName] ?? false;
  }

  /// Rekod amalan sunnah (dengan XP reward)
  void recordAmalan(String amalanId) {
    _checkDailyReset();
    
    // Prevent double recording
    if (dailyAmalanLog[amalanId] == true) return;
    
    dailyAmalanLog[amalanId] = true;
    totalPoints += 10; // 10 XP untuk Sunnah
    _checkLevelUp();
    save();
    notifyListeners();
  }

  /// Check if amalan done today
  bool isAmalanDoneToday(String amalanId) {
    _checkDailyReset();
    return dailyAmalanLog[amalanId] ?? false;
  }

  /// Rekod selawat (dengan XP reward kecil)
  void recordSelawat() {
    _checkDailyReset();
    selawatCountToday++;
    totalPoints += 5; // 5 XP per sesi selawat
    _checkLevelUp();
    save();
    notifyListeners();
  }

  // ===== LEGACY SUPPORT (Untuk backward compatibility) =====

  /// Legacy method - check fardhu completion
  bool isFardhuComplete(String amal) => isFardhuDoneToday(amal);

  /// Legacy method - toggle fardhu (prevent undo)
  void toggleFardhuCompletion(String amal) {
    if (!isFardhuDoneToday(amal)) {
      recordFardhu(amal);
    }
  }

  /// Legacy method - check optional completion
  bool isOptionalComplete(String amal) => isAmalanDoneToday(amal);

  /// Legacy method - toggle optional
  void toggleOptionalCompletion(String amal) {
    if (!isOptionalComplete(amal)) {
      recordAmalan(amal);
    }
  }

  // ===== SETTINGS MANAGEMENT =====

  /// Update azan mode setting
  void setAdhanMode(int index) {
    if (index >= 0 && index < AdhanMode.values.length) {
      adhanModeIndex = index;
      save();
      notifyListeners();
    }
  }

  /// Update user profile (name & birthdate)
  void updateProfile({required String newName, required DateTime newDate}) {
    name = newName;
    birthdate = newDate;
    hijriDOB = HijriService.convertToHijri(newDate);
    save();
    notifyListeners();
  }

  /// Set user's birthdate from a Gregorian DateTime
  void setBirthDate(DateTime newDate) {
    birthdate = newDate;
    hijriDOB = HijriService.convertToHijri(newDate);
    save();
    notifyListeners();
  }

  /// Update avatar path
  void setAvatarPath(String? path) {
    avatarPath = path;
    save();
    notifyListeners();
  }

  // ===== DEBUG HELPERS (DEVELOPMENT ONLY) =====

  /// Reset all data (for testing)
  void resetAllData() {
    dailyFardhuLog.clear();
    dailyAmalanLog.clear();
    selawatCountToday = 0;
    totalPoints = 0;
    treeLevel = 1;
    save();
    notifyListeners();
  }

  /// Add points manually (for testing)
  void addPoints(int points) {
    totalPoints += points;
    _checkLevelUp();
    save();
    notifyListeners();
  }

  @override
  String toString() {
    return 'UserModel(name: $name, level: $treeLevel, points: $totalPoints/$nextLevelPoints, '
           'fardhu: $fardhuCompletedToday, amalan: $amalanCompletedToday, selawat: $selawatCountToday)';
  }
}