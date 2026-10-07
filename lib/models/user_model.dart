// lib/models/user_model.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/hijri_service.dart';
import '../utils/result.dart';
import '../services/profile_service.dart';
import '../services/social_failure.dart';
import '../services/social_service.dart';

/// Hasil [UserModel.pullFromCloudDetailed].
enum CloudPullResult {
  /// Dokumen users/{uid} dimuatkan dan digunakan.
  applied,

  /// Dokumen users/{uid} tiada (belum dicipta ATAU sudah dipadam) —
  /// TIDAK dicipta secara automatik oleh pull.
  notFound,

  /// Tiada pengguna Firebase (guest).
  unauthenticated,

  /// Sesi (UID/generation) berubah semasa read — hasil dibuang.
  staleSession,

  /// Padam akaun sedang berjalan / belum selesai.
  blocked,

  /// Write tempatan masih tertangguh — pull dilangkau supaya tak
  /// menimpa perubahan yang sedang dihantar.
  pendingWrites,

  /// Ralat rangkaian / Firestore.
  failed,
}

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

  // F3-C: marker persistent untuk deletion yang terhenti selepas
  // proses destructive bermula. UID disimpan supaya marker satu akaun
  // tidak menyekat akaun lain pada peranti yang sama.
  static const String _deletionIncompleteUidKey =
      'deletion_incomplete_uid';

  // F01: penanda bahawa request accountDeletionRequests/{uid} telah
  // dihantar. Client tidak boleh membaca request, jadi ini satu-satunya
  // cara panggilan seterusnya mengelak mencipta request kedua.
  static const String _deletionSubmittedUidKey =
      'deletion_request_submitted_uid';

  /// Mulakan pemantau auth-session SEKALI untuk setiap instance.
  /// Semua laluan yang menukar identiti Firebase (logout, login semula,
  /// tukar akaun, padam akaun) menaikkan generation tanpa bergantung
  /// kepada call site mengingati resetLocalSession(). Selamat dalam ujian
  /// unit tanpa Firebase (pemantau langsung dilangkau).
  UserModel() {
    _startAuthSessionListener();
  }

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

  /// Kemaskini info profil asas (nama/jantina/bio/avatar) SEKALIGUS —
  /// dipanggil dari EditProfileScreen. Encapsulate mutasi + save() +
  /// notifyListeners() dalam SATU method supaya caller luar class TAK
  /// PERLU (dan tak patut) sentuh field terus + panggil notifyListeners()
  /// sendiri (ChangeNotifier.notifyListeners ialah @protected).
  ///
  /// Urutan:
  ///   1. kemas kini medan tempatan (nama/bio dinormalkan — SATU bentuk
  ///      kanonik dgn ProfileService & rules);
  ///   2. simpan local + beritahu UI;
  ///   3. push ke users/{uid} dan TUNGGU (had masa 12s — offline tak
  ///      menggantung skrin; tulisan kekal beratur dalam SDK);
  ///   4. HANYA selepas cloud berjaya → segerakkan profil awam dengan
  ///      nilai users terkini.
  ///
  /// Pulangan:
  ///   • success(true)  — semua langkah yang BERKENAAN siap (guest / e-mel
  ///                      belum verify tiada profil awam → langkah 4 tak
  ///                      berkenaan).
  ///   • failure(...)   — perubahan LOCAL kekal tersimpan (state tak
  ///                      rosak); cloud/profil awam belum selesai. Ia
  ///                      disegerakkan lagi pada save() seterusnya atau
  ///                      bila HomePage dibuka.
  Future<Result<bool, SocialFailure>> updateProfile({
    required String name,
    required String gender,
    required String bio,
    String? avatarPath,
  }) async {
    _syncSessionIdentity();
    if (_writesBlocked) {
      return Result<bool, SocialFailure>.failure(
        SocialFailure.permissionDenied,
      );
    }

    this.name       = ProfileService.normalizeUserName(name);
    this.gender     = gender;
    this.bio        = ProfileService.cleanBio(bio);
    this.avatarPath = avatarPath;

    final Map<String, dynamic>? snapshot = await _persistLocal();
    if (snapshot == null) {
      // Sesi tamat semasa menyimpan — jangan tulis apa-apa lagi.
      return Result<bool, SocialFailure>.failure(SocialFailure.conflict);
    }
    notifyListeners();

    try {
      await _queuePush(snapshot).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      debugPrint('UserModel.updateProfile: push cloud belum siap (masa tamat).');
      return Result<bool, SocialFailure>.failure(_unavailableFailure());
    } catch (e) {
      debugPrint('UserModel.updateProfile: push cloud gagal: $e');
      return Result<bool, SocialFailure>.failure(socialFailureFromError(e));
    }

    final User? authUser = _currentAuthUser();
    if (authUser == null || !authUser.emailVerified) {
      return Result<bool, SocialFailure>.success(true);
    }
    return syncPublicProfile();
  }

  /// Segerakkan profil AWAM (profiles/{uid}: nama + bio sahaja) daripada
  /// data users/{uid} yang SUDAH SEGAR.
  ///
  /// Ditolak (tanpa menulis apa-apa) jika:
  ///   • tiada pengguna Firebase Auth                     → unauthenticated
  ///   • padam akaun sedang berjalan / belum selesai      → permissionDenied
  ///   • FirebaseAuth.currentUser.emailVerified == false   → permissionDenied
  ///     (dibaca dari Firebase Auth, BUKAN bool model tempatan)
  ///   • data users belum segar (belum pull/push berjaya
  ///     dalam sesi ini, atau push terakhir gagal)         → conflict
  ///
  /// Dijalankan dalam queue yang sama dgn write users/{uid}, jadi ia
  /// sentiasa selepas push yang sedang menunggu, dan rules (yang
  /// membandingkan profiles.name/bio dgn users.name/bio) melihat data
  /// yang sepadan. Sesi disemak semula sebelum menulis.
  Future<Result<bool, SocialFailure>> syncPublicProfile() async {
    _syncSessionIdentity();
    final User? authUser = _currentAuthUser();
    if (authUser == null) {
      return Result<bool, SocialFailure>.failure(
        SocialFailure.unauthenticated,
      );
    }
    if (_writesBlocked) {
      debugPrint('UserModel.syncPublicProfile: disekat (padam akaun).');
      return Result<bool, SocialFailure>.failure(
        SocialFailure.permissionDenied,
      );
    }
    if (!authUser.emailVerified) {
      debugPrint('UserModel.syncPublicProfile: e-mel belum disahkan.');
      return Result<bool, SocialFailure>.failure(
        SocialFailure.permissionDenied,
      );
    }
    if (!_cloudInSync) {
      debugPrint(
        'UserModel.syncPublicProfile: data users belum segar — dilangkau.',
      );
      return Result<bool, SocialFailure>.failure(SocialFailure.conflict);
    }

    final String uid = authUser.uid;
    final int gen = _sessionGeneration;
    // Nilai ditangkap SEKARANG (sama seperti snapshot write users yang
    // beratur sebelum ini) — bukan dibaca lewat semasa giliran tiba.
    final String n = name;
    final String b = bio;

    final Future<Result<bool, SocialFailure>> job =
        _pushChain.then<Result<bool, SocialFailure>>((_) async {
      if (_isStale(uid, gen) || !_cloudInSync) {
        debugPrint('UserModel.syncPublicProfile: sesi/data berubah — batal.');
        return Result<bool, SocialFailure>.failure(SocialFailure.conflict);
      }
      return ProfileService.instance.ensureMyProfile(
        name: n,
        bio: b,
        expectedUid: uid,
      );
    });
    // Queue TIDAK boleh mati kerana job ini.
    _pushChain = job.then<void>(
      (_) {},
      onError: (Object e) {
        debugPrint('UserModel.syncPublicProfile queue gagal: $e');
      },
    );
    return job;
  }

  // ── STORAGE (SharedPreferences local) ───────────────────────────
  Map<String, dynamic> _toMap() => <String, dynamic>{
    // Nama/bio SENTIASA dalam bentuk kanonik (lihat ProfileService).
    'name':                 ProfileService.normalizeUserName(name),
    'email':                email,
    'gender':               gender,
    'bio':                  ProfileService.cleanBio(bio),
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

  /// Medan yang HANYA dikawal server/rules. Update biasa TIDAK BOLEH
  /// menghantarnya. "Server/rules-controlled" ≠ server-authoritative untuk
  /// gamification: nilai XP/streak tempatan masih dikira client
  /// (belum ada backend dipercayai) — rules hanya menghalang client
  /// daripada menulisnya ke cloud.
  static const List<String> _protectedCloudFields = [
    'followersCount',
    'followingCount',
    'postsCount',
    'treeLevel',
    'totalPoints',
    'currentStreak',
    'longestStreak',
  ];

  static const List<String> _immutableUpdateFields = [
    'email',
    'authMethod',
  ];

  @visibleForTesting
  static Map<String, dynamic> buildCreatePayload(
    Map<String, dynamic> localMap,
  ) {
    return Map<String, dynamic>.from(localMap)
      ..['followersCount'] = 0
      ..['followingCount'] = 0
      ..['postsCount'] = 0
      ..['treeLevel'] = 1
      ..['totalPoints'] = 0
      ..['currentStreak'] = 0
      ..['longestStreak'] = 0;
  }

  @visibleForTesting
  static Map<String, dynamic> buildUpdatePayload(
    Map<String, dynamic> localMap,
  ) {
    return Map<String, dynamic>.from(localMap)
      ..removeWhere(
        (key, _) =>
            _protectedCloudFields.contains(key) ||
            _immutableUpdateFields.contains(key),
      );
  }

  // ── PARSER SELAMAT (data cloud/local rosak tak boleh crash / separuh apply)
  static String? _asString(Object? v) => v is String ? v : null;

  static int _asInt(Object? v, int fallback) {
    if (v is int) return v;
    if (v is num && v.isFinite) return v.toInt();
    return fallback;
  }

  static bool _asBool(Object? v, bool fallback) => v is bool ? v : fallback;

  static DateTime? _asDate(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  static Map<String, bool> _asBoolMap(Object? v) {
    final Map<String, bool> out = <String, bool>{};
    if (v is Map) {
      v.forEach((Object? k, Object? val) {
        if (k is String && val is bool) out[k] = val;
      });
    }
    return out;
  }

  void _applyMap(
    Map<String, dynamic> d, {
    bool preserveLocalGamification = false,
  }) {
    name           = ProfileService.normalizeUserName(_asString(d['name']) ?? '');
    email          = _asString(d['email'])      ?? '';
    gender         = _asString(d['gender'])     ?? 'Lelaki';
    bio            = ProfileService.cleanBio(_asString(d['bio']) ?? '');
    avatarPath     = _asString(d['avatarPath']);
    authMethod     = _asString(d['authMethod']) ?? 'Guest';
    hijriDOB       = _asString(d['hijriDOB']);
    final DateTime? bd = _asDate(d['birthdate']);
    if (bd != null) birthdate = bd;
    followersCount = _asInt(d['followersCount'], 0).clamp(0, 1 << 31).toInt();
    followingCount = _asInt(d['followingCount'], 0).clamp(0, 1 << 31).toInt();
    postsCount     = _asInt(d['postsCount'], 0).clamp(0, 1 << 31).toInt();

    if (!preserveLocalGamification) {
      treeLevel     = _asInt(d['treeLevel'], 1).clamp(1, 1 << 31).toInt();
      totalPoints   = _asInt(d['totalPoints'], 0).clamp(0, 1 << 31).toInt();
      currentStreak = _asInt(d['currentStreak'], 0).clamp(0, 1 << 31).toInt();
      longestStreak = _asInt(d['longestStreak'], 0).clamp(0, 1 << 31).toInt();
    }

    final DateTime? lad = _asDate(d['lastActiveDate']);
    if (lad != null) lastActiveDate = lad;
    lastLogResetDate      = _asString(d['lastLogResetDate']);
    dailyFardhuLog        = _asBoolMap(d['dailyFardhuLog']);
    dailyAmalanLog        = _asBoolMap(d['dailyAmalanLog']);
    _zikirDoneToday       = _asBool(d['zikirDoneToday'], false);
    adhanModeIndex        = _asInt(d['adhanModeIndex'], 1);
    isFajrAlarmEnabled    = _asBool(d['isFajrAlarmEnabled'], true);
    isDhuhrAlarmEnabled   = _asBool(d['isDhuhrAlarmEnabled'], true);
    isAsrAlarmEnabled     = _asBool(d['isAsrAlarmEnabled'], true);
    isMaghribAlarmEnabled = _asBool(d['isMaghribAlarmEnabled'], true);
    isIshaAlarmEnabled    = _asBool(d['isIshaAlarmEnabled'], true);
    zikirReminderEnabled  = _asBool(d['zikirReminderEnabled'], true);
    themeMode             = _asString(d['themeMode']) ?? 'auto';
  }

  void _normalizeIdentityFields() {
    name = ProfileService.normalizeUserName(name);
    bio  = ProfileService.cleanBio(bio);
  }

  // ═══════════════════════════════════════════════════════════════
  // SESI + QUEUE WRITE
  // ═══════════════════════════════════════════════════════════════
  // UID SAHAJA tak cukup: UID yang sama boleh log masuk semula. Setiap
  // write cloud menangkap (uid, _sessionGeneration) semasa dimasukkan
  // ke queue, dan mengesahkan KEDUA-DUANYA sebelum menulis. Generation
  // bertambah pada: SETIAP peralihan identiti authStateChanges() (logout,
  // login semula termasuk UID yang sama, tukar akaun — dipantau
  // berpusat, tak bergantung pada call site), padam akaun,
  // resetLocalSession(). Write lama yang tiba selepas itu menjadi
  // tak berbahaya (dilangkau).
  int     _sessionGeneration = 0;
  String? _sessionUid;

  /// Langganan authStateChanges() — dibuat sekali, dibatalkan dalam
  /// dispose(). Pemantau ini HANYA mengubah medan sesi (generation,
  /// _sessionUid, flag sync); ia tidak push, tidak pull, tidak
  /// notifyListeners().
  StreamSubscription<User?>? _authSub;

  /// false sehingga event PERTAMA authStateChanges() diterima. Event
  /// pertama ialah keadaan semasa (bukan peralihan) — lihat
  /// [_onAuthStateEvent].
  bool _authBaselineSeen = false;

  /// true = tiada write cloud/profil baharu dibenarkan (permintaan padam
  /// akaun sedang dihantar ATAU sudah dihantar/tidak pasti dan belum selesai).
  bool _writesBlocked = false;
  bool _deletionInProgress = false;

  /// F01/D2: permintaan padam akaun masih TERTUNGGAK atau hasilnya belum
  /// pasti; write client mesti kekal disekat. TIDAK bermaksud client telah
  /// memadam sebahagian data.
  bool _deletionIncomplete = false;

  /// D2: cache dalam memori bagi marker persisten (UID yang padam akaunnya
  /// tertunggak) dan penanda "request dihantar". Dimuat oleh load() supaya
  /// _adoptSessionIdentity() (segerak) boleh menguatkuasakannya.
  String? _deletionMarkerUid;
  String? _deletionSubmittedUid;

  /// users/{uid} di cloud dianggap sepadan dgn nama/bio tempatan
  /// (selepas pull/push berjaya dalam sesi ini). Syarat menyegerakkan
  /// profil awam.
  bool _cloudInSync = false;

  /// Generation di mana users/{uid} pernah terbukti wujud. Kalau kemudian
  /// hilang (dipadam dari peranti lain), JANGAN cipta semula.
  int _docSeenGeneration = -1;

  Future<void> _pushChain = Future<void>.value();

  /// Laporan pembersihan lama (untuk UI/diagnostik). F01: deleteAccount()
  /// tidak lagi memadam apa-apa di client, jadi medan ini tidak diisi lagi;
  /// dikekalkan supaya API awam tidak berubah.
  ProfileCleanupReport? lastDeletionCleanupReport;

  /// Seperti [lastDeletionCleanupReport]: tidak diisi lagi oleh F01.
  /// Dikosongkan oleh resetLocalSession().
  SocialCleanupReport? lastSocialCleanupReport;

  /// Had masa menghantar request padam akaun dalam deleteAccount(). Timeout
  /// hanya berhenti menunggu: hasil request menjadi TIDAK PASTI, jadi marker
  /// dan sekatan write kekal (fail-closed) dan ralat dilempar.
  static const Duration _destructiveOpTimeout = Duration(seconds: 30);

  /// true = padam akaun sedang berjalan.
  bool get isDeletionInProgress => _deletionInProgress;

  /// true = permintaan padam akaun tertunggak / hasil belum pasti. Write
  /// cloud/profil disekat. Log keluar TIDAK membuang sekatan ini.
  bool get isDeletionIncomplete => _deletionIncomplete;

  /// D2: UID semasa mempunyai marker padam akaun yang tertunggak.
  bool get hasOutstandingDeletionMarker {
    final String? uid = _uidOrNull() ?? _sessionUid;
    return uid != null && uid == _deletionMarkerUid;
  }

  @visibleForTesting
  bool get debugWritesBlocked => _writesBlocked;

  @visibleForTesting
  String? get debugDeletionMarkerUid => _deletionMarkerUid;

  @visibleForTesting
  String? get debugDeletionSubmittedUid => _deletionSubmittedUid;

  /// Hanya untuk ujian unit tanpa Firebase.
  @visibleForTesting
  static String? Function()? debugUidOverride;

  /// Hanya untuk ujian: simulasi event authStateChanges().
  @visibleForTesting
  void debugHandleAuthUid(String? uid) => _handleAuthUid(uid);

  static String? _uidOrNull() {
    final String? Function()? override = debugUidOverride;
    if (override != null) return override();
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      // Firebase belum diinisialisasi (mis. ujian unit tanpa Firebase)
      // → layan sebagai guest.
      return null;
    }
  }

  static User? _currentAuthUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static SocialFailure _unavailableFailure() => socialFailureFromError(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

  /// Kesan login / tukar akaun: bila UID Firebase berbeza daripada UID
  /// sesi yang direkod, mulakan sesi BAHARU (generation++).
  void _syncSessionIdentity() => _adoptSessionIdentity(_uidOrNull());

  /// Tukar identiti sesi kepada [uid] jika berbeza daripada yang direkod:
  /// generation++ dan buang status sync. Dikongsi oleh
  /// [_syncSessionIdentity] (baca currentUser secara malas) dan
  /// [_onAuthStateEvent] (uid daripada event auth).
  void _adoptSessionIdentity(String? uid) {
    if (uid == _sessionUid) {
      // D2: UID sama TIDAK boleh memintas penguatkuasaan marker.
      _enforceDeletionMarker(uid);
      return;
    }
    _sessionUid = uid;
    _sessionGeneration++;
    _cloudInSync = false;
    _docSeenGeneration = -1;
    if (!_deletionInProgress) {
      _writesBlocked = false;
      _deletionIncomplete = false;
    }
    // D2: UID yang sama dengan marker tertunggak kekal beku selepas
    // log keluar/masuk. UID lain TIDAK mewarisi sekatan itu.
    _enforceDeletionMarker(uid);
  }

  /// D2: jika [uid] ialah UID marker padam akaun yang tertunggak, sekat
  /// write. Segerak (guna cache memori `_deletionMarkerUid` yang dimuat oleh
  /// load()). Tidak pernah membuang marker dan tidak pernah melonggarkan
  /// sekatan — hanya menguatkuasakan.
  void _enforceDeletionMarker(String? uid) {
    if (uid != null && uid == _deletionMarkerUid) {
      _deletionIncomplete = true;
      _writesBlocked = true;
    }
  }

  void _startAuthSessionListener() {
    if (_authSub != null) return; // tiada listener berganda
    try {
      _authSub = FirebaseAuth.instance.authStateChanges().listen(
        _onAuthStateEvent,
        onError: (Object e) {
          debugPrint('UserModel.authStateChanges ralat: $e');
        },
      );
    } catch (e) {
      // Firebase belum diinisialisasi (mis. ujian unit) → layan sebagai
      // guest; tiada pemantau.
      debugPrint('UserModel: pemantau auth dilangkau: $e');
    }
  }

  /// Setiap peralihan identiti auth yang benar-benar berlaku menaikkan
  /// generation, walaupun kod pemanggil terlupa resetLocalSession():
  ///
  ///   A → logout            : event null  → generation++ (write A lama batal)
  ///   logout → A semula     : event A     → generation++ (write A lama TETAP
  ///                           batal — UID sama tidak lagi mencukupi)
  ///   A → B                 : event B     → generation++
  ///
  /// Guna uid daripada EVENT (bukan currentUser) supaya login semula yang
  /// pantas tidak menyembunyikan event logout.
  ///
  /// Event PERTAMA ialah keadaan permulaan, bukan peralihan: jika belum ada
  /// identiti direkod (`_sessionUid == null`) ia hanya MENGAMBIL identiti
  /// tersebut tanpa invalidate. Aman kerana _queuePush() sentiasa
  /// mengambil identiti (melalui _syncSessionIdentity) sebelum menangkap
  /// write, jadi tiada write lapuk boleh wujud pada ketika itu. Jika
  /// identiti sudah direkod tetapi event pertama berbeza, itu peralihan
  /// sebenar dan diproses seperti biasa.
  ///
  /// Jika ia berlumba dengan _syncSessionIdentity() (yang sudah mengambil
  /// uid yang sama), tiada apa berubah. Kes berlumba yang jarang berlaku
  /// menghasilkan generation++ tambahan — arah selamat (write dilangkau,
  /// data local kekal, push seterusnya menghantar semula).
  void _onAuthStateEvent(User? user) => _handleAuthUid(user?.uid);

  void _handleAuthUid(String? uid) {
    final bool isBaseline = !_authBaselineSeen;
    _authBaselineSeen = true;

    // D2: kuatkuasa marker SEBELUM sebarang early return (event baseline
    // dan UID sama turut dilindungi).
    _enforceDeletionMarker(uid);

    if (uid == _sessionUid) return;

    if (isBaseline && _sessionUid == null) {
      _sessionUid = uid;
      return;
    }
    _adoptSessionIdentity(uid);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    super.dispose();
  }

  void _invalidateSession() {
    _sessionGeneration++;
    _cloudInSync = false;
    _docSeenGeneration = -1;
  }

  @visibleForTesting
  static bool isStaleSession(
    String capturedUid,
    String? currentUid, {
    int? capturedGeneration,
    int? currentGeneration,
  }) {
    if (currentUid != capturedUid) return true;
    if (capturedGeneration != null &&
        currentGeneration != null &&
        capturedGeneration != currentGeneration) {
      return true;
    }
    return false;
  }

  bool _isStale(String uid, int gen) =>
      _writesBlocked ||
      isStaleSession(
        uid,
        _uidOrNull(),
        capturedGeneration: gen,
        currentGeneration: _sessionGeneration,
      );

  /// Tunggu queue kosong, dengan had masa (write offline boleh
  /// tergantung sehingga rangkaian pulih). true = kosong.
  Future<bool> _drainPushChain(Duration timeout) async {
    try {
      await _pushChain.timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  /// Simpan local SAHAJA (guard generation). null = sesi tamat semasa
  /// menyimpan, tiada apa-apa ditulis.
  Future<Map<String, dynamic>?> _persistLocal() async {
    _syncSessionIdentity();
    _normalizeIdentityFields();
    final int gen = _sessionGeneration;
    final Map<String, dynamic> map = _toMap();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // logout / padam akaun / reset berlaku semasa await → JANGAN tulis
    // semula data lama ke prefs yang baru dibersihkan.
    if (gen != _sessionGeneration) return null;
    await prefs.setString('user_data', json.encode(map));
    return map;
  }

  /// Simpan local (SharedPreferences) — SENTIASA berjalan & sentiasa
  /// disiapkan (await-able) macam asal. Push ke cloud pula "fire and
  /// forget" (tak di-await) — supaya tiap save() (dipanggil sangat
  /// kerap: addPoints, toggle amalan, dll) tak jadi perlahan/block UI
  /// sebab tunggu network. Kegagalan push DILOG oleh queue (tak menutup
  /// queue) dan menandakan data cloud "belum segar".
  Future<void> save() async {
    final Map<String, dynamic>? map = await _persistLocal();
    if (map == null) return;
    unawaited(_queuePush(map));
  }

  /// Seperti save(), tetapi tunggu sehingga write cloud untuk snapshot ini
  /// selesai. Guna hanya pada flow kritikal seperti onboarding/birthdate
  /// yang perlu memastikan dokumen users/{uid} sudah wujud sebelum teruskan.
  /// Melempar jika write gagal, jika sesi tamat semasa menyimpan, atau
  /// jika write disekat (padam akaun).
  ///
  /// [timeout] pilihan: had menunggu (TimeoutException). Tulisan tidak
  /// dibatalkan — ia kekal beratur.
  Future<void> saveAndWaitForCloud({Duration? timeout}) async {
    _syncSessionIdentity();
    if (_writesBlocked) {
      throw StateError(
        'Penyimpanan cloud disekat: padam akaun sedang/belum selesai.',
      );
    }
    final Map<String, dynamic>? map = await _persistLocal();
    if (map == null) {
      throw StateError('Sesi berubah semasa menyimpan — tiada apa dihantar.');
    }
    Future<void> write = _queuePush(map);
    if (timeout != null) write = write.timeout(timeout);
    await write;
  }

  /// Masukkan snapshot ke queue serial. Uid + generation ditangkap SEKARANG.
  Future<void> _queuePush(Map<String, dynamic> map) {
    _syncSessionIdentity();
    final String? uid = _uidOrNull();
    if (uid == null || _writesBlocked) return Future<void>.value();
    final int gen = _sessionGeneration;

    final Future<void> write =
        _pushChain.then((_) => _doPushToCloud(uid, gen, map));

    // Queue kekal hidup walaupun write ini gagal; kegagalan dilog dan
    // (untuk yang menunggu `write`) tetap dilempar kepada caller.
    _pushChain = write.catchError((Object e) {
      debugPrint('UserModel push queue gagal: $e');
    });
    return write;
  }

  Future<void> _doPushToCloud(
    String uid,
    int gen,
    Map<String, dynamic> map,
  ) async {
    if (_isStale(uid, gen)) {
      debugPrint(
        'UserModel._pushToCloud dilangkau — sesi tamat/berubah '
        '(logout, tukar akaun, padam akaun atau login semula).',
      );
      return;
    }

    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await docRef.update(buildUpdatePayload(map));
      if (!_isStale(uid, gen)) {
        _cloudInSync = true;
        _docSeenGeneration = gen;
      }
      return;
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') {
        debugPrint('UserModel._pushToCloud update gagal (offline?): $e');
        if (!_isStale(uid, gen)) _cloudInSync = false;
        rethrow;
      }
      // not-found → teruskan ke logik cipta di bawah.
    }

    // ── Dokumen users/{uid} tiada ────────────────────────────────
    // Ini ialah laluan "hidupkan semula" yang berbahaya: JANGAN cipta
    // kalau sesi sudah tamat, kalau dokumen pernah wujud dalam sesi ini
    // (bermakna ia dipadam), atau kalau akaun Auth sudah tiada.
    if (_isStale(uid, gen)) return;
    if (_docSeenGeneration == gen) {
      _cloudInSync = false;
      throw StateError(
        'users/$uid hilang selepas pernah wujud — TIDAK dicipta semula.',
      );
    }
    if (!await _authAccountStillExists()) {
      _cloudInSync = false;
      throw StateError(
        'Akaun Firebase Auth sudah tiada — users/$uid TIDAK dicipta semula.',
      );
    }
    if (_isStale(uid, gen)) return;

    try {
      await docRef.set(buildCreatePayload(map));
      if (!_isStale(uid, gen)) {
        _cloudInSync = true;
        _docSeenGeneration = gen;
      }
    } catch (e) {
      debugPrint('UserModel._pushToCloud create gagal (offline?): $e');
      if (!_isStale(uid, gen)) _cloudInSync = false;
      rethrow;
    }
  }

  /// Sahkan akaun Auth masih wujud di server (reload). false HANYA untuk
  /// kod muktamad (akaun dipadam/dilumpuhkan/token ditarik balik); ralat
  /// rangkaian dilempar semula supaya push gagal dgn punca sebenar.
  static Future<bool> _authAccountStillExists() async {
    final User? u = _currentAuthUser();
    if (u == null) return false;
    try {
      await u.reload();
      return _currentAuthUser() != null;
    } on FirebaseAuthException catch (e) {
      const Set<String> gone = <String>{
        'user-not-found',
        'user-disabled',
        'user-token-expired',
        'invalid-user-token',
      };
      if (gone.contains(e.code)) {
        debugPrint('UserModel: akaun Auth tiada (${e.code}).');
        return false;
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT / RESET SESI
  // ═══════════════════════════════════════════════════════════════

  /// Log keluar penuh: invalidate generation DAHULU (write yang beratur
  /// jadi tak berbahaya), kemudian signOut, kemudian reset sesi local.
  /// Disyorkan sebagai ganti signOut() + resetLocalSession() berasingan.
  /// (Tidak menunggu queue — write offline yang tergantung tak boleh
  /// menghalang logout.)
  Future<void> signOutAndReset() async {
    // D2: tentukan SEBELUM signOut (selepas itu currentUser == null).
    final bool deletionOutstanding = hasOutstandingDeletionMarker;
    _invalidateSession();
    await FirebaseAuth.instance.signOut();
    await resetLocalSession(preserveDeletionMarker: deletionOutstanding);
  }

  /// Panggil semasa LOGOUT SAHAJA (atau sebagai langkah akhir padam
  /// akaun). Reset semua field ke default di memori + kosongkan cache
  /// local (SharedPreferences) — TANPA push apa-apa ke cloud. Logout ≠
  /// padam akaun: dokumen Firestore pengguna kekal utuh; ni cuma
  /// bersihkan sesi peranti ni supaya akaun/guest seterusnya tak
  /// warisi data lama.
  ///
  /// Fungsi ni sengaja TAK PERNAH panggil save()/_pushToCloud(). Langkah
  /// PERTAMA (sebelum sebarang await) ialah invalidate generation, jadi
  /// walaupun ia dipanggil selepas signOut() oleh kod lama, semua write
  /// yang beratur sebelum ini menjadi tak berbahaya.
  Future<void> _persistDeletionIncompleteMarker(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deletionIncompleteUidKey, uid);
    _deletionMarkerUid = uid;
  }

  Future<void> _persistDeletionSubmittedMarker(String uid) async {
    // Cache DAHULU: walaupun penulisan prefs gagal, proses ini sudah tahu
    // request telah dicipta dan tidak akan mencipta yang kedua.
    _deletionSubmittedUid = uid;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deletionSubmittedUidKey, uid);
  }

  // Disimpan untuk laluan pengesahan siap (D1) yang BELUM wujud. Tiada
  // pemanggil sekarang — marker TIDAK dibuang secara automatik oleh F01/D2.
  // ignore: unused_element
  Future<void> _clearDeletionIncompleteMarker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deletionIncompleteUidKey);
    await prefs.remove(_deletionSubmittedUidKey);
    _deletionMarkerUid = null;
    _deletionSubmittedUid = null;
  }

  Future<void> _restoreDeletionIncompleteMarker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? markerUid = prefs.getString(_deletionIncompleteUidKey);
    final String? submittedUid = prefs.getString(_deletionSubmittedUidKey);
    // Cache marker (juga untuk UID lain — ia kekal sehingga ada laluan
    // pembersihan sah). Sekatan hanya untuk UID semasa yang sama.
    _deletionMarkerUid = markerUid;
    _deletionSubmittedUid = submittedUid;

    // Constructor sudah memulakan listener Auth sebelum restore ini siap.
    // Kuatkuasa untuk UID semasa DAN UID yang mungkin sudah diambil oleh
    // listener supaya perlumbaan tidak melepaskan UID bermarker. Auth yang
    // null sementara TIDAK membuang marker.
    final String? currentUid = _uidOrNull();
    _enforceDeletionMarker(currentUid);
    _enforceDeletionMarker(_sessionUid);
    if (_writesBlocked) {
      debugPrint(
        'UserModel: deletion tertunggak dipulihkan untuk UID semasa.',
      );
    }
  }

  /// F3-E: Bersihkan fail avatar local yang dijana oleh iHijrah.
  ///
  /// Semua avatar iHijrah disimpan dengan nama "avatar_<timestamp>.<ext>".
  /// Helper ini hanya menyentuh regular file dengan format nama
  /// "avatar_<timestamp>.<extension>". Fail/directory lain dalam
  /// ApplicationDocumentsDirectory tidak disentuh.
  ///
  /// F01: BUKAN lagi dipanggil oleh deleteAccount(). Disimpan untuk laluan
  /// pengesahan siap (D1) yang belum wujud; jangan panggil sebelum siap
  /// disahkan.
  // ignore: unused_element
  Future<void> _cleanupLocalAvatarFiles() async {
    try {
      final Directory docsDir = await getApplicationDocumentsDirectory();

      if (!await docsDir.exists()) return;

      await for (final FileSystemEntity entity in docsDir.list(
        followLinks: false,
      )) {
        if (entity is! File) continue;

        final String name = entity.uri.pathSegments.isNotEmpty
            ? entity.uri.pathSegments.last
            : '';

        // Hanya fail yang dijana oleh picker iHijrah:
        // avatar_<timestamp>.<extension>
        final Match? match = RegExp(
          r'^avatar_[0-9]+\.[A-Za-z0-9]+$',
        ).firstMatch(name);

        if (match == null) continue;

        try {
          await entity.delete();
        } catch (e) {
          debugPrint(
            'UserModel: gagal padam avatar local "$name": $e',
          );
        }
      }
    } catch (e) {
      // Local cleanup tidak boleh menggagalkan reset sesi.
      debugPrint('UserModel: avatar cleanup gagal: $e');
    }
  }

  ///
  /// D2 — [preserveDeletionMarker] = true (logout semasa padam akaun
  /// tertunggak): data sesi biasa TETAP dibersihkan, tetapi sekatan write
  /// (`_writesBlocked`, `_deletionIncomplete`) dan marker persisten kekal.
  /// Reset TIDAK PERNAH membuang marker persisten: marker satu akaun tidak
  /// boleh terpadam kerana akaun lain log keluar; hanya laluan pengesahan
  /// siap (D1, belum ada) yang boleh membuangnya.
  Future<void> resetLocalSession({bool preserveDeletionMarker = false}) async {
    _sessionGeneration++;
    _sessionUid = _uidOrNull();
    _cloudInSync = false;
    _docSeenGeneration = -1;
    _deletionInProgress = false;
    if (!preserveDeletionMarker) {
      _writesBlocked = false;
      _deletionIncomplete = false;
    }
    lastDeletionCleanupReport = null;
    lastSocialCleanupReport = null;

    // Reset SETIAP field secara eksplisit di sini — SENGAJA tidak
    // bergantung kepada _applyMap(const {}). Sebab: _applyMap guna
    // corak "if (x != null) field = ..." untuk birthdate &
    // lastActiveDate, jadi bila map input kosong, field tu terus TAK
    // DISENTUH (bukan reset ke null macam field lain). Ini punca bug
    // asal — nilai lama boleh terbawa ke sesi/akaun seterusnya pada
    // peranti sama.
    name                  = '';
    birthdate             = null;
    hijriDOB              = null;
    avatarPath            = null;
    gender                = 'Lelaki';
    email                 = '';
    authMethod            = 'Guest';
    bio                   = '';
    followersCount        = 0;
    followingCount        = 0;
    postsCount            = 0;
    treeLevel             = 1;
    totalPoints           = 0;
    currentStreak         = 0;
    longestStreak         = 0;
    lastActiveDate        = null;
    dailyFardhuLog        = {};
    dailyAmalanLog        = {};
    lastLogResetDate      = null;
    selawatCountToday     = 0;
    _zikirDoneToday       = false;
    adhanModeIndex        = 1;
    isFajrAlarmEnabled    = true;
    isDhuhrAlarmEnabled   = true;
    isAsrAlarmEnabled     = true;
    isMaghribAlarmEnabled = true;
    isIshaAlarmEnabled    = true;
    zikirReminderEnabled  = true;
    themeMode             = 'auto';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('birthday_state');
    await prefs.remove('birthday_note');
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // PADAM AKAUN — F01 + D2: CLIENT = PENGHANTAR REQUEST SAHAJA
  // ═══════════════════════════════════════════════════════════════
  /// Menghantar permintaan padam akaun kepada backend F3-G yang sedia ada
  /// (`accountDeletionRequests/{uid}`) dan KEKAL dibekukan. Pulangan biasa
  /// bermaksud "permintaan DIHANTAR" — BUKAN "akaun telah dipadam".
  ///
  /// Urutan:
  ///   1. Reauthenticate — WAJIB berjaya dulu (rules memerlukan
  ///      `recentlyAuthenticated()`). Gagal → tiada apa berubah.
  ///   2. Bekukan write client + invalidate generation sesi.
  ///   3. Simpan marker niat PERSISTEN (`deletion_incomplete_uid`).
  ///   4. Kosongkan queue push (had 8s).
  ///   5. Cipta `accountDeletionRequests/{uid}` dengan TEPAT
  ///      {uid, status: 'pending', createdAt: serverTimestamp}. Dokumen ini
  ///      mengaktifkan W3 write-freeze di pelayan dan mencetuskan F3-G.
  ///   6. Simpan penanda "dihantar" dan KEKAL beku. Selesai.
  ///
  /// FAIL-CLOSED: sebaik sahaja marker niat berjaya ditulis (langkah 3),
  /// TIADA ralat boleh membuang marker atau membuka semula write. Khususnya
  /// `permission-denied` BUKAN bukti request tidak wujud (create atas
  /// dokumen sedia ada ialah update, yang ditolak rules). Hasil tidak pasti
  /// = kekal beku; ralat dilempar semula apa adanya.
  ///
  /// Panggilan seterusnya apabila UID ini sudah ada penanda "dihantar":
  /// tiada reauthentication, tiada request kedua, tiada pembukaan beku.
  ///
  /// Client TIDAK memadam apa-apa di sini. Backend memiliki posts, social,
  /// follows, profil, users/{uid}, verify dan Firebase Auth. Pengesanan siap
  /// (D1) BELUM dilaksanakan — tiada pembersihan/reset tempatan di sini.
  ///
  /// Throws [FirebaseAuthException] bila reauth gagal.
  /// Throws ralat Firestore/timeout sebenar bila request gagal/tidak pasti
  /// (ketika itu [isDeletionIncomplete] == true dan write kekal disekat).
  Future<void> deleteAccount({required String password}) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('Tiada pengguna log masuk.');
    }
    if (_deletionInProgress) {
      throw StateError('Padam akaun sedang berjalan.');
    }
    final String uid = currentUser.uid;
    _syncSessionIdentity();

    // Sudah dihantar: kekal beku. Tiada reauth, tiada request kedua.
    if (_deletionMarkerUid == uid && _deletionSubmittedUid == uid) {
      _enforceDeletionMarker(uid);
      return;
    }

    final String? userEmail = currentUser.email;
    if (userEmail == null || userEmail.isEmpty) {
      throw StateError('Akaun ini tiada e-mel berdaftar untuk reauthentication.');
    }

    // ── 1. REAUTHENTICATE ───────────────────────────────────────────
    final AuthCredential credential = EmailAuthProvider.credential(
      email: userEmail,
      password: password,
    );
    await currentUser.reauthenticateWithCredential(credential);

    // ── 2. BEKUKAN WRITE + INVALIDATE SESI ──────────────────────────
    _deletionInProgress = true;
    _writesBlocked = true;
    _invalidateSession();

    try {
      // ── 3. MARKER NIAT PERSISTEN ──────────────────────────────────
      try {
        await _persistDeletionIncompleteMarker(uid);
      } catch (_) {
        // Marker TIDAK tertulis dan request belum dicipta: tiada apa di
        // pelayan. Selamat memulihkan write (sama seperti reauth gagal).
        _writesBlocked = false;
        _deletionIncomplete = false;
        unawaited(_queuePush(_toMap()));
        rethrow;
      }

      // Dari sini FAIL-CLOSED: marker + beku tidak dilonggarkan lagi.
      _deletionIncomplete = true;

      // ── 4. KOSONGKAN QUEUE PUSH ───────────────────────────────────
      // Hasil diabaikan dengan sengaja: write tertangguh menjadi tak
      // berbahaya kerana generation sudah berubah.
      await _drainPushChain(const Duration(seconds: 8));

      // ── 5. CIPTA REQUEST ──────────────────────────────────────────
      await FirebaseFirestore.instance
          .collection('accountDeletionRequests')
          .doc(uid)
          .set(<String, dynamic>{
            'uid': uid,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(_destructiveOpTimeout);

      // ── 6. PENANDA "DIHANTAR" — kekal beku ────────────────────────
      await _persistDeletionSubmittedMarker(uid);
    } finally {
      _deletionInProgress = false;
    }
  }

  static Future<UserModel> load() async {
    final UserModel m = UserModel();
    await m._restoreDeletionIncompleteMarker();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('user_data');
    if (raw == null) return m;
    try {
      final Object? decoded = json.decode(raw);
      if (decoded is Map) {
        m._applyMap(Map<String, dynamic>.from(decoded));
      } else {
        debugPrint('UserModel.load: data local bukan Map — guna default.');
      }
    } catch (e) {
      // Cache local rosak tidak boleh menjatuhkan permulaan app.
      debugPrint('UserModel.load: data local rosak, guna default: $e');
    }
    return m;
  }

  // ── STORAGE (Firebase — backup, dipulih lepas reinstall) ────────

  /// Pulangkan hasil terperinci. Panggil selepas login berjaya (AuthScreen)
  /// dan pada permulaan HomePage — SEBELUM menyegerakkan profil awam.
  ///
  ///  • menunggu write yang sedang beratur siap dulu (had 10s) supaya
  ///    pull tak menimpa perubahan tempatan yang sedang dihantar; kalau
  ///    tak sempat → [CloudPullResult.pendingWrites] dan TIADA apa diubah;
  ///  • menangkap UID + generation; jika sesi berubah semasa read, hasil
  ///    DIBUANG (tidak dipakai kepada sesi baharu);
  ///  • data cloud override local (kecuali gamification tempatan —
  ///    `preserveLocalGamification`, yang BUKAN bermakna gamification
  ///    server-authoritative; ia belum).
  Future<CloudPullResult> pullFromCloudDetailed() async {
    _syncSessionIdentity();
    if (_writesBlocked) return CloudPullResult.blocked;
    final String? uid = _uidOrNull();
    if (uid == null) return CloudPullResult.unauthenticated;
    final int gen = _sessionGeneration;

    if (!await _drainPushChain(const Duration(seconds: 10))) {
      debugPrint('UserModel.pullFromCloud: write tertangguh — pull dilangkau.');
      return CloudPullResult.pendingWrites;
    }
    if (_isStale(uid, gen)) return CloudPullResult.staleSession;

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (_isStale(uid, gen)) return CloudPullResult.staleSession;

      final Map<String, dynamic>? data = doc.data();
      if (!doc.exists || data == null) {
        _cloudInSync = false;
        return CloudPullResult.notFound;
      }

      _applyMap(data, preserveLocalGamification: true);
      _cloudInSync = true;
      _docSeenGeneration = gen;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_isStale(uid, gen)) return CloudPullResult.staleSession;
      await prefs.setString('user_data', json.encode(_toMap()));
      notifyListeners();
      return CloudPullResult.applied;
    } catch (e) {
      debugPrint('UserModel.pullFromCloud gagal: $e');
      return CloudPullResult.failed;
    }
  }

  /// Panggil SEKALI lepas login berjaya (dari AuthScreen) — bukan
  /// automatik berulang, elak overwrite tak sengaja data local yg
  /// mungkin lagi baru. Pulangkan true kalau dokumen cloud wujud &
  /// berjaya dimuatkan (data cloud override local + di-cache semula).
  /// Guna [pullFromCloudDetailed] untuk tahu SEBAB kalau false.
  Future<bool> pullFromCloud() async =>
      (await pullFromCloudDetailed()) == CloudPullResult.applied;
}
