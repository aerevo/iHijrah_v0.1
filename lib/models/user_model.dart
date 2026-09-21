// lib/models/user_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // 'yyyy-MM-dd' — tarikh terakhir dailyFardhuLog/dailyAmalanLog di-reset.
  // Tanpa ni, log tak pernah bersih & amalan yg sama takkan boleh
  // ditanda semula esok (Map dikunci ikut id, bukan ikut tarikh).
  String? lastLogResetDate;
  int      selawatCountToday = 0;
  bool     _zikirDoneToday   = false;

  // ── 5. TETAPAN SOLAT ─────────────────────────────────────────
  int  adhanModeIndex         = 1;
  bool isFajrAlarmEnabled     = true;
  bool isDhuhrAlarmEnabled    = true;
  bool isAsrAlarmEnabled      = true;
  bool isMaghribAlarmEnabled  = true;
  bool isIshaAlarmEnabled     = true;
  bool zikirReminderEnabled   = true;

  // ── 6. TETAPAN APP ────────────────────────────────────────────
  /// 'auto' (ikut waktu Subuh/Maghrib sebenar) | 'day' | 'night'
  String themeMode = 'auto';

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

  bool isFardhuDoneToday(String prayer) {
    _ensureFreshDailyLogs();
    return dailyFardhuLog[prayer] ?? false;
  }

  /// Toggle status siap. Bagi +20 XP HANYA bila bertukar ke siap (elak
  /// exploit tekan-berulang). Sebelum ni sentiasa set true + bagi XP
  /// tiap kali dipanggil — kalau ada UI tekan, XP infinite.
  void recordFardhu(String prayer) {
    _ensureFreshDailyLogs();
    final bool wasDone = dailyFardhuLog[prayer] ?? false;
    dailyFardhuLog[prayer] = !wasDone;
    if (!wasDone) {
      addPoints(20);
      _updateStreak();
    } else {
      save();
      notifyListeners();
    }
  }

  // ── AMALAN SUNAT — tanda siap, simpan & bagi XP ────────────────
  bool isAmalanDoneToday(String amalanId) {
    _ensureFreshDailyLogs();
    return dailyAmalanLog[amalanId] ?? false;
  }

  /// Toggle status siap. Bagi +15 XP HANYA bila bertukar ke siap (elak
  /// exploit tekan-lepas-tekan berulang utk kumpul XP percuma). Tekan
  /// semula utk nyahtanda TIDAK tolak XP balik — sengaja, elak UX buruk
  /// (rasa dihukum) kalau tersalah tekan.
  void toggleAmalanDone(String amalanId) {
    _ensureFreshDailyLogs();
    final bool wasDone = dailyAmalanLog[amalanId] ?? false;
    dailyAmalanLog[amalanId] = !wasDone;
    if (!wasDone) {
      addPoints(15);
      _updateStreak();
    } else {
      save();
      notifyListeners();
    }
  }

  void _ensureFreshDailyLogs() {
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastLogResetDate != today) {
      dailyFardhuLog.clear();
      dailyAmalanLog.clear();
      lastLogResetDate = today;
    }
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

  void setZikirReminder(bool enabled) {
    zikirReminderEnabled = enabled;
    save();
    notifyListeners();
  }

  /// 'auto' | 'day' | 'night' — dibaca oleh PrayerService.isDayTime
  /// utk override tema siang/malam FeedPalette.
  void setThemeMode(String mode) {
    themeMode = mode;
    save();
    notifyListeners();
  }

  // ── STORAGE (SharedPreferences local) ───────────────────────────
  Map<String, dynamic> _toMap() => {
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
    'lastLogResetDate':     lastLogResetDate,
    'dailyFardhuLog':       dailyFardhuLog,
    'dailyAmalanLog':       dailyAmalanLog,
    'zikirDoneToday':       _zikirDoneToday,
    'adhanModeIndex':       adhanModeIndex,
    'isFajrAlarmEnabled':   isFajrAlarmEnabled,
    'isDhuhrAlarmEnabled':  isDhuhrAlarmEnabled,
    'isAsrAlarmEnabled':    isAsrAlarmEnabled,
    'isMaghribAlarmEnabled':isMaghribAlarmEnabled,
    'isIshaAlarmEnabled':   isIshaAlarmEnabled,
    'zikirReminderEnabled': zikirReminderEnabled,
    'themeMode':            themeMode,
  };

  void _applyMap(Map<String, dynamic> d) {
    name           = d['name']       ?? '';
    email          = d['email']      ?? '';
    gender         = d['gender']     ?? 'Lelaki';
    bio            = d['bio']        ?? '';
    avatarPath     = d['avatarPath'];
    authMethod     = d['authMethod'] ?? 'Guest';
    hijriDOB       = d['hijriDOB'];
    if (d['birthdate'] != null) birthdate = DateTime.parse(d['birthdate']);
    followersCount       = d['followersCount']   ?? 0;
    followingCount       = d['followingCount']   ?? 0;
    postsCount           = d['postsCount']       ?? 0;
    treeLevel            = d['treeLevel']        ?? 1;
    totalPoints          = d['totalPoints']      ?? 0;
    currentStreak        = d['currentStreak']    ?? 0;
    longestStreak        = d['longestStreak']    ?? 0;
    if (d['lastActiveDate'] != null) lastActiveDate = DateTime.parse(d['lastActiveDate']);
    lastLogResetDate    = d['lastLogResetDate'];
    dailyFardhuLog      = Map<String, bool>.from(d['dailyFardhuLog'] ?? {});
    dailyAmalanLog      = Map<String, bool>.from(d['dailyAmalanLog'] ?? {});
    _zikirDoneToday      = d['zikirDoneToday']   ?? false;
    adhanModeIndex       = d['adhanModeIndex']   ?? 1;
    isFajrAlarmEnabled   = d['isFajrAlarmEnabled']    ?? true;
    isDhuhrAlarmEnabled  = d['isDhuhrAlarmEnabled']   ?? true;
    isAsrAlarmEnabled    = d['isAsrAlarmEnabled']     ?? true;
    isMaghribAlarmEnabled= d['isMaghribAlarmEnabled'] ?? true;
    isIshaAlarmEnabled   = d['isIshaAlarmEnabled']    ?? true;
    zikirReminderEnabled = d['zikirReminderEnabled']  ?? true;
    themeMode            = d['themeMode']             ?? 'auto';
  }

  /// Simpan local (SharedPreferences) — SENTIASA berjalan & sentiasa
  /// disiapkan (await-able) macam asal. Push ke cloud pula "fire and
  /// forget" (tak di-await) — supaya tiap save() (dipanggil sangat
  /// kerap: addPoints, toggle amalan, dll) tak jadi perlahan/block UI
  /// sebab tunggu network. Kalau offline/gagal, local tetap selamat.
  Future<void> save() async {
    final map = _toMap();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(map));
    _pushToCloud(map);
  }

  static Future<UserModel> load() async {
    final m = UserModel();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw == null) return m;
    m._applyMap(json.decode(raw));
    return m;
  }

  // ── STORAGE (Firebase — backup, dipulih lepas reinstall) ────────
  static String? _uidOrNull() => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _pushToCloud(Map<String, dynamic> map) async {
    final String? uid = _uidOrNull();
    if (uid == null) return; // belum log masuk — cloud sync x applicable
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(map);
    } catch (e) {
      // Senyap sahaja — local (SharedPreferences) dah cukup utk app
      // terus berfungsi walau offline. Cloud cuma backup/sync, bukan
      // satu-satunya sumber data.
      debugPrint('UserModel._pushToCloud gagal (offline?): $e');
    }
  }

  /// Panggil SEKALI lepas login berjaya (dari AuthScreen) — bukan
  /// automatik berulang, elak overwrite tak sengaja data local yg
  /// mungkin lagi baru. Pulangkan true kalau dokumen cloud wujud &
  /// berjaya dimuatkan (data cloud override local + di-cache semula).
  Future<bool> pullFromCloud() async {
    final String? uid = _uidOrNull();
    if (uid == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return false;
      _applyMap(doc.data()!);
      await save(); // cache ke local sekali, supaya offline pun ada
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('UserModel.pullFromCloud gagal: $e');
      return false;
    }
  }
}
