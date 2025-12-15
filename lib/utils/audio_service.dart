// lib/utils/audio_service.dart (UPGRADED: Intro Audio Fix)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'settings_enums.dart';
import 'constants.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _introPlayer = AudioPlayer(); // Guna player berasingan untuk intro

  bool _isPlaying = false;
  String? _currentTrack;
  Timer? _autoStopTimer;

  bool get isPlaying => _isPlaying;

  Future<bool> _playAudio(
    AudioPlayer player,
    String assetPath, {
    double volume = 1.0,
    Duration? autoStopAfter,
  }) async {
    try {
      await player.stop();
      await player.setSource(AssetSource(assetPath));
      await player.setVolume(volume);
      await player.resume();
      _isPlaying = true;
      _currentTrack = assetPath;
      notifyListeners();

      if (autoStopAfter != null) {
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(autoStopAfter, () async {
          await player.stop();
          _isPlaying = false;
          _currentTrack = null;
          notifyListeners();
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error playing audio: $e');
      _isPlaying = false;
      _currentTrack = null;
      notifyListeners();
      return false;
    }
  }

  // ===== PUBLIC CONTROL METHODS =====

  Future<void> stopAllAudio() async {
    await _mainPlayer.stop();
    await _introPlayer.stop();
    _autoStopTimer?.cancel();
    _isPlaying = false;
    notifyListeners();
  }

  // ✅ DITAMBAH METHOD: Untuk home.dart
  Future<bool> playIntroAudio() async {
     // Intro audio guna introPlayer dan volume rendah
    return await _playAudio(_introPlayer, AppAssets.intro, volume: 0.2, autoStopAfter: const Duration(milliseconds: 3000));
  }


  // ===== SPECIFIC AUDIO PLAYERS (DIPANGGIL OLEH WIDGET) =====

  Future<bool> playSplashAudio() async => await _playAudio(_mainPlayer, AppAssets.splash, volume: 0.8, autoStopAfter: const Duration(milliseconds: 1500));
  Future<bool> playAlhamdulillah() async => await _playAudio(_mainPlayer, AppAssets.suaraAlhamdulillah, volume: 1.0, autoStopAfter: const Duration(seconds: 2));
  Future<bool> playInsyaallah() async => await _playAudio(_mainPlayer, AppAssets.suaraInsyaAllah, volume: 1.0, autoStopAfter: const Duration(seconds: 2));
  Future<bool> playHi() async => await _playAudio(_mainPlayer, AppAssets.suaraHi, volume: 1.0, autoStopAfter: const Duration(seconds: 2));
  Future<bool> playZikirPrompt() async => playHi(); // Guna semula sound Hi untuk zikir prompt

  Future<bool> playAdhan(BuildContext context) async {
    try {
      // Pastikan context di-handle dengan betul di luar scope method
      final user = Provider.of<UserModel>(context, listen: false);
      final AdhanMode currentMode = AdhanMode.values[user.adhanModeIndex];

      if (currentMode == AdhanMode.off) return false;

      final success = await _playAudio(_mainPlayer, AppAssets.adhan, volume: 1.0);
      if (!success) return false;

      if (currentMode == AdhanMode.short) {
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(const Duration(seconds: 15), () async {
          await _mainPlayer.stop();
          _isPlaying = false;
          notifyListeners();
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error playing Adhan: $e');
      return false;
    }
  }
}
