// lib/models/animation_controller_model.dart
import 'package:flutter/material.dart';

class AnimationControllerModel extends ChangeNotifier {
  bool _spraying   = false;
  bool _processing = false;
  int  _queued     = 0;

  bool get shouldSprayParticles => _spraying;
  bool get isProcessing         => _processing;

  Future<bool> triggerParticleSpray() async {
    if (_processing) {
      if (_queued < 3) _queued++;
      return false;
    }
    await _play();
    while (_queued > 0) {
      _queued--;
      await Future.delayed(const Duration(milliseconds: 400));
      await _play();
    }
    return true;
  }

  Future<void> _play() async {
    _processing = true;
    _spraying   = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _spraying   = false;
    _processing = false;
    notifyListeners();
  }

  void resetParticleSpray() {
    _spraying = false;
    notifyListeners();
  }

  void stopAnimation() {
    _spraying   = false;
    _processing = false;
    _queued     = 0;
    notifyListeners();
  }
}
