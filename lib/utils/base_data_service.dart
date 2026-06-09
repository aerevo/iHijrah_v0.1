// lib/utils/base_data_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

dynamic _decode(String source) => json.decode(source);

abstract class BaseDataService {
  static final Map<String, dynamic> _cache = {};

  static Future<T> load<T>(String path) async {
    if (_cache.containsKey(path)) return _cache[path] as T;
    try {
      final raw    = await rootBundle.loadString(path);
      final parsed = await compute(_decode, raw);
      if (parsed is List) {
        final d = parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _cache[path] = d;
        return d as T;
      } else if (parsed is Map) {
        final d = Map<String, dynamic>.from(parsed);
        _cache[path] = d;
        return d as T;
      }
      throw Exception('Format JSON tidak dikenali: $path');
    } catch (e) {
      if (kDebugMode) debugPrint('BaseDataService.load [$path]: $e');
      if (T.toString().contains('List')) return <Map<String, dynamic>>[] as T;
      return <String, dynamic>{} as T;
    }
  }

  static T get<T>(String path) {
    if (_cache.containsKey(path)) return _cache[path] as T;
    if (T.toString().contains('List')) return <Map<String, dynamic>>[] as T;
    return <String, dynamic>{} as T;
  }

  static void clearCache() => _cache.clear();
}
