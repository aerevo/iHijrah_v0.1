// lib/models/sidebar_state_model.dart (FULL CODE: PHANTOM MODE)

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
  
  // ✅ STATE BARU: VISIBILITY (PHANTOM MODE)
  // Default true (Nampak)
  bool _isVisible = true; 

  // ===== GETTERS =====

  /// Current active menu ID
  String? get activeMenuId => _activeMenuId;

  /// Check if any menu is open
  bool get isMenuOpen => _activeMenuId != null;

  /// Check if sidebar is closed
  bool get isClosed => _activeMenuId == null;

  /// Get sidebar dock width
  double get dockWidth => _defaultDockWidth;

  /// Get flyout panel width
  double get flyoutWidth => _defaultFlyoutWidth;

  /// Check if currently animating
  bool get isAnimating => _isAnimating;

  /// Get last opened menu (for back navigation)
  String? get previousMenu => _menuHistory.isNotEmpty ? _menuHistory.last : null;

  /// Check sidebar visibility
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

  /// Set active menu dengan toggle logic
  ///
  /// Rules:
  /// - Tekan menu yang sama → Close
  /// - Tekan menu lain → Switch
  void setActiveMenu(String id) {
    if (_activeMenuId != null && _activeMenuId != id) {
      // Record current menu before switching
      _menuHistory.add(_activeMenuId!);
    }
    
    if (_activeMenuId == id) {
      closeMenu();
    } else {
      _activeMenuId = id;
      // Bila buka menu, pastikan sidebar visible
      _isVisible = true; 
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

  /// Toggle menu (for FAB)
  ///
  /// Logic:
  /// - Jika closed → Open last menu atau default (profil)
  /// - Jika open → Close
  void toggleMenu() {
    if (_isAnimating) return;

    if (isMenuOpen) {
      closeMenu();
    } else {
      // Open last menu atau default
      final menuToOpen = previousMenu ?? 'profil';
      setActiveMenu(menuToOpen);
    }
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

  /// Open specific menu without toggle
  void openMenu(String menuId) {
    if (_activeMenuId != menuId) {
      setActiveMenu(menuId);
    }
  }
  
  // ✅ METHOD BARU: KAWAL VISIBILITY BILA SCROLL
  void setSidebarVisibility(bool visible) {
    // Jika menu sedang terbuka, JANGAN sorok sidebar (nanti pelik)
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

  /// Handle Infaq menu (special case - show dialog then close)
  void handleInfaqMenu() {
    // Infaq menu tak buka flyout, terus trigger dialog
    // So kita close menu selepas user click
    closeMenu();
  }

  // ===== DEBUG HELPERS =====

  /// Reset state (for testing)
  void reset() {
    _activeMenuId = null;
    _menuHistory.clear();
    _isAnimating = false;
    _isVisible = true;
    notifyListeners();
  }
}
