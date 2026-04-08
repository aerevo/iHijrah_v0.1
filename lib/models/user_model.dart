// lib/models/user_model.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

// ─── POST MODEL (Untuk Wheel Feed) ───
class PostModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final String author;
  final String authorAge;
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

// ─── USER MODEL ───
class UserModel extends ChangeNotifier {
  // ===== 1. BASIC INFO =====
  String name = 'Pengguna iHijrah';
  DateTime? birthdate;
  String? hijriDOB;
  String? avatarPath;
  String gender = 'Lelaki';
  String email = '';
  String authMethod = 'Guest';

  // ===== 2. LEVEL & POINTS SYSTEM =====
  int treeLevel = 1;
  int totalPoints = 0;

  // ===== 3. DAILY TRACKING =====
  Map<String, bool> dailyFardhuLog = {};
  Map<String, bool> dailyAmalanLog = {};
  int selawatCountToday = 0;
  DateTime? lastResetDate;
  bool _zikirDoneToday = false;

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

  String get hijriAge {
    if (birthdate == null) return "0 Tahun";
    // Tukar DateTime ke String ISO untuk HijriService
    return HijriService.calculateHijriAge(birthdate!.toIso8601String());
  }

  // ===== METHODS =====
  void recordZikir() {
    _zikirDoneToday = true;
    addPoints(10);
    save();
    notifyListeners();
  }

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

  bool isFardhuDoneToday(String prayerName) => dailyFardhuLog[prayerName] ?? false;

  void recordFardhu(String prayerName) {
    dailyFardhuLog[prayerName] = true;
    addPoints(20);
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

  // ===== STORAGE =====
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'email': email,
      'gender': gender,
      'avatarPath': avatarPath,
      'authMethod': authMethod,
      'birthdate': birthdate?.toIso8601String(),
      'hijriDOB': hijriDOB,
      'treeLevel': treeLevel,
      'totalPoints': totalPoints,
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
      model.name = data['name'] ?? 'Pengguna iHijrah';
      model.email = data['email'] ?? '';
      model.gender = data['gender'] ?? 'Lelaki';
      model.avatarPath = data['avatarPath'];
      model.authMethod = data['authMethod'] ?? 'Guest';
      model.hijriDOB = data['hijriDOB'];
      if (data['birthdate'] != null) model.birthdate = DateTime.parse(data['birthdate']);
      model.treeLevel = data['treeLevel'] ?? 1;
      model.totalPoints = data['totalPoints'] ?? 0;
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
