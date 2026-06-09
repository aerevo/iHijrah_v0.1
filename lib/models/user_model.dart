// lib/models/user_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/hijri_service.dart';

// ═══════════════════════════════════════════
// POST MODEL — Komuniti Feed
// ═══════════════════════════════════════════
class PostModel {
  final String  id;
  final String  type;         // video | article | event | quote | hadith | amalan | sirah
  final String  title;
  final String  content;
  final String  author;
  final String  authorId;
  final String  authorAge;    // umur Hijri penulis
  final String  time;
  final int     likes;
  final int     commentsCount;
  final bool    isLiked;
  final String? assetPath;
  final String? category;     // kategori komuniti

  const PostModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.author,
    this.authorId       = '',
    this.authorAge      = '',
    this.time           = '',
    this.likes          = 0,
    this.commentsCount  = 0,
    this.isLiked        = false,
    this.assetPath,
    this.category,
  });

  PostModel copyWith({bool? isLiked, int? likes}) => PostModel(
    id:            id,
    type:          type,
    title:         title,
    content:       content,
    author:        author,
    authorId:      authorId,
    authorAge:     authorAge,
    time:          time,
    likes:         likes ?? this.likes,
    commentsCount: commentsCount,
    isLiked:       isLiked ?? this.isLiked,
    assetPath:     assetPath,
    category:      category,
  );
}

// ═══════════════════════════════════════════
// USER MODEL
// ═══════════════════════════════════════════
class UserModel extends ChangeNotifier {

  // ── 1. IDENTITI ASAS ─────────────────────────────────────────
  String    name        = '';
  DateTime? birthdate;          // tarikh lahir Masihi
  String?   hijriDOB;           // "1410/09/12" atau ISO string
  String?   avatarPath;
  String    gender      = 'Lelaki';
  String    email       = '';
  String    authMethod  = 'Guest';

  // ── 2. IDENTITI KOMUNITI ──────────────────────────────────────
  String bio            = '';   // bio pendek
  int    followersCount = 0;
  int    followingCount = 0;
  int    postsCount     = 0;

  // ── 3. POKOK HIJRAH — LEVEL & POIN ───────────────────────────
  int treeLevel   = 1;
  int totalPoints = 0;

  // ── 4. STREAK & TRACKING HARIAN ──────────────────────────────
  int      currentStreak    = 0;   // hari berturut-turut ada aktiviti
  int      longestStreak    = 0;
  DateTime? lastActiveDate;
  Map<String, bool> dailyFardhuLog  = {};
  Map<String, bool> dailyAmalanLog  = {};
  int      selawatCountToday = 0;
  bool     _zikirDoneToday   = false;

  // ── 5. TETAPAN SOLAT ─────────────────────────────────────────
  int  adhanModeIndex         = 1;
  bool isFajrAlarmEnabled     = true;
  bool isDhuhrAlarmEnabled    = true;
  bool isAsrAlarmEnabled      = true;
  bool isMaghribAlarmEnabled  = true;
  bool isIshaAlarmEnabled     = true;

  // ── GETTERS ───────────────────────────────────────────────────
  bool get zikirDoneToday  => _zikirDoneToday;
  int  get nextLevelPoints => treeLevel * 100;
  int  get progressPoints  => totalPoints % 100;

  /// "34 Tahun" dalam Hijri
  String get hijriAge => HijriService.calculateHijriAge(
    birthdate?.toIso8601String() ?? hijriDOB,
  );

  /// "15 Ramadan" — tarikh lahir Hijri
  String get hijriBirthdayDisplay => HijriService.birthdayDisplay(
    birthdate?.toIso8601String() ?? hijriDOB,
  );

  /// Berapa hari lagi hari jadi Hijri
  int get daysUntilBirthday => HijriService.getDaysUntilNextBirthday(
    birthdate?.toIso8601String() ?? hijriDOB,
  );

  /// Adakah hari ini hari jadi Hijri?
  bool get isBirthdayToday => HijriService.isBirthdayToday(
    birthdate?.toIso8601String() ?? hijriDOB,
  );

  /// Fasa kenabian
  String get propheticPhase => HijriService.propheticAgeComparison(
    birthdate?.toIso8601String() ?? hijriDOB,
  );

