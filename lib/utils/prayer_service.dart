// lib/utils/prayer_service.dart (RE-CONFIRMED FIX)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart'; // Import yang betul
import '../models/user_model.dart';
import 'settings_enums.dart';

class PrayerService with ChangeNotifier {
  UserModel _userModel;

  late PrayerTimes _prayerTimes;
  Coordinates? _coordinates;

  String? nextPrayerName;
  Duration? timeUntilNextPrayer;

  Timer? _ticker;
  Timer? _dailyRefreshTimer;

  // Koordinat Semasa (Guna constant yang diimport)
  double _currentLat = DEFAULT_LATITUDE;
  double _currentLng = DEFAULT_LONGITUDE;

  PrayerService(this._userModel) {
    _loadSettings();
    _startTimers(); // Start the timer for next prayer countdown
  }

  void updateUser(UserModel newUserModel) {
    _userModel = newUserModel;
    // Potentially re-load settings if they can change
    // notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Penggunaan DEFAULT_LATITUDE/LONGITUDE kini merujuk kepada constants.dart
    _currentLat = prefs.getDouble('latitude') ?? DEFAULT_LATITUDE;
    _currentLng = prefs.getDouble('longitude') ?? DEFAULT_LONGITUDE;

    _initPrayerTimes();
  }

  void _initPrayerTimes() {
    try {
      _coordinates = Coordinates(_currentLat, _currentLng);
      final now = DateTime.now();
      final dateComps = DateComponents.from(now);
      
      // Menggunakan CalculationMethod yang sesuai (Singapore/MuslimWorldLeague for Malaysia)
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;
      
      _prayerTimes = PrayerTimes(_coordinates!, dateComps, params);
      
      _updateNextPrayer();
      _calculateQibla();
    } catch (e) {
      if (kDebugMode) {
        print("Ralat mengira waktu solat: $e");
      }
    }
  }
  
  // Logic untuk kira waktu solat seterusnya
  void _updateNextPrayer() {
    if (_prayerTimes == null) return;
    
    final next = _prayerTimes!.nextPrayer();
    nextPrayerName = _getPrayerName(next);
    
    final nextTime = _prayerTimes!.timeForPrayer(next);
    if (nextTime != null) {
      timeUntilNextPrayer = nextTime.difference(DateTime.now());
    } else {
      timeUntilNextPrayer = null;
    }
    notifyListeners();
  }
  
  // Update lokasi jika user ubah
  Future<void> updateLocation(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
    
    _initPrayerTimes(); // Re-calculate with new location
    notifyListeners();
  }
  
  void _calculateQibla() {
    if (_coordinates != null) {
      // Logic untuk Qibla (Jika ada)
    }
  }

  // Helper untuk namakan waktu solat
  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return "Subuh";
      case Prayer.sunrise: return "Syuruk";
      case Prayer.dhuhr: return "Zohor";
      case Prayer.asr: return "Asar";
      case Prayer.maghrib: return "Maghrib";
      case Prayer.isha: return "Isyak";
      case Prayer.none: return "Subuh";
      default: return "--";
    }
  }
  
  // Timer untuk update waktu solat (setiap saat)
  void _startTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNextPrayer();
    });

    // Refresh waktu solat setiap hari (supaya tarikh sentiasa betul)
    _dailyRefreshTimer?.cancel();
    _dailyRefreshTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _initPrayerTimes();
    });
  }

  // Getter format masa (dipanggil oleh widgets)
  String getPrayerTime(String prayerName) {
    try {
      if (_prayerTimes == null) return '--:--';

      // ... (logic remains the same)
      switch (prayerName.toLowerCase()) {
        case 'subuh':
        case 'fajr':
          return DateFormat.jm().format(_prayerTimes.fajr);
        case 'syuruk':
        case 'sunrise':
          return DateFormat.jm().format(_prayerTimes.sunrise);
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
    // ... (logic remains the same)
    try {
      if (_prayerTimes == null) return {
        'Subuh': '--:--', 'Zohor': '--:--', 'Asar': '--:--', 'Maghrib': '--:--', 'Isyak': '--:--'
      };
      
      return {
        'Subuh': DateFormat.jm().format(_prayerTimes.fajr),
        'Syuruk': DateFormat.jm().format(_prayerTimes.sunrise),
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

  @override
  void dispose() {
    _ticker?.cancel();
    _dailyRefreshTimer?.cancel();
    super.dispose();
  }
}
