// lib/models/user_model.dart (UPGRADED: Zikir & Reset Logic)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/settings_enums.dart';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // ===== BASIC INFO =====
  String name = 'Pengguna iHijrah';
  DateTime? birthdate;
  String? hijriDOB;
  String? avatarPath;
  String? gender; // Added safety based on previous context

  // ===== LEVEL & POINTS SYSTEM =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== DAILY TRACKING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};
  int selawatCountToday = 0;
  DateTime? lastResetDate;
  
  // ✅ DITAMBAH: ZIKIR LOGIC
  bool _zikirDoneToday = false; 

  // ===== SETTINGS =====
  int adhanModeIndex = 1; // Default: Full
  bool isFajrAlarmEnabled = true;
  bool isDhuhrAlarmEnabled = true;
  bool isAsrAlarmEnabled = true;
  bool isMaghribAlarmEnabled = true;
  bool isIshaAlarmEnabled = true;

  // ===== CONSTRUCTOR =====
  UserModel({
    this.name = 'Pengguna iHijrah',
    this.birthdate,
    this.hijriDOB,
    this.avatarPath,
    this.gender,
  });

  // ===== GETTERS (COMPUTED PROPERTIES) =====
  int get nextLevelPoints => treeLevel * 100;
  double get progressPercentage => totalPoints / nextLevelPoints;
  // ✅ DITAMBAH GETTER: Untuk home.dart
  bool get zikirDoneToday => _zikirDoneToday; 


  // ===== INIT & SAVE =====

  static Future<UserModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel();
    
    user.name = prefs.getString('name') ?? user.name;
    final birthdateStr = prefs.getString('birthdate');
    if (birthdateStr != null) {
      try {
        user.birthdate = DateTime.parse(birthdateStr);
      } catch (e) {
        debugPrint('Error parsing birthdate: $e');
      }
    }
    
    // ✅ Load HijriDOB
    user.hijriDOB = prefs.getString('hijriDOB');
    user.avatarPath = prefs.getString('avatarPath');
    user.gender = prefs.getString('user_gender');
    
    user.treeLevel = prefs.getInt('treeLevel') ?? 1;
    user.totalPoints = prefs.getInt('totalPoints') ?? 0;

    final fardhuStr = prefs.getString('dailyFardhuLog');
    if (fardhuStr != null) {
      user.dailyFardhuLog = Map<String, bool>.from(jsonDecode(fardhuStr));
    }

    final amalanStr = prefs.getString('dailyAmalanLog');
    if (amalanStr != null) {
      user.dailyAmalanLog = Map<String, bool>.from(jsonDecode(amalanStr));
    }

    user.selawatCountToday = prefs.getInt('selawatCountToday') ?? 0;
    final lastResetStr = prefs.getString('lastResetDate');
    if (lastResetStr != null) {
      user.lastResetDate = DateTime.parse(lastResetStr);
    }
    user.adhanModeIndex = prefs.getInt('adhanModeIndex') ?? 1;
    user.isFajrAlarmEnabled = prefs.getBool('isFajrAlarmEnabled') ?? true;
    user.isDhuhrAlarmEnabled = prefs.getBool('isDhuhrAlarmEnabled') ?? true;
    user.isAsrAlarmEnabled = prefs.getBool('isAsrAlarmEnabled') ?? true;
    user.isMaghribAlarmEnabled = prefs.getBool('isMaghribAlarmEnabled') ?? true;
    user.isIshaAlarmEnabled = prefs.getBool('isIshaAlarmEnabled') ?? true;
    
    // ✅ LOAD ZIKIR
    user._zikirDoneToday = prefs.getBool('zikirDoneToday') ?? false; 

    user._checkAndResetDailyData();

    return user;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    if (birthdate != null) {
      prefs.setString('birthdate', birthdate!.toIso8601String());
    }
    prefs.setString('hijriDOB', hijriDOB ?? '');
    prefs.setString('avatarPath', avatarPath ?? '');
    prefs.setString('user_gender', gender ?? '');
    
    prefs.setInt('treeLevel', treeLevel);
    prefs.setInt('totalPoints', totalPoints);

    prefs.setString('dailyFardhuLog', jsonEncode(dailyFardhuLog));
    prefs.setString('dailyAmalanLog', jsonEncode(dailyAmalanLog));

    prefs.setInt('selawatCountToday', selawatCountToday);
    prefs.setString('lastResetDate', lastResetDate!.toIso8601String());
    
    prefs.setInt('adhanModeIndex', adhanModeIndex);
    prefs.setBool('isFajrAlarmEnabled', isFajrAlarmEnabled);
    prefs.setBool('isDhuhrAlarmEnabled', isDhuhrAlarmEnabled);
    prefs.setBool('isAsrAlarmEnabled', isAsrAlarmEnabled);
    prefs.setBool('isMaghribAlarmEnabled', isMaghribAlarmEnabled);
    prefs.setBool('isIshaAlarmEnabled', isIshaAlarmEnabled);
    
    // ✅ SAVE ZIKIR
    prefs.setBool('zikirDoneToday', _zikirDoneToday);

  }

  // ===== USER MUTATORS =====

  void setProfile({required String newName, required DateTime newBirthdate, String? newGender}) {
    name = newName;
    birthdate = newBirthdate;
    hijriDOB = HijriService.fromDate(newBirthdate).toString(); // Simpan string Hijri
    gender = newGender;
    save();
    notifyListeners();
  }

  // ✅ DITAMBAH METHOD: Untuk home.dart
  Future<void> recordZikir() async {
    _zikirDoneToday = true;
    // Beri sedikit mata ganjaran
    addPoints(5);
    await save();
    notifyListeners();
  }

  void setAvatarPath(String path) {
    avatarPath = path;
    save();
    notifyListeners();
  }

  // ===== POINT & LEVELING =====

  void addPoints(int points) {
    totalPoints += points;
    if (totalPoints >= nextLevelPoints) {
      _levelUp();
    }
    save();
    notifyListeners();
  }

  void _levelUp() {
    treeLevel++;
    totalPoints = totalPoints - (treeLevel - 1) * 100; // Reset points based on new level
    // In production, trigger animation/notification here
  }

  // ===== TRACKER LOGIC =====

  void toggleFardhu(String prayerName) {
    dailyFardhuLog[prayerName] = !(dailyFardhuLog[prayerName] ?? false);
    
    // Beri 10 point untuk setiap solat
    if (dailyFardhuLog[prayerName] == true) {
      addPoints(10);
    } else {
      // Tolak balik kalau uncheck
      totalPoints = (totalPoints - 10).clamp(0, totalPoints); 
    }
    save();
    notifyListeners();
  }

  bool isFardhuDoneToday(String prayerName) {
    return dailyFardhuLog[prayerName] ?? false;
  }
  
  void recordAmalan(String amalanId) {
    dailyAmalanLog[amalanId] = !(dailyAmalanLog[amalanId] ?? false);
    
    // Beri 5 point untuk setiap amalan sunat
    if (dailyAmalanLog[amalanId] == true) {
      addPoints(5);
    } else {
      // Tolak balik kalau uncheck
      totalPoints = (totalPoints - 5).clamp(0, totalPoints);
    }
    save();
    notifyListeners();
  }

  bool isAmalanDoneToday(String amalanId) {
    return dailyAmalanLog[amalanId] ?? false;
  }

  void incrementSelawat() {
    selawatCountToday++;
    // Setiap 100 selawat, bagi point tambahan
    if (selawatCountToday % 100 == 0) {
      addPoints(2);
    }
    save();
    notifyListeners();
  }

  // ===== SETTINGS MUTATORS =====

  void setAdhanMode(int modeIndex) {
    adhanModeIndex = modeIndex;
    save();
    notifyListeners();
  }

  void setPrayerAlarm(String prayerName, bool isEnabled) {
    // Logic setting alarm berdasarkan nama solat
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
    notifyListeners();
  }

  // ===== DAILY RESET =====

  void _checkAndResetDailyData() {
    final now = DateTime.now();
    
    // Reset setiap hari pada waktu tertentu (contoh: 3 pagi)
    final resetTime = DateTime(now.year, now.month, now.day, 3, 0, 0); 

    bool needsReset = false;
    
    if (lastResetDate == null) {
      needsReset = true;
    } else {
      // Jika reset time hari ini sudah berlalu DAN reset terakhir sebelum hari ini
      if (now.isAfter(resetTime) && lastResetDate!.isBefore(resetTime)) {
        needsReset = true;
      }
    }

    if (needsReset) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      selawatCountToday = 0;
      lastResetDate = now;
      _zikirDoneToday = false; // ✅ RESET ZIKIR
      save(); // Save the reset state
      // Tidak perlu notifyListeners di sini jika dipanggil semasa load()
    }
  }
}
