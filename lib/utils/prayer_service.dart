// lib/utils/prayer_service.dart (SYNCED WITH USERMODEL)
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import '../models/user_model.dart';
// import 'settings_enums.dart'; // Uncomment jika enum dipindahkan ke fail asing

class PrayerService with ChangeNotifier {
  UserModel _userModel;

  late PrayerTimes _prayerTimes;
  Coordinates? _coordinates;
  String? nextPrayerName;
  Duration? timeUntilNextPrayer;
  Timer? _ticker;
  Timer? _dailyRefreshTimer;
  double _currentLat = DEFAULT_LATITUDE;
  double _currentLng = DEFAULT_LONGITUDE;

  // Constructor menerima UserModel
  PrayerService(this._userModel) {
    _loadSettings();
    _startTimers();
  }

  // Dipanggil oleh ProxyProvider bila UserModel berubah
  void updateUser(UserModel newUserModel) {
    _userModel = newUserModel;
    // Boleh trigger logic tambahan jika setting user berubah (cth: kaedah kiraan)
    // notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLat = prefs.getDouble('latitude') ?? DEFAULT_LATITUDE;
    _currentLng = prefs.getDouble('longitude') ?? DEFAULT_LONGITUDE;
    _initPrayerTimes();
  }

  void _initPrayerTimes() {
    try {
      _coordinates = Coordinates(_currentLat, _currentLng);
      final now = DateTime.now();
      final dateComps = DateComponents.from(now);

      // MWL standard, boleh ubah ikut user setting nanti
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      _prayerTimes = PrayerTimes(_coordinates!, dateComps, params);
      _updateNextPrayer();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to init prayer times: $e');
      }
    }
  }

  void _startTimers() {
    _ticker = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateNextPrayer();
    });
    _scheduleDailyRefresh();
  }

  void _scheduleDailyRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _dailyRefreshTimer = Timer(durationUntilMidnight, () {
      _initPrayerTimes();
      _scheduleDailyRefresh();
    });
  }

  void _updateNextPrayer() {
    if (_coordinates == null) return;
    try {
      final now = DateTime.now();

      if (now.isBefore(_prayerTimes.fajr)) {
        nextPrayerName = 'Subuh';
        timeUntilNextPrayer = _prayerTimes.fajr.difference(now);
      } else if (now.isBefore(_prayerTimes.dhuhr)) {
        nextPrayerName = 'Zohor';
        timeUntilNextPrayer = _prayerTimes.dhuhr.difference(now);
      } else if (now.isBefore(_prayerTimes.asr)) {
        nextPrayerName = 'Asar';
        timeUntilNextPrayer = _prayerTimes.asr.difference(now);
      } else if (now.isBefore(_prayerTimes.maghrib)) {
        nextPrayerName = 'Maghrib';
        timeUntilNextPrayer = _prayerTimes.maghrib.difference(now);
      } else if (now.isBefore(_prayerTimes.isha)) {
        nextPrayerName = 'Isyak';
        timeUntilNextPrayer = _prayerTimes.isha.difference(now);
      } else {
        nextPrayerName = 'Subuh (Esok)';
        final tomorrow = now.add(const Duration(days: 1));
        final dateComps = DateComponents.from(tomorrow);
        final params = CalculationMethod.muslim_world_league.getParameters();
        params.madhab = Madhab.shafi;
        final prayerTomorrow = PrayerTimes(_coordinates!, dateComps, params);
        timeUntilNextPrayer = prayerTomorrow.fajr.difference(now);
      }
      notifyListeners();
    } catch (e) {
      nextPrayerName = '--';
    }
  }

  // Getters & Formatters
  String? getPrayerTimeByName(String prayerName) {
    final name = prayerName.toLowerCase().trim();
    try {
      switch (name) {
        case 'subuh': case 'fajr': return DateFormat.jm().format(_prayerTimes.fajr);
        case 'zohor': case 'dhuhr': return DateFormat.jm().format(_prayerTimes.dhuhr);
        case 'asar': case 'asr': return DateFormat.jm().format(_prayerTimes.asr);
        case 'maghrib': return DateFormat.jm().format(_prayerTimes.maghrib);
        case 'isyak': case 'isha': return DateFormat.jm().format(_prayerTimes.isha);
        default: return '--:--';
      }
    } catch (e) {
      return '--:--';
    }
  }

  Map<String, String> getAllPrayerTimes() {
    try {
      return {
        'Subuh': DateFormat.jm().format(_prayerTimes.fajr),
        'Zohor': DateFormat.jm().format(_prayerTimes.dhuhr),
        'Asar': DateFormat.jm().format(_prayerTimes.asr),
        'Maghrib': DateFormat.jm().format(_prayerTimes.maghrib),
        'Isyak': DateFormat.jm().format(_prayerTimes.isha),
      };
    } catch (e) {
      return {'Subuh': '--:--', 'Zohor': '--:--', 'Asar': '--:--', 'Maghrib': '--:--', 'Isyak': '--:--'};
    }
  }

  String get formattedTimeUntilNextPrayer {
    if (timeUntilNextPrayer == null) return '--:--';
    final h = timeUntilNextPrayer!.inHours;
    final m = timeUntilNextPrayer!.inMinutes.remainder(60);
    return '${h}j ${m}m';
  }

  Future<void> updateLocation(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
    _initPrayerTimes();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _dailyRefreshTimer?.cancel();
    super.dispose();
  }
}