  // ── METHODS — IBADAH ─────────────────────────────────────────
  void recordZikir() {
    _zikirDoneToday = true;
    addPoints(10);
    _updateStreak();
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
    int level = (totalPoints / 100).floor() + 1;
    if (level > 5) level = 5;
    if (level > treeLevel) treeLevel = level;
  }

  bool isFardhuDoneToday(String prayer) => dailyFardhuLog[prayer] ?? false;

  void recordFardhu(String prayer) {
    dailyFardhuLog[prayer] = true;
    addPoints(20);
    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() {
    final today = DateTime.now();
    if (lastActiveDate != null) {
      final diff = today.difference(lastActiveDate!).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) longestStreak = currentStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }
    lastActiveDate = today;
    save();
  }

  void setAdhanMode(int modeIndex) {
    adhanModeIndex = modeIndex;
    save();
    notifyListeners();
  }

  void setPrayerAlarm(String prayer, bool enabled) {
    switch (prayer) {
      case 'Subuh':   isFajrAlarmEnabled    = enabled; break;
      case 'Zohor':   isDhuhrAlarmEnabled   = enabled; break;
      case 'Asar':    isAsrAlarmEnabled     = enabled; break;
      case 'Maghrib': isMaghribAlarmEnabled = enabled; break;
      case 'Isyak':   isIshaAlarmEnabled    = enabled; break;
    }
    save();
    notifyListeners();
  }

  // ── STORAGE ───────────────────────────────────────────────────
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode({
      'name':                 name,
      'email':                email,
      'gender':               gender,
      'bio':                  bio,
      'avatarPath':           avatarPath,
      'authMethod':           authMethod,
      'birthdate':            birthdate?.toIso8601String(),
      'hijriDOB':             hijriDOB,
      'followersCount':       followersCount,
      'followingCount':       followingCount,
      'postsCount':           postsCount,
      'treeLevel':            treeLevel,
      'totalPoints':          totalPoints,
      'currentStreak':        currentStreak,
      'longestStreak':        longestStreak,
      'lastActiveDate':       lastActiveDate?.toIso8601String(),
      'zikirDoneToday':       _zikirDoneToday,
      'adhanModeIndex':       adhanModeIndex,
      'isFajrAlarmEnabled':   isFajrAlarmEnabled,
      'isDhuhrAlarmEnabled':  isDhuhrAlarmEnabled,
      'isAsrAlarmEnabled':    isAsrAlarmEnabled,
      'isMaghribAlarmEnabled':isMaghribAlarmEnabled,
      'isIshaAlarmEnabled':   isIshaAlarmEnabled,
    }));
  }

  static Future<UserModel> load() async {
    final m = UserModel();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw == null) return m;

    final d = json.decode(raw);
    m.name           = d['name']       ?? '';
    m.email          = d['email']      ?? '';
    m.gender         = d['gender']     ?? 'Lelaki';
    m.bio            = d['bio']        ?? '';
    m.avatarPath     = d['avatarPath'];
    m.authMethod     = d['authMethod'] ?? 'Guest';
    m.hijriDOB       = d['hijriDOB'];
    if (d['birthdate'] != null) m.birthdate = DateTime.parse(d['birthdate']);
    m.followersCount       = d['followersCount']   ?? 0;
    m.followingCount       = d['followingCount']   ?? 0;
    m.postsCount           = d['postsCount']       ?? 0;
    m.treeLevel            = d['treeLevel']        ?? 1;
    m.totalPoints          = d['totalPoints']      ?? 0;
    m.currentStreak        = d['currentStreak']    ?? 0;
    m.longestStreak        = d['longestStreak']    ?? 0;
    if (d['lastActiveDate'] != null) m.lastActiveDate = DateTime.parse(d['lastActiveDate']);
    m._zikirDoneToday      = d['zikirDoneToday']   ?? false;
    m.adhanModeIndex       = d['adhanModeIndex']   ?? 1;
    m.isFajrAlarmEnabled   = d['isFajrAlarmEnabled']    ?? true;
    m.isDhuhrAlarmEnabled  = d['isDhuhrAlarmEnabled']   ?? true;
    m.isAsrAlarmEnabled    = d['isAsrAlarmEnabled']     ?? true;
    m.isMaghribAlarmEnabled= d['isMaghribAlarmEnabled'] ?? true;
    m.isIshaAlarmEnabled   = d['isIshaAlarmEnabled']    ?? true;
    return m;
  }
}
