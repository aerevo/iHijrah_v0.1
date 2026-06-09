// lib/models/sidebar_state_model.dart
import 'package:flutter/material.dart';

class SidebarStateModel extends ChangeNotifier {
  String? _activeMenuId;
  bool    _isVisible = true;

  String? get activeMenuId => _activeMenuId;
  bool    get isMenuOpen   => _activeMenuId != null;
  bool    get isClosed     => _activeMenuId == null;
  bool    get isVisible    => _isVisible;

  void setActiveMenu(String id) {
    if (_activeMenuId == id) {
      closeMenu();
    } else {
      _activeMenuId = id;
      _isVisible    = true;
      notifyListeners();
    }
  }

  void closeMenu() {
    _activeMenuId = null;
    notifyListeners();
  }

  void setSidebarVisibility(bool visible) {
    // Jangan sorok bila menu terbuka
    if (isMenuOpen && !visible) return;
    if (_isVisible == visible) return;
    _isVisible = visible;
    notifyListeners();
  }

  bool isMenuActive(String id) => _activeMenuId == id;

  void reset() {
    _activeMenuId = null;
    _isVisible    = true;
    notifyListeners();
  }
}
