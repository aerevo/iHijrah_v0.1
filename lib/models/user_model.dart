// lib/models/user_model.dart (DATA CORE - LAZY LOAD READY)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart'; // Pastikan path betul

class UserModel extends ChangeNotifier {
  // ===== BASIC INFO =====
  String name = 'Pengguna iHijrah'; // Default
  DateTime? birthdate; 
  String? hijriDOB;
  String? avatarPath;

  // ===== LEVEL & GAMIFICATION =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== LOGGING =====
  Map<String, bool> dailyFardhuLog = {};
  DateTime? lastResetDate;

  // ===== COMPUTED GETTERS =====
  int get nextLevelPoints => treeLevel * 100;
  
  // ===== FUNGSI UTAMA: LOAD DATA (PANGGIL DI SPLASH SCREEN) =====
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Load Info Asas
      name = prefs.getString('name') ?? 'Pengguna iHijrah';
      
      final birthdateStr = prefs.getString('birthdate');
      if (birthdateStr != null) {
        birthdate = DateTime.parse(birthdateStr);
      }
      
      hijriDOB = prefs.getString('hijriDOB');
      avatarPath = prefs.getString('avatarPath');

      // 2. Load Progress
      treeLevel = prefs.getInt('treeLevel') ?? 1;
      totalPoints = prefs.getInt('totalPoints') ?? 0;
      
      // 3. Load Logs
      final fardhuStr = prefs.getString('dailyFardhuLog');
      if (fardhuStr != null) {
        dailyFardhuLog = Map<String, bool>.from(jsonDecode(fardhuStr));
      }
      
      // 4. Reset Harian (Jika tarikh dah berubah)
      _checkDailyReset();

      notifyListeners(); // Update UI
    } catch (e) {
      debugPrint("⚠️ Error Loading User Data: $e");
    }
  }

  // ===== UPDATE PROFILE (UNTUK ONBOARDING) =====
  void updateProfile({required String newName, required DateTime newDate}) {
    name = newName;
    birthdate = newDate;
    
    // Auto convert Hijrah
    final hijriDate = HijriService.fromDate(newDate);
    hijriDOB = '${hijriDate.hDay}/${hijriDate.hMonth}/${hijriDate.hYear}';
    
    save(); // Simpan kekal
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