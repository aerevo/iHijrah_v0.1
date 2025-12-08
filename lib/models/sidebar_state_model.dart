// lib/models/sidebar_state_model.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';

/// Model untuk manage sidebar & flyout panel state
///
/// Features:
/// - Toggle logic dengan animation support
/// - Menu history tracking
/// - Auto-close untuk special menus (Infaq)
class SidebarStateModel extends ChangeNotifier {
  // ===== CONSTANTS =====
  static const double _defaultDockWidth = 70.0;
  static const double _defaultFlyoutWidth = 300.0;

  // ===== STATE =====
  String? _activeMenuId;
  final List<String> _menuHistory = [];
  bool _isAnimating = false;

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

  // ===== PUBLIC METHODS =====

  /// Set active menu dengan toggle logic
  ///
  /// Rules:
  /// - Tekan menu yang sama → Close
  /// - Tekan menu lain → Switch
  void setActiveMenu(String menuId) {
    // Prevent spam during animation
    if (_isAnimating) return;

    _isAnimating = true;

    // Toggle logic
    if (_activeMenuId == menuId) {
      // Sama menu → Close
      _closeMenuInternal();
    } else {
      // Lain menu → Switch
      if (_activeMenuId != null) {
        _menuHistory.add(_activeMenuId!);
      }
      _activeMenuId = menuId;
    }

    notifyListeners();

    // Reset animation flag after animation duration
    Future.delayed(const Duration(milliseconds: 400), () {
      _isAnimating = false;
    });
  }

  /// Close menu (public method)
  void closeMenu() {
    if (_activeMenuId == null) return;

    _closeMenuInternal();
    notifyListeners();
  }

  /// Internal close (no notify)
  void _closeMenuInternal() {
    _activeMenuId = null;
    _menuHistory.clear();
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
    notifyListeners();
  }

  @override
  String toString() {
    return 'SidebarStateModel(active: $_activeMenuId, '
           'open: $isMenuOpen, history: ${_menuHistory.length})';
  }
}