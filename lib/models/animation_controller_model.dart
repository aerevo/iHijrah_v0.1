// lib/models/animation_controller_model.dart (FIXED V2)
import 'package:flutter/material.dart';

class AnimationControllerModel extends ChangeNotifier {
  bool _shouldSprayParticles = false;
  bool _isProcessing = false;
  int _queuedTriggers = 0;

  bool get shouldSprayParticles => _shouldSprayParticles;
  bool get isProcessing => _isProcessing;

  Future<bool> triggerParticleSpray() async {
    if (_isProcessing) {
      if (_queuedTriggers < 3) _queuedTriggers++;
      return false;
    }
    await _playAnimation();
    if (_queuedTriggers > 0) {
      _queuedTriggers--;
      await Future.delayed(const Duration(milliseconds: 500));
      await _playAnimation();
    }
    return true;
  }

  Future<void> _playAnimation() async {
    _isProcessing = true;
    _shouldSprayParticles = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _shouldSprayParticles = false;
    _isProcessing = false;
    notifyListeners();
  }

  // ✅ FIX: Added missing method
  void resetParticleSpray() {
    _shouldSprayParticles = false;
    notifyListeners();
  }

  void stopAnimation() {
    _shouldSprayParticles = false;
    _isProcessing = false;
    _queuedTriggers = 0;
    notifyListeners();
  }
}