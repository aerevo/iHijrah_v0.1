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

  /// Kemaskini info profil asas (nama/jantina/bio/avatar) SEKALIGUS —
  /// dipanggil dari EditProfileScreen. Encapsulate mutasi + save() +
  /// notifyListeners() dalam SATU method supaya caller luar class TAK
  /// PERLU (dan tak patut) sentuh field terus + panggil notifyListeners()
  /// sendiri. notifyListeners() pada ChangeNotifier ditanda @protected
  /// + @visibleForTesting — panggilan terus dari luar class (macam
  /// EditProfileScreen buat sebelum ni) adalah invalid usage yang
  /// analyzer flag (invalid_use_of_protected_member +
  /// invalid_use_of_visible_for_testing_member).
  Future<void> updateProfile({
    required String name,
    required String gender,
    required String bio,
    String? avatarPath,
  }) async {
    this.name       = name;
    this.gender      = gender;
    this.bio         = bio;
    this.avatarPath  = avatarPath;
    await save();
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

  void _applyMap(
    Map<String, dynamic> d, {
    bool preserveLocalGamification = false,
  }) {
    name           = d['name']       ?? '';
    email          = d['email']      ?? '';
    gender         = d['gender']     ?? 'Lelaki';
    bio            = d['bio']        ?? '';
    avatarPath     = d['avatarPath'];
    authMethod     = d['authMethod'] ?? 'Guest';
    hijriDOB       = d['hijriDOB'];
    if (d['birthdate'] != null) birthdate = DateTime.parse(d['birthdate']);
    followersCount = d['followersCount'] ?? 0;
    followingCount = d['followingCount'] ?? 0;
    postsCount     = d['postsCount'] ?? 0;

    if (!preserveLocalGamification) {
      treeLevel     = d['treeLevel'] ?? 1;
      totalPoints   = d['totalPoints'] ?? 0;
      currentStreak = d['currentStreak'] ?? 0;
      longestStreak = d['longestStreak'] ?? 0;
    }

    if (d['lastActiveDate'] != null) {
      lastActiveDate = DateTime.parse(d['lastActiveDate']);
    }
    lastLogResetDate     = d['lastLogResetDate'];
    dailyFardhuLog       = Map<String, bool>.from(d['dailyFardhuLog'] ?? {});
    dailyAmalanLog       = Map<String, bool>.from(d['dailyAmalanLog'] ?? {});
    _zikirDoneToday      = d['zikirDoneToday'] ?? false;
    adhanModeIndex       = d['adhanModeIndex'] ?? 1;
    isFajrAlarmEnabled   = d['isFajrAlarmEnabled'] ?? true;
    isDhuhrAlarmEnabled  = d['isDhuhrAlarmEnabled'] ?? true;
    isAsrAlarmEnabled    = d['isAsrAlarmEnabled'] ?? true;
    isMaghribAlarmEnabled = d['isMaghribAlarmEnabled'] ?? true;
    isIshaAlarmEnabled   = d['isIshaAlarmEnabled'] ?? true;
    zikirReminderEnabled = d['zikirReminderEnabled'] ?? true;
    themeMode             = d['themeMode'] ?? 'auto';
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

  /// Seperti save(), tetapi tunggu sehingga write cloud untuk snapshot ini
  /// selesai. Guna hanya pada flow kritikal seperti onboarding/birthdate
  /// yang perlu memastikan dokumen users/{uid} sudah wujud sebelum teruskan.
  Future<void> saveAndWaitForCloud() async {
    final map = _toMap();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(map));

    final String? uid = _uidOrNull();
    if (uid == null) return;

    // Caller kritikal boleh tahu jika write cloud sebenar gagal.
    final write = _pushChain.then((_) => _doPushToCloud(uid, map));

    // Queue utama tetap hidup walaupun write ini gagal.
    _pushChain = write.catchError((e) {
      debugPrint('UserModel._pushToCloud queue gagal: $e');
    });

    await write;
  }

  /// Panggil semasa LOGOUT SAHAJA. Reset semua field ke default di
  /// memori + kosongkan cache local (SharedPreferences) — TANPA push
  /// apa-apa ke cloud. Logout ≠ padam akaun: dokumen Firestore
  /// pengguna kekal utuh sepenuhnya; ni cuma bersihkan sesi peranti
  /// ni supaya akaun/guest seterusnya tak warisi data lama.
  ///
  /// SEBAB fungsi khas ni wujud: cara lama set field jadi '' terus
  /// panggil save() — save() tu SENTIASA push ke Firestore utk uid
  /// yg log masuk semasa itu. Kalau reset tu berlaku SEBELUM signOut()
  /// (atau kalau susunan kod diubah lain hari), nama & e-mel SEBENAR
  /// pengguna kat cloud boleh accidentally tertimpa jadi kosong.
  /// Fungsi ni sengaja TAK PERNAH panggil save()/_pushToCloud().
  ///
  /// Juga dipanggil sebagai langkah TERAKHIR oleh deleteAccount() —
  /// selepas Firestore & Firebase Auth berjaya dipadam, sesi peranti
  /// ni mesti dibersihkan sama macam logout biasa.
  Future<void> resetLocalSession() async {
    // Reset SETIAP field secara eksplisit di sini — SENGAJA tidak
    // bergantung kepada _applyMap(const {}). Sebab: _applyMap guna
    // corak "if (d['x'] != null) field = ..." untuk birthdate &
    // lastActiveDate, jadi bila map input kosong, field tu terus TAK
    // DISENTUH (bukan reset ke null macam field lain). Ini punca bug
    // asal — nilai lama boleh terbawa ke sesi/akaun seterusnya pada
    // peranti sama. Reset eksplisit di sini elak isu ni berulang walau
    // _applyMap() diubah lain hari.
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('birthday_state');
    await prefs.remove('birthday_note');
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // PADAM AKAUN — FIX #4
  // ═══════════════════════════════════════════════════════════════
  /// Padam akaun sepenuhnya: post-post pengguna, dokumen users/{uid},
  /// akaun Firebase Auth, dan akhirnya sesi local peranti ni.
  ///
  /// PENTING — client-side deletion BUKAN atomik. Urutan di bawah ni
  /// sengaja disusun begini supaya kegagalan di mana-mana langkah
  /// tidak sekali-kali meninggalkan akaun dalam keadaan lebih teruk
  /// dari sebelum dipanggil:
  ///
  ///   1. Reauthenticate — WAJIB berjaya dulu. Kalau gagal (kata
  ///      laluan salah, dll), method ni throw & TIADA APA-APA yang
  ///      dipadam — bukan post, bukan users/{uid}, bukan Auth.
  ///   2. Padam post-post pengguna (posts where authorId == uid).
  ///      Guna batch selamat (< 500 operasi/batch).
  ///   3. Padam dokumen users/{uid} — HANYA lepas (2) berjaya.
  ///   4. Padam akaun Firebase Auth (currentUser.delete()) — langkah
  ///      TERAKHIR & TAK BOLEH DIUNDUR, HANYA lepas (3) berjaya.
  ///   5. Bersihkan sesi local (sama seperti resetLocalSession()).
  ///
  /// Kalau langkah (2), (3) atau (4) throw, exception itu terus
  /// dilontar ke caller (UI) TANPA cuba teruskan ke langkah
  /// seterusnya — caller mesti anggap padam TIDAK BERJAYA SEPENUHNYA
  /// (mungkin sebahagian data dah terpadam) dan TIDAK boleh navigate
  /// ke AuthScreen macam padam berjaya.
  ///
  /// Throws [FirebaseAuthException] bila reauth (langkah 1) gagal.
  /// Throws [FirebaseException]/[Exception] lain bila langkah
  /// Firestore/Auth selepas reauth gagal.
  Future<void> deleteAccount({required String password}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('Tiada pengguna log masuk.');
    }
    final String uid = currentUser.uid;
    final String? userEmail = currentUser.email;
    if (userEmail == null || userEmail.isEmpty) {
      throw StateError('Akaun ini tiada e-mel berdaftar untuk reauthentication.');
    }

    // ── 1. REAUTHENTICATE ─────────────────────────────────────────
    // Mesti berjaya SEBELUM apa-apa dipadam. Kalau baris ni throw
    // (FirebaseAuthException, cth. 'wrong-password'), caller berhenti
    // di sini — tiada post/users/Auth yang tersentuh langsung.
    final credential = EmailAuthProvider.credential(
      email: userEmail,
      password: password,
    );
    await currentUser.reauthenticateWithCredential(credential);

    // ── 2. PADAM POST-POST PENGGUNA SAHAJA ─────────────────────────
    // postsCount TIDAK digunakan sebagai sumber — ia bukan medan yang
    // diselenggara (lihat _protectedCloudFields), jadi query sebenar
    // ke koleksi posts ialah satu-satunya cara boleh dipercayai.
    final postsQuery = await FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .get();

    if (postsQuery.docs.isNotEmpty) {
      // Firestore had 500 operasi/batch — 400 bagi ruang selamat.
      const int batchSize = 400;
      for (var i = 0; i < postsQuery.docs.length; i += batchSize) {
        final batch = FirebaseFirestore.instance.batch();
        final chunk = postsQuery.docs.skip(i).take(batchSize);
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    // Result kosong (pengguna tiada post langsung) dikendalikan
    // secara semula jadi — gelung di atas tak jalan, terus ke (3).

    // ── 3. PADAM DOKUMEN users/{uid} ───────────────────────────────
    // HANYA sampai sini kalau (2) berjaya sepenuhnya tanpa exception.
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // ── 4. PADAM AKAUN FIREBASE AUTH ───────────────────────────────
    // Langkah TERAKHIR & TAK BOLEH DIUNDUR — HANYA lepas (3) berjaya.
    await currentUser.delete();

    // ── 5. BERSIHKAN SESI LOCAL ─────────────────────────────────────
    // Sama seperti logout — tiada apa-apa untuk push ke cloud lagi,
    // sebab akaun cloud dah tiada.
    await resetLocalSession();
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

  Future<void> _pushChain = Future.value();

  @visibleForTesting
  static bool isStaleSession(String capturedUid, String? currentUid) {
    return currentUid != capturedUid;
  }

  void _pushToCloud(Map<String, dynamic> map) {
    final String? uid = _uidOrNull();
    if (uid == null) return;

    final write = _pushChain.then((_) => _doPushToCloud(uid, map));

    // save() biasa kekal fire-and-forget, tetapi failure tidak boleh
    // mematikan queue untuk write seterusnya.
    _pushChain = write.catchError((e) {
      debugPrint('UserModel._pushToCloud queue gagal: $e');
    });
  }

  Future<void> _doPushToCloud(
    String uid,
    Map<String, dynamic> map,
  ) async {
    if (isStaleSession(uid, _uidOrNull())) {
      debugPrint(
        'UserModel._pushToCloud dilangkau — sesi UID dah berubah '
        '(logout/tukar akaun semasa write masih dalam queue).',
      );
      return;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await docRef.update(buildUpdatePayload(map));
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') {
        debugPrint('UserModel._pushToCloud update gagal (offline?): $e');
        rethrow;
      }

      try {
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        await docRef.set(buildCreatePayload(map));
      } catch (e2) {
        debugPrint('UserModel._pushToCloud create gagal (offline?): $e2');
        rethrow;
      }
    } catch (e) {
      debugPrint('UserModel._pushToCloud gagal (offline?): $e');
      rethrow;
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
      _applyMap(
        doc.data()!,
        preserveLocalGamification: true,
      );
      final map = _toMap();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(map));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('UserModel.pullFromCloud gagal: $e');
      return false;
    }
  }
}
