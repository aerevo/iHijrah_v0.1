// lib/utils/prayer_service.dart (UPGRADED 7.8/10)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';

import 'storage_service.dart';
import 'constants.dart';
import 'audio_service.dart';
import 'settings_enums.dart';

/// Service untuk manage prayer times & notifications
/// 
/// Features:
/// - Auto-update prayer times daily
/// - Countdown to next prayer
/// - Alarm status management per prayer
/// - Location-based calculation
class PrayerService with ChangeNotifier {
  // ===== DEPENDENCIES =====
  final StorageService storage;
  final AudioService audioService;

  // ===== STATE =====
  late PrayerTimes _prayerTimes;
  Coordinates? _coordinates;
  
  // UI State
  String? nextPrayerName;
  Duration? timeUntilNextPrayer;
  
  // Timers
  Timer? _ticker;
  Timer? _dailyRefreshTimer;
  
  // Location
  double _currentLat = DEFAULT_LATITUDE;
  double _currentLng = DEFAULT_LONGITUDE;
  
  // Alarm Status (menggunakan Enum untuk type safety)
  final Map<PrayerType, bool> _alarmStatus = {
    PrayerType.subuh: true,
    PrayerType.zohor: true,
    PrayerType.asar: true,
    PrayerType.maghrib: true,
    PrayerType.isyak: true,
  };

  // ===== CONSTRUCTOR =====
  
  PrayerService(this.storage, this.audioService) {
    _loadSettings();
    _initPrayerTimes();
    _startTimers();
  }

  // ===== INITIALIZATION =====

  Future<void> _loadSettings() async {
    // Load location
    final lat = storage.getLatitude();
    final lng = storage.getLongitude();

    if (lat != null && lng != null) {
      _currentLat = lat;
      _currentLng = lng;
      
      if (kDebugMode) {
        print('📍 Loaded location: $lat, $lng');
      }
    }

    // Load alarm statuses
    for (var prayer in PrayerType.values) {
      _alarmStatus[prayer] = storage.getAlarmStatus(prayer.name) ?? true;
    }

    _initPrayerTimes();
  }

  void _initPrayerTimes() {
    try {
      _coordinates = Coordinates(_currentLat, _currentLng);

      final params = CalculationMethod.muslimWorldLeague();
      params.madhab = Madhab.shafi;

      final date = DateTime.now();
      _prayerTimes = PrayerTimes(_coordinates!, date, params);

      _updateNextPrayer();
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Prayer times initialized for ${date.toString().split(' ')[0]}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to init prayer times: $e');
      }
    }
  }

  // ===== TIMERS =====

  void _startTimers() {
    // Update countdown setiap 30 saat
    _ticker = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateNextPrayer();
    });

    // Refresh prayer times setiap hari (jam 12 malam)
    _scheduleDailyRefresh();
  }

  void _scheduleDailyRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _dailyRefreshTimer = Timer(durationUntilMidnight, () {
      if (kDebugMode) {
        print('🔄 Daily prayer times refresh');
      }
      _initPrayerTimes();
      _scheduleDailyRefresh(); // Schedule next refresh
    });
  }

  // ===== PRAYER TIME CALCULATIONS =====

  void _updateNextPrayer() {
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
      // After Isyak, next is Fajr tomorrow
      nextPrayerName = 'Subuh (Esok)';

      final params = CalculationMethod.muslimWorldLeague();
      params.madhab = Madhab.shafi;
      final tomorrow = now.add(const Duration(days: 1));
      final prayerTomorrow = PrayerTimes(_coordinates!, tomorrow, params);

      timeUntilNextPrayer = prayerTomorrow.fajr.difference(now);
    }

    notifyListeners();
  }

  // ===== GETTERS =====

  /// Get prayer time dalam format String (contoh: "5:30 AM")
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

  /// Get all prayer times (untuk display semua waktu sekaligus)
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
        'Subuh': '--:--',
        'Zohor': '--:--',
        'Asar': '--:--',
        'Maghrib': '--:--',
        'Isyak': '--:--',
      };
    }
  }

  /// Format countdown untuk UI
  String get formattedTimeUntilNextPrayer {
    if (timeUntilNextPrayer == null) return '--:--';
    
    final h = timeUntilNextPrayer!.inHours;
    final m = timeUntilNextPrayer!.inMinutes.remainder(60);
    
    return '${h}j ${m}m';
  }

  // ===== ALARM MANAGEMENT =====

  /// Get alarm status (On/Off) dengan type safety
  bool getAlarmStatus(String prayerName) {
    final key = _stringToPrayerType(prayerName);
    if (key == null) return true; // Default: enabled
    return _alarmStatus[key] ?? true;
  }

  /// Set alarm status
  void setAlarmStatus(String prayerName, bool isEnabled) {
    final key = _stringToPrayerType(prayerName);
    if (key != null) {
      _alarmStatus[key] = isEnabled;
      storage.setAlarmStatus(key.name, isEnabled);
      notifyListeners();
      
      if (kDebugMode) {
        print('🔔 Alarm $prayerName: ${isEnabled ? "ON" : "OFF"}');
      }
    }
  }

  /// Helper: Convert string ke PrayerType enum
  PrayerType? _stringToPrayerType(String prayerName) {
    final name = prayerName.toLowerCase().trim();

    // Try exact match first
    for (var p in PrayerType.values) {
      if (p.name == name) return p;
    }

    // Try alternative names
    switch (name) {
      case 'fajr':
        return PrayerType.subuh;
      case 'dhuhr':
        return PrayerType.zohor;
      case 'asr':
        return PrayerType.asar;
      case 'isha':
        return PrayerType.isyak;
      default:
        return null;
    }
  }

  // ===== LOCATION UPDATE =====

  /// Update location & recalculate prayer times
  Future<void> updateLocation(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;

    // Save to storage
    await storage.setLocation(lat, lng);

    // Recalculate
    _initPrayerTimes();

    if (kDebugMode) {
      print('📍 Location updated: $lat, $lng');
    }
  }

  // ===== CLEANUP =====

  @override
  void dispose() {
    _ticker?.cancel();
    _dailyRefreshTimer?.cancel();
    super.dispose();
  }

  // ===== DEBUG =====

  @override
  String toString() {
    return 'PrayerService(next: $nextPrayerName in $formattedTimeUntilNextPrayer)';
  }
}