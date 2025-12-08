import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Penting untuk 'compute'

// Fungsi Top-Level (Mesti di luar class) untuk background process
dynamic _jsonDecodeIsolated(String source) {
  return json.decode(source);
}

abstract class BaseDataService {
  // Cache mudah untuk elak baca fail berulang kali
  static final Map<String, dynamic> _cache = {};

  static Future<T> load<T>(String assetPath) async {
    // 1. Cek Cache
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath] as T;
    }

    try {
      // 2. Baca fail
      final raw = await rootBundle.loadString(assetPath);

      // 3. Parse JSON di Background Thread (Elak Lag)
      final parsed = await compute(_jsonDecodeIsolated, raw);

      if (parsed is List) {
        final data = parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _cache[assetPath] = data;
        return data as T;
      } else if (parsed is Map) {
        final data = Map<String, dynamic>.from(parsed);
        _cache[assetPath] = data;
        return data as T;
      }
      throw Exception('Format data salah: $assetPath');

    } catch (e) {
      if (kDebugMode) print('Error Load $assetPath: $e');
      // Return nilai kosong yang selamat
      if (T.toString().contains("List")) return <Map<String, dynamic>>[] as T;
      return <String, dynamic>{} as T;
    }
  }

  static T get<T>(String assetPath) {
    if (_cache.containsKey(assetPath)) return _cache[assetPath] as T;
    if (T.toString().contains("List")) return <Map<String, dynamic>>[] as T;
    return <String, dynamic>{} as T;
  }
}