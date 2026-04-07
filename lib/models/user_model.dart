import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

class UserModel extends ChangeNotifier {
  // Data Profil
  String name = 'Hamba Allah';
  String email = '';
  String gender = 'Lelaki';
  String avatarPath = ''; // Kosongkan dulu untuk guna placeholder
  DateTime? birthdate;

  // Data Progress
  int treeLevel = 1;
  int totalPoints = 0;

  // Getter Umur Hijriah (Untuk dipapar di Sidebar)
  String get hijriAge {
    if (birthdate == null) return "0 Tahun";
    // HijriService akan kira beza tarikh lahir dengan hari ini
    return HijriService.calculateHijriAge(birthdate!); 
  }

  // Simpan Data
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'email': email,
      'gender': gender,
      'birthdate': birthdate?.toIso8601String(),
      'totalPoints': totalPoints,
      'treeLevel': treeLevel,
    };
    await prefs.setString('user_data', json.encode(data));
    notifyListeners();
  }

  // Load Data
  static Future<UserModel> load() async {
    final model = UserModel();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw != null) {
      final data = json.decode(raw);
      model.name = data['name'] ?? 'Hamba Allah';
      model.email = data['email'] ?? '';
      model.gender = data['gender'] ?? 'Lelaki';
      if (data['birthdate'] != null) model.birthdate = DateTime.parse(data['birthdate']);
      model.totalPoints = data['totalPoints'] ?? 0;
      model.treeLevel = data['treeLevel'] ?? 1;
    }
    return model;
  }
}
