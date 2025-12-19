// lib/models/sidebar_state_model.dart (FULL FIX: PARAMETERIZED TOGGLE)

import 'package:flutter/material.dart';

/// Model untuk manage sidebar & flyout panel state
///
/// Features:
/// - Toggle logic dengan animation support
/// - Menu history tracking
/// - Auto-close untuk special menus (Infaq)
/// - Visibility toggle on scroll (Phantom Mode)
class SidebarStateModel extends ChangeNotifier {
  // ===== CONSTANTS =====
  static const double _defaultDockWidth = 60.0;
  static const double _defaultFlyoutWidth = 300.0;

  // ===== STATE =====
  String? _activeMenuId;
  final List<String> _menuHistory = [];
  bool _isAnimating = false;
  
  // ✅ STATE: VISIBILITY (PHANTOM MODE)
  bool _isVisible = true; 

  // ===== GETTERS =====

  /// Current active menu ID
  String? get activeMenuId => _activeMenuId;

  /// Check if any menu is open
  bool get isMenuOpen => _activeMenuId != null;

  /// Check if sidebar is closed
  bool get isClosed => _activeMenuId == null;

  double get dockWidth => _defaultDockWidth;
  double get flyoutWidth => _defaultFlyoutWidth;
  bool get isAnimating => _isAnimating;
  String? get previousMenu => _menuHistory.isNotEmpty ? _menuHistory.last : null;
  bool get isVisible => _isVisible;

  /// Tajuk Menu untuk Flyout Panel
  String get menuTitle {
    switch (_activeMenuId) {
      case 'profil': return 'Profil Pengguna';
      case 'kalendar': return 'Kalendar Islam';
      case 'sirah': return 'Sirah Nabi';
      case 'peristiwa': return 'Peristiwa Penting';
      case 'notifikasi': return 'Tetapan Notifikasi';
      case 'info': return 'Tentang Aplikasi';
      case 'tree_progress': return 'Pohon Amal';
      case 'birthday': return 'Hari Lahir';
      case 'qiblat': return 'Arah Qiblat';
      case 'quran': return 'Al-Quran';
      case 'infaq': return 'Infaq Pembangunan';
      default: return 'Menu';
    }
  }

  // ===== PUBLIC METHODS =====

  /// ✅ FIX UTAMA: Toggle Menu kini terima ID
  void toggleMenu(String menuId) {
    // KES 1: Butang Hamburger ('menu' atau kosong)
    if (menuId == 'menu' || menuId.isEmpty) {
      if (_activeMenuId != null) {
        // Kalau dah buka, tutup
        closeMenu();
      } else {
        // Kalau tutup, buka profil atau menu terakhir
        _activeMenuId = _menuHistory.isNotEmpty ? _menuHistory.last : 'profil';
        _isVisible = true; // Paksa muncul
        notifyListeners();
      }
      return;
    }

    // KES 2: Item Menu Biasa (Profil, Sirah, dll)
    if (_activeMenuId != null && _activeMenuId != menuId) {
      _menuHistory.add(_activeMenuId!); // Simpan history
    }
    
    if (_activeMenuId == menuId) {
      closeMenu(); // Tutup jika tekan benda sama
    } else {
      _activeMenuId = menuId; // Buka menu baru
      _isVisible = true; // Paksa muncul
      notifyListeners();
    }
  }

  /// Close the menu
  void closeMenu() {
    _activeMenuId = null;
    notifyListeners();
  }

  /// Start animation
  void startAnimation() {
    _isAnimating = true;
    notifyListeners();
  }

  /// Stop animation
  void stopAnimation() {
    _isAnimating = false;
    notifyListeners();
  }

  /// Navigate back in menu history
  bool navigateBack() {
    if (_menuHistory.isEmpty) {
      closeMenu();
      return false;
    }
    final previousMenuId = _menuHistory.removeLast();
    _activeMenuId = previousMenuId;
    notifyListeners();
    return true;
  }

  /// Check if specific menu is active
  bool isMenuActive(String menuId) => _activeMenuId == menuId;

  // ✅ PHANTOM MODE: KAWAL VISIBILITY BILA SCROLL
  void setSidebarVisibility(bool visible) {
    // Jika menu sedang terbuka, JANGAN sorok sidebar
    if (isMenuOpen) {
      if (!_isVisible) {
        _isVisible = true;
        notifyListeners();
      }
      return;
    }

    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }

  // ===== SPECIAL MENU HANDLERS =====
  void handleInfaqMenu() {
    closeMenu();
  }

  // ===== DEBUG HELPERS =====
  void reset() {
    _activeMenuId = null;
    _menuHistory.clear();
    _isAnimating = false;
    _isVisible = true;
    notifyListeners();
  }
}
