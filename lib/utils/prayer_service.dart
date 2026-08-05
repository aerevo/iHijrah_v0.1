// lib/utils/prayer_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import '../models/user_model.dart';

class PrayerService with ChangeNotifier {

  UserModel _user;

  // Nullable — belum tentu ada kalau gagal init
  PrayerTimes? _times;
  Coordinates?  _coords;

  String   nextPrayerName        = '--';
  Duration timeUntilNextPrayer   = Duration.zero;

  Timer? _ticker;
  Timer? _daily;

  double _lat = DEFAULT_LATITUDE;
  double _lng = DEFAULT_LONGITUDE;

  PrayerService(this._user) {
    _boot();
  }

  void updateUser(UserModel u) {
    _user = u;
  }

  // ── BOOT ──────────────────────────────────────────────────────
  Future<void> _boot() async {
    final p = await SharedPreferences.getInstance();
    _lat = p.getDouble('pref_lat') ?? DEFAULT_LATITUDE;
    _lng = p.getDouble('pref_lng') ?? DEFAULT_LONGITUDE;
    _compute();
    _startTimers();
  }

  void _compute() {
    try {
      _coords = Coordinates(_lat, _lng);
      final params = CalculationMethod.singapore.getParameters()
        ..madhab = Madhab.shafi;
      _times = PrayerTimes(
          _coords!, DateComponents.from(DateTime.now()), params);
      _tick();
    } catch (e) {
      if (kDebugMode) debugPrint('PrayerService._compute: $e');
    }
  }

  void _tick() {
    if (_times == null) return;
    try {
      final Prayer next = _times!.nextPrayer();
      nextPrayerName = _name(next);
      final DateTime? t = _times!.timeForPrayer(next);
      timeUntilNextPrayer =
          t != null ? t.difference(DateTime.now()) : Duration.zero;
      notifyListeners();
    } catch (_) {}
  }

  void _startTimers() {
    // Setiap minit — bukan setiap saat
    _ticker = Timer.periodic(
        const Duration(minutes: 1), (_) => _tick());
    // Refresh waktu solat setiap jam
    _daily = Timer.periodic(
        const Duration(hours: 1), (_) => _compute());
  }

  // ── PUBLIC API ────────────────────────────────────────────────
  Future<void> updateLocation(double lat, double lng) async {
    _lat = lat; _lng = lng;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('pref_lat', lat);
    await p.setDouble('pref_lng', lng);
    _compute();
  }

  /// Waktu solat tunggal — format "5:43 AM"
  String timeFor(String name) {
    if (_times == null) return '--:--';
    try {
      final fmt = DateFormat('h:mm a');
      switch (name.toLowerCase()) {
        case 'subuh':   return fmt.format(_times!.fajr);
        case 'syuruk':  return fmt.format(_times!.sunrise);
        case 'zohor':   return fmt.format(_times!.dhuhr);
        case 'asar':    return fmt.format(_times!.asr);
        case 'maghrib': return fmt.format(_times!.maghrib);
        case 'isyak':   return fmt.format(_times!.isha);
        default:        return '--:--';
      }
    } catch (_) { return '--:--'; }
  }

  /// Semua waktu solat
  Map<String, String> get allTimes {
    if (_times == null) return _empty;
    try {
      final fmt = DateFormat('h:mm a');
      return {
        'Subuh':   fmt.format(_times!.fajr),
        'Syuruk':  fmt.format(_times!.sunrise),
        'Zohor':   fmt.format(_times!.dhuhr),
        'Asar':    fmt.format(_times!.asr),
        'Maghrib': fmt.format(_times!.maghrib),
        'Isyak':   fmt.format(_times!.isha),
      };
    } catch (_) { return _empty; }
  }

  static const Map<String, String> _empty = {
    'Subuh':'--:--','Syuruk':'--:--','Zohor':'--:--',
    'Asar':'--:--','Maghrib':'--:--','Isyak':'--:--',
  };

  /// True = waktu siang (Subuh–Maghrib), false = waktu malam.
  /// Guna utk auto tema Siang/Malam feed (lihat theme/feed_theme.dart).
  /// notifyListeners() dari _tick() (setiap minit) sudah cukup kerap utk
  /// dikesan bila nilai ni bertukar sekitar waktu Subuh/Maghrib sebenar.
  bool get isDayTime {
    if (_times == null) {
      // Fallback sblm waktu solat berjaya dikira (cth. app baru buka,
      // GPS belum settle) — anggar ikut jam sistem 6 pagi – 7 malam.
      final int h = DateTime.now().hour;
      return h >= 6 && h < 19;
    }
    final DateTime now = DateTime.now();
    return now.isAfter(_times!.fajr) && now.isBefore(_times!.maghrib);
  }

  /// "2j 15m" lagi ke waktu solat seterusnya
  String get countdown {
    if (timeUntilNextPrayer <= Duration.zero) return '--:--';
    final h = timeUntilNextPrayer.inHours;
    final m = timeUntilNextPrayer.inMinutes.remainder(60);
    if (h > 0) return '${h}j ${m}m';
    return '${m}m lagi';
  }

  String _name(Prayer p) {
    switch (p) {
      case Prayer.fajr:    return 'Subuh';
      case Prayer.sunrise: return 'Syuruk';
      case Prayer.dhuhr:   return 'Zohor';
      case Prayer.asr:     return 'Asar';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha:    return 'Isyak';
      default:             return 'Subuh';
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _daily?.cancel();
    super.dispose();
  }
}
