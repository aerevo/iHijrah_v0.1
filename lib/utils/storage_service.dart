// lib/utils/storage_service.dart (UPGRADED 7.8/10)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'result.dart';

/// Service untuk manage persistent storage (Hive + SharedPreferences)
/// 
/// Features:
/// - Centralized storage access
/// - Error handling dengan Result<T, E>
/// - Safe initialization
/// - Latitude/Longitude storage
class StorageService {
  // ===== CONSTANTS =====
  static const String _userBox = 'userBox';
  static const String _prayerBox = 'prayerBox';
  static const String _keyIntroSeen = 'hasSeenIntro';
  static const String _keyLatitude = 'latitude';
  static const String _keyLongitude = 'longitude';
  static const String _prefixAlarm = 'alarm_';

  // ===== STATE =====
  SharedPreferences? _prefs;
  bool _initialized = false;

  // ===== GETTERS =====
  bool get isInitialized => _initialized;

  // ===== INITIALIZATION =====

  /// Initialize storage (MUST call before using any method)
  Future<Result<void, String>> init() async {
    if (_initialized) {
      return Result.success(null);
    }

    try {
      // 1. Setup Hive
      final dir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(dir.path);

      // 2. Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      // 3. Open boxes
      await Hive.openBox<UserModel>(_userBox);
      await Hive.openBox<Map>(_prayerBox);

      // 4. Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      _initialized = true;
      
      if (kDebugMode) {
        print('✅ StorageService initialized successfully');
      }

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ StorageService init failed: $e');
      }
      return Result.failure('Failed to initialize storage: $e');
    }
  }

  /// Ensure initialized (helper untuk prevent crashes)
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
  }

  // ===== USER DATA (HIVE) =====

  /// Get UserModel (always returns valid model)
  UserModel getUserModel() {
    _ensureInitialized();
    
    final userBox = Hive.box<UserModel>(_userBox);
    
    if (userBox.isEmpty) {
      // Create new user
      final newUser = UserModel();
      userBox.add(newUser);
      
      if (kDebugMode) {
        print('📝 Created new UserModel');
      }
      
      return newUser;
    }

    return userBox.getAt(0)!;
  }

  /// Save user model
  Future<Result<void, String>> saveUserModel(UserModel user) async {
    try {
      await user.save();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save user: $e');
    }
  }

  // ===== PRAYER TIMES (HIVE) =====

  /// Update prayer times
  Future<Result<void, String>> updatePrayerTimes(Map<String, dynamic> times) async {
    try {
      _ensureInitialized();
      final prayerBox = Hive.box<Map>(_prayerBox);
      await prayerBox.put('prayerTimes', times);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save prayer times: $e');
    }
  }

  /// Get prayer times
  Map<String, dynamic>? getPrayerTimes() {
    try {
      _ensureInitialized();
      final prayerBox = Hive.box<Map>(_prayerBox);
      return prayerBox.get('prayerTimes')?.cast<String, dynamic>();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get prayer times: $e');
      }
      return null;
    }
  }

  // ===== APP SETTINGS (SHARED PREFERENCES) =====

  /// Check if user has seen intro
  bool get hasSeenIntro {
    _ensureInitialized();
    return _prefs?.getBool(_keyIntroSeen) ?? false;
  }

  /// Mark intro as seen
  Future<bool> setSeenIntro() async {
    _ensureInitialized();
    return await _prefs?.setBool(_keyIntroSeen, true) ?? false;
  }

  // ===== ALARM SETTINGS =====

  /// Get alarm status for specific prayer
  bool? getAlarmStatus(String key) {
    _ensureInitialized();
    return _prefs?.getBool('$_prefixAlarm$key');
  }

  /// Set alarm status
  Future<bool> setAlarmStatus(String key, bool value) async {
    _ensureInitialized();
    return await _prefs?.setBool('$_prefixAlarm$key', value) ?? false;
  }

  // ===== LOCATION SETTINGS =====

  /// Get saved latitude
  double? getLatitude() {
    _ensureInitialized();
    return _prefs?.getDouble(_keyLatitude);
  }

  /// Get saved longitude
  double? getLongitude() {
    _ensureInitialized();
    return _prefs?.getDouble(_keyLongitude);
  }

  /// Set latitude
  Future<bool> setLatitude(double value) async {
    _ensureInitialized();
    return await _prefs?.setDouble(_keyLatitude, value) ?? false;
  }

  /// Set longitude
  Future<bool> setLongitude(double value) async {
    _ensureInitialized();
    return await _prefs?.setDouble(_keyLongitude, value) ?? false;
  }

  /// Set location (latitude & longitude together)
  Future<Result<void, String>> setLocation(double lat, double lng) async {
    try {
      final latSuccess = await setLatitude(lat);
      final lngSuccess = await setLongitude(lng);

      if (latSuccess && lngSuccess) {
        return Result.success(null);
      } else {
        return Result.failure('Failed to save location');
      }
    } catch (e) {
      return Result.failure('Error saving location: $e');
    }
  }

  // ===== GENERIC PREFERENCES =====

  /// Get string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs?.getString(key);
  }

  /// Set string value
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await _prefs?.setString(key, value) ?? false;
  }

  /// Get int value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs?.getInt(key);
  }

  /// Set int value
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs?.setInt(key, value) ?? false;
  }

  // ===== CLEANUP =====

  /// Clear all preferences (for testing/logout)
  Future<Result<void, String>> clearAllPreferences() async {
    try {
      _ensureInitialized();
      await _prefs?.clear();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear preferences: $e');
    }
  }

  /// Reset user data (delete user box)
  Future<Result<void, String>> resetUserData() async {
    try {
      _ensureInitialized();
      final userBox = Hive.box<UserModel>(_userBox);
      await userBox.clear();
      
      if (kDebugMode) {
        print('🗑️ User data cleared');
      }
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to reset user data: $e');
    }
  }

  // ===== DEBUG =====

  @override
  String toString() {
    return 'StorageService(initialized: $_initialized)';
  }
}