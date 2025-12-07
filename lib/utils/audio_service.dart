// lib/utils/audio_service.dart (UPGRADED 7.8/10)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'settings_enums.dart';
import 'constants.dart';

/// Service untuk manage audio playback
/// 
/// Features:
/// - Multiple players untuk prevent conflicts
/// - Azan mode support (Off/Full/Short)
/// - Auto-stop untuk prevent memory leaks
/// - Error handling
class AudioService extends ChangeNotifier {
  // ===== AUDIO PLAYERS =====
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _introPlayer = AudioPlayer();
  
  // ===== STATE =====
  bool _isPlaying = false;
  String? _currentTrack;
  Timer? _autoStopTimer;

  // ===== GETTERS =====
  bool get isPlaying => _isPlaying;
  String? get currentTrack => _currentTrack;

  // ===== PRIVATE HELPERS =====

  /// Play audio dengan error handling
  Future<bool> _playAudio(
    AudioPlayer player,
    String assetPath, {
    double volume = 1.0,
    Duration? autoStopAfter,
  }) async {
    try {
      await player.stop(); // Stop current if any
      await player.setSource(AssetSource(assetPath));
      await player.setVolume(volume);
      await player.resume();

      _isPlaying = true;
      _currentTrack = assetPath;
      notifyListeners();

      // Auto-stop timer
      if (autoStopAfter != null) {
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(autoStopAfter, () async {
          await player.stop();
          _isPlaying = false;
          _currentTrack = null;
          notifyListeners();
        });
      }

      if (kDebugMode) {
        print('🔊 Playing: $assetPath');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Audio error: $e');
      }
      _isPlaying = false;
      _currentTrack = null;
      notifyListeners();
      return false;
    }
  }

  /// Stop audio dengan cleanup
  Future<void> _stopAudio(AudioPlayer player) async {
    try {
      await player.stop();
      _autoStopTimer?.cancel();
      _isPlaying = false;
      _currentTrack = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Stop audio error: $e');
      }
    }
  }

  // ===== PUBLIC METHODS - INTRO =====

  /// Play intro music (splash screen)
  Future<bool> playIntro() async {
    return await _playAudio(
      _introPlayer,
      AppAssets.intro,
      volume: 0.5,
    );
  }

  /// Stop intro music
  Future<void> stopIntro() async {
    await _stopAudio(_introPlayer);
  }

  // ===== PUBLIC METHODS - SOUND EFFECTS =====

  /// Play siraman/splash sound (water effect)
  Future<bool> playSiraman() async {
    return await _playAudio(
      _mainPlayer,
      AppAssets.splash,
      volume: 0.8,
      autoStopAfter: const Duration(milliseconds: 1500),
    );
  }

  /// Alias untuk playSiraman (backward compatibility)
  Future<bool> playSplash() async => playSiraman();

  /// Play Alhamdulillah voice
  Future<bool> playAlhamdulillah() async {
    return await _playAudio(
      _mainPlayer,
      AppAssets.suaraAlhamdulillah,
      volume: 1.0,
      autoStopAfter: const Duration(seconds: 2),
    );
  }

  /// Play InsyaAllah voice
  Future<bool> playInsyaallah() async {
    return await _playAudio(
      _mainPlayer,
      AppAssets.suaraInsyaAllah,
      volume: 1.0,
      autoStopAfter: const Duration(seconds: 2),
    );
  }

  /// Play Hi/Assalamualaikum voice
  Future<bool> playHi() async {
    return await _playAudio(
      _mainPlayer,
      AppAssets.suaraHi,
      volume: 1.0,
      autoStopAfter: const Duration(seconds: 2),
    );
  }

  /// Play zikir prompt (sama dengan playHi)
  Future<bool> playZikirPrompt() async => playHi();

  // ===== PUBLIC METHODS - AZAN =====

  /// Play Azan dengan mode support (Off/Full/Short)
  /// 
  /// Requires BuildContext untuk access UserModel
  Future<bool> playAdhan(BuildContext context) async {
    try {
      // Get user's Azan mode preference
      final user = Provider.of<UserModel>(context, listen: false);
      final AdhanMode currentMode = AdhanMode.values[user.adhanModeIndex];

      // Check if OFF
      if (currentMode == AdhanMode.off) {
        if (kDebugMode) {
          print('🔇 Azan mode: OFF');
        }
        return false;
      }

      // Play Azan
      final success = await _playAudio(
        _mainPlayer,
        AppAssets.adhan,
        volume: 1.0,
      );

      if (!success) return false;

      // Handle SHORT mode (stop after 15 seconds)
      if (currentMode == AdhanMode.short) {
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(const Duration(seconds: 15), () async {
          await _mainPlayer.stop();
          _isPlaying = false;
          _currentTrack = null;
          notifyListeners();
          
          if (kDebugMode) {
            print('⏹️ Azan stopped (Short mode)');
          }
        });
      }

      if (kDebugMode) {
        print('📿 Azan playing (mode: ${currentMode.name})');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Azan playback error: $e');
      }
      return false;
    }
  }

  /// Stop Azan manually
  Future<void> stopAdhan() async {
    await _stopAudio(_mainPlayer);
  }

  // ===== SEQUENCED PLAYBACK =====

  /// Play audio sequence dengan delays (untuk complex animations)
  /// 
  /// Example:
  /// ```dart
  /// playSequence([
  ///   (AudioItem(AppAssets.splash, duration: Duration(seconds: 1)),
  ///   (AudioItem(AppAssets.suaraAlhamdulillah, delay: Duration(milliseconds: 500)),
  /// ]);
  /// ```
  Future<void> playSequence(List<AudioItem> items) async {
    for (final item in items) {
      if (item.delay != null) {
        await Future.delayed(item.delay!);
      }

      await _playAudio(
        _mainPlayer,
        item.assetPath,
        volume: item.volume,
        autoStopAfter: item.duration,
      );

      if (item.duration != null) {
        await Future.delayed(item.duration!);
      }
    }
  }

  // ===== VOLUME CONTROL =====

  /// Set main player volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _mainPlayer.setVolume(clampedVolume);
      
      if (kDebugMode) {
        print('🔊 Volume set to: ${(clampedVolume * 100).toInt()}%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Volume change error: $e');
      }
    }
  }

  // ===== CLEANUP =====

  /// Stop all audio & cleanup
  Future<void> stopAll() async {
    await _stopAudio(_mainPlayer);
    await _stopAudio(_introPlayer);
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _mainPlayer.dispose();
    _introPlayer.dispose();
    super.dispose();
  }

  // ===== DEBUG =====

  @override
  String toString() {
    return 'AudioService(playing: $_isPlaying, track: $_currentTrack)';
  }
}

// ===== HELPER CLASS =====

/// Audio item untuk sequenced playback
class AudioItem {
  final String assetPath;
  final double volume;
  final Duration? delay;
  final Duration? duration;

  const AudioItem(
    this.assetPath, {
    this.volume = 1.0,
    this.delay,
    this.duration,
  });
}