// lib/models/animation_controller_model.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';

/// Model untuk control particle spray animations (Lottie water splash)
/// 
/// Features:
/// - Anti-spam protection (prevent multiple rapid triggers)
/// - Auto-cleanup after animation completes
/// - Queue system untuk multiple triggers
class AnimationControllerModel extends ChangeNotifier {
  // ===== STATE =====
  bool _shouldSprayParticles = false;
  bool _isProcessing = false;
  int _queuedTriggers = 0;

  // ===== GETTERS =====
  
  /// Check if animation should play
  bool get shouldSprayParticles => _shouldSprayParticles;
  
  /// Check if currently processing
  bool get isProcessing => _isProcessing;
  
  /// Get number of queued animations
  int get queuedCount => _queuedTriggers;

  // ===== PUBLIC METHODS =====

  /// Trigger particle spray animation dengan anti-spam
  /// 
  /// Returns: true if triggered, false if blocked by anti-spam
  Future<bool> triggerParticleSpray() async {
    // Anti-spam: Block jika sedang process
    if (_isProcessing) {
      // Queue untuk play selepas current animation habis
      _queuedTriggers++;
      if (_queuedTriggers > 3) {
        // Max 3 dalam queue, lebih dari tu ignore
        return false;
      }
      return false;
    }

    await _playAnimation();
    
    // Process queue jika ada
    if (_queuedTriggers > 0) {
      _queuedTriggers--;
      // Delay sikit sebelum play queued animation
      await Future.delayed(const Duration(milliseconds: 500));
      await _playAnimation();
    }
    
    return true;
  }

  /// Play animation sequence
  Future<void> _playAnimation() async {
    _isProcessing = true;
    _shouldSprayParticles = true;
    notifyListeners(); // Trigger animation start

    // Duration match dengan Lottie animation
    await Future.delayed(const Duration(seconds: 2));

    // Reset state
    _shouldSprayParticles = false;
    _isProcessing = false;
    notifyListeners(); // Trigger animation end
  }

  /// Force stop animation (emergency brake)
  void stopAnimation() {
    _shouldSprayParticles = false;
    _isProcessing = false;
    _queuedTriggers = 0;
    notifyListeners();
  }

  /// Clear animation queue
  void clearQueue() {
    _queuedTriggers = 0;
  }

  // ===== LEGACY SUPPORT =====

  /// Legacy method - untuk backward compatibility
  @Deprecated('Use triggerParticleSpray() instead')
  void setShouldAnimate(bool val) {
    if (val && !_isProcessing) {
      triggerParticleSpray();
    }
  }

  // ===== DEBUG HELPERS =====

  @override
  String toString() {
    return 'AnimationControllerModel(playing: $_shouldSprayParticles, '
           'processing: $_isProcessing, queued: $_queuedTriggers)';
  }
}