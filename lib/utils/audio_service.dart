// lib/utils/audio_service.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'constants.dart';

class AudioService with ChangeNotifier {

  final AudioPlayer _main = AudioPlayer();
  final AudioPlayer _sfx  = AudioPlayer();
  Timer? _stopTimer;

  // ── PRIVATE HELPER ────────────────────────────────────────────
  Future<void> _play(
    AudioPlayer player,
    String path, {
    double volume = 1.0,
    Duration? stopAfter,
  }) async {
    try {
      await player.stop();
      await player.setVolume(volume);
      await player.play(AssetSource(path));
      if (stopAfter != null) {
        _stopTimer?.cancel();
        _stopTimer = Timer(stopAfter, () => player.stop());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService._play: $e');
    }
  }

  // ── PUBLIC API ────────────────────────────────────────────────

  /// Audio intro splash
  Future<void> playIntroAudio() => _play(
    _main, AppAssets.splash,
    volume: 0.8,
    stopAfter: const Duration(milliseconds: 1500),
  );

  /// Bunyi siraman pokok
  Future<void> playSiraman() => _play(
    _sfx, AppAssets.splash, // ganti dengan sounds/siraman.mp3 bila ada
    volume: 0.9,
    stopAfter: const Duration(seconds: 3),
  );

  /// Azan — ambil modeIndex dari UserModel terus
  Future<void> playAdhan({int modeIndex = 2}) async {
    if (modeIndex == 0) return; // off
    await _play(_main, AppAssets.adhan, volume: 1.0);
    if (modeIndex == 2) {
      // tone — stop selepas 15 saat
      _stopTimer?.cancel();
      _stopTimer = Timer(
        const Duration(seconds: 15),
        () => _main.stop(),
      );
    }
  }

  /// Suara Alhamdulillah
  Future<void> playAlhamdulillah() => _play(
    _main, AppAssets.suaraAlhamdulillah,
    stopAfter: const Duration(seconds: 3),
  );

  /// Suara InsyaAllah
  Future<void> playInsyaallah() => _play(
    _main, AppAssets.suaraInsyaAllah,
    stopAfter: const Duration(seconds: 3),
  );

  /// Prompt zikir
  Future<void> playZikirPrompt() => _play(
    _main, AppAssets.suaraHi,
    stopAfter: const Duration(seconds: 2),
  );

  Future<void> stopAll() async {
    _stopTimer?.cancel();
    await _main.stop();
    await _sfx.stop();
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _main.dispose();
    _sfx.dispose();
    super.dispose();
  }
}
