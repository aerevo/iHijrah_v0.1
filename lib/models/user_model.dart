// lib/models/user_model.dart (DATA CORE - LAZY LOAD READY)
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

  // ===== LEVEL & GAMIFICATION =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== SETTINGS =====
  int adhanModeIndex = 0; // 0: Off, 1: Short, 2: Full

  // ===== LOGGING =====
  Map<String, bool> dailyFardhuLog = {};
  DateTime? lastResetDate;

  // ===== FUNGSI UTAMA: LOAD DATA (PANGGIL DI SPLASH SCREEN) =====
  Future<void> loadData() async {
    try {
      debugPrint('🔵 START: UserModel.loadData()');

      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2)); // Add timeout
      
      name = prefs.getString('name') ?? 'Pengguna iHijrah';
      debugPrint('✅ Name loaded: $name');
      
      final birthdateStr = prefs.getString('birthdate');
      if (birthdateStr != null) {
        birthdate = DateTime.parse(birthdateStr);
        debugPrint('✅ Birthdate loaded: $birthdate');
      }
      
      hijriDOB = prefs.getString('hijriDOB');
      avatarPath = prefs.getString('avatarPath');

      treeLevel = prefs.getInt('treeLevel') ?? 1;
      totalPoints = prefs.getInt('totalPoints') ?? 0;
      adhanModeIndex = prefs.getInt('adhanModeIndex') ?? 0;
      
      final fardhuStr = prefs.getString('dailyFardhuLog');
      if (fardhuStr != null && fardhuStr.isNotEmpty) {
        try {
          dailyFardhuLog = Map<String, bool>.from(jsonDecode(fardhuStr));
        } catch (e) {
          debugPrint('⚠️ Error parsing dailyFardhuLog: $e');
          dailyFardhuLog = {};
        }
      }
      
      _checkDailyReset();

      debugPrint('✅ COMPLETE: UserModel.loadData()');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR in loadData: $e');
      // Set default values bila error
      name = 'Pengguna iHijrah';
      treeLevel = 1;
      totalPoints = 0;
      notifyListeners();
    }
  }

  // ===== UPDATE PROFILE (UNTUK ONBOARDING) =====
  void updateProfile({required String newName, required DateTime newDate}) {
    name = newName;
    birthdate = newDate;
    
    final hijriDate = HijriService.fromDate(newDate);
    hijriDOB = '${hijriDate.hDay}/${hijriDate.hMonth}/${hijriDate.hYear}';
    
    save(); 
    notifyListeners();
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
    
    await prefs.setInt('treeLevel', treeLevel);
    await prefs.setInt('totalPoints', totalPoints);
    await prefs.setInt('adhanModeIndex', adhanModeIndex);
    await prefs.setString('dailyFardhuLog', jsonEncode(dailyFardhuLog));
    
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
      lastResetDate = today;
      save();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}