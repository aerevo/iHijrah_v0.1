// lib/utils/prayer_service.dart (FINAL - OFFICIAL ADHAN ENGINE)
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart'; // Menggunakan official package
import 'package:intl/intl.dart';
import 'storage_service.dart';
import 'constants.dart';
import 'audio_service.dart';
import 'settings_enums.dart';

class PrayerService with ChangeNotifier {
  final StorageService storage;
  final AudioService audioService;

  late PrayerTimes _prayerTimes;
  Coordinates? _coordinates;

  String? nextPrayerName;
  Duration? timeUntilNextPrayer;

  Timer? _ticker;
  Timer? _dailyRefreshTimer;

  double _currentLat = DEFAULT_LATITUDE;
  double _currentLng = DEFAULT_LONGITUDE;

  final Map<PrayerType, bool> _alarmStatus = {
    PrayerType.subuh: true,
    PrayerType.zohor: true,
    PrayerType.asar: true,
    PrayerType.maghrib: true,
    PrayerType.isyak: true,
  };

  PrayerService(this.storage, this.audioService) {
    _loadSettings();
    _startTimers();
  }

  Future<void> _loadSettings() async {
    final lat = storage.getLatitude();
    final lng = storage.getLongitude();
    if (lat != null && lng != null) {
      _currentLat = lat;
      _currentLng = lng;
    }

    for (var prayer in PrayerType.values) {
      _alarmStatus[prayer] = storage.getAlarmStatus(prayer.name) ?? true;
    }

    _initPrayerTimes();
  }

  void _initPrayerTimes() {
    try {
      _coordinates = Coordinates(_currentLat, _currentLng);
      final now = DateTime.now();

      // ✅ SETUP OFFICIAL ADHAN
      final dateComps = DateComponents.from(now);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      _prayerTimes = PrayerTimes(_coordinates!, dateComps, params);

      _updateNextPrayer();
      notifyListeners();

      if (kDebugMode) {
        print('✅ Prayer times initialized (Official Adhan Engine)');
      }
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
    try {
      final now = DateTime.now();

      // Dapatkan waktu solat sebenar dari library
      // Library adhan return DateTime local, jadi boleh banding terus

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

  String? getPrayerTimeByName(String prayerName) {
    final name = prayerName.toLowerCase().trim();
    try {
      switch (name) {
        case 'subuh':
        case 'fajr':
          return DateFormat.jm().format(_prayerTimes.fajr);
        case 'zohor':
        case 'dhuhr':
          return DateFormat.jm().format(_prayerTimes.dhuhr);
        case 'asar':
        case 'asr':
          return DateFormat.jm().format(_prayerTimes.asr);
        case 'maghrib':
          return DateFormat.jm().format(_prayerTimes.maghrib);
        case 'isyak':
        case 'isha':
          return DateFormat.jm().format(_prayerTimes.isha);
        default:
          return '--:--';
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
      return {
        'Subuh': '--:--', 'Zohor': '--:--', 'Asar': '--:--', 'Maghrib': '--:--', 'Isyak': '--:--'
      };
    }
  }

  String get formattedTimeUntilNextPrayer {
    if (timeUntilNextPrayer == null) return '--:--';
    final h = timeUntilNextPrayer!.inHours;
    final m = timeUntilNextPrayer!.inMinutes.remainder(60);
    return '${h}j ${m}m';
  }

  bool getAlarmStatus(String prayerName) {
    final key = _stringToPrayerType(prayerName);
    if (key == null) return true;
    return _alarmStatus[key] ?? true;
  }

  void setAlarmStatus(String prayerName, bool isEnabled) {
    final key = _stringToPrayerType(prayerName);
    if (key != null) {
      _alarmStatus[key] = isEnabled;
      storage.setAlarmStatus(key.name, isEnabled);
      notifyListeners();
    }
  }

  PrayerType? _stringToPrayerType(String prayerName) {
    final name = prayerName.toLowerCase().trim();
    for (var p in PrayerType.values) {
      if (p.name == name) return p;
    }
    switch (name) {
      case 'fajr': return PrayerType.subuh;
      case 'dhuhr': return PrayerType.zohor;
      case 'asr': return PrayerType.asar;
      case 'isha': return PrayerType.isyak;
      default: return null;
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;
    await storage.setLocation(lat, lng);
    _initPrayerTimes();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _dailyRefreshTimer?.cancel();
    super.dispose();
  }
}