// lib/models/sidebar_state_model.dart
import 'package:flutter/material.dart';

class SidebarStateModel extends ChangeNotifier {
  String? _activeMenuId;
  bool    _isVisible  = true;
  bool    _isExpanded = false;

  String? get activeMenuId => _activeMenuId;
  bool    get isMenuOpen   => _activeMenuId != null;
  bool    get isClosed     => _activeMenuId == null;
  bool    get isVisible    => _isVisible;
  bool    get isExpanded   => _isExpanded;

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

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void collapseRail() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  // Kembang rel secara eksplisit (bukan toggle) — selamat dipanggil
  // berulang kali (cth. dari beberapa onTap serentak / tiap scroll event)
  // sebab tak buat apa-apa kalau dah pun kembang.
  void expandRail() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  bool isMenuActive(String id) => _activeMenuId == id;

  void reset() {
    _activeMenuId = null;
    _isVisible    = true;
    _isExpanded   = false;
    notifyListeners();
  }
}
