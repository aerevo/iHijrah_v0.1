import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'settings_enums.dart';
import 'constants.dart';

class AudioService extends ChangeNotifier {
  // Channel 1: Background / Music
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  // Channel 2: Sound Effects (SFX) - Klik, Vocal
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;

  AudioService() {
    AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
  }

  Source _getSource(String path) {
    String cleanPath = path;
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/', '');
    }
    return AssetSource(cleanPath);
  }

  /// Mainkan bunyi SFX
  Future<void> _playSfx(String path, {double volume = 1.0}) async {
    if (_isMuted) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop(); 
      }
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(_getSource(path));
    } catch (e) {
      if (kDebugMode) print("RALAT AUDIO (SFX): $e");
    }
  }

  /// Mainkan bunyi BGM
  Future<void> _playBgm(String path, {double volume = 0.5}) async {
    if (_isMuted) return;
    try {
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.play(_getSource(path));
    } catch (e) {
      if (kDebugMode) print("RALAT AUDIO (BGM): $e");
    }
  }

  // ===== PUBLIC METHODS =====

  Future<void> playIntro() async {
    await _playBgm(AppAssets.intro, volume: 1.0);
  }

  Future<void> playBismillah() async {
    await _playBgm(AppAssets.intro, volume: 0.3);
  }

  Future<void> playClick() async {
    // Bunyi klik lembut (embun_ringan.mp3)
    await _playSfx(AppAssets.embunRingan, volume: 0.5); 
  }

  /// Bunyi 1: Vocal Alhamdulillah (Mula-mula)
  Future<void> playAlhamdulillah() async {
    await _playSfx(AppAssets.suaraAlhamdulillah, volume: 1.0);
  }

  /// Bunyi 2: Siraman Air (Selepas Alhamdulillah)
  Future<void> playSiraman() async {
    await _playSfx(AppAssets.siraman, volume: 0.8);
  }

  Future<void> playInsyaallah() async {
    await _playSfx(AppAssets.suaraInsyaAllah, volume: 1.0);
  }

  Future<void> playZikirPrompt() async {
    await _playSfx(AppAssets.suaraHi, volume: 1.0);
  }

  // Azan Logic
  Future<void> playAdhan(BuildContext context) async {
    final user = Provider.of<UserModel>(context, listen: false);
    final AdhanMode currentMode = AdhanMode.values[user.adhanModeIndex];
    if (currentMode == AdhanMode.off) return;

    await _playBgm(AppAssets.adhan, volume: 1.0);
    if (currentMode == AdhanMode.short) {
      Future.delayed(const Duration(seconds: 15), () {
        _bgmPlayer.stop();
      });
    }
  }

  void stopAll() {
    _bgmPlayer.stop();
    _sfxPlayer.stop();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) stopAll();
    notifyListeners();
  }
}