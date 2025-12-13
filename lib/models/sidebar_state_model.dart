// lib/models/sidebar_state_model.dart

import 'package:flutter/material.dart';

class SidebarStateModel extends ChangeNotifier {
  // ===== CONSTANTS =====
  static const double _collapsedWidth = 80.0; // Lebar bila tutup (Icon shj)
  static const double _expandedWidth = 288.0; // Lebar bila buka (Detail)
  static const double _flyoutWidth = 300.0;

  // ===== STATE =====
  String? _activeMenuId = "HOME"; // Default home
  final List<String> _menuHistory = [];
  bool _isAnimating = false;
  
  // LOGIK BARU: Sidebar Kembang/Kuncup
  bool _isSidebarExpanded = true; 

  // ===== GETTERS =====
  String? get activeMenuId => _activeMenuId;
  bool get isMenuOpen => _activeMenuId != null;
  bool get isAnimating => _isAnimating;
  
  // Getter Lebar Sidebar (Dinamik)
  double get currentSidebarWidth => _isSidebarExpanded ? _expandedWidth : _collapsedWidth;
  bool get isSidebarExpanded => _isSidebarExpanded;

  String? get previousMenu => _menuHistory.isNotEmpty ? _menuHistory.last : null;

  // ===== METHODS =====

  // Toggle Saiz Sidebar (Kecil <-> Besar)
  void toggleSidebarSize() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  void setActiveMenu(String menuId) {
    if (_isAnimating) return;
    _isAnimating = true;

    if (_activeMenuId == menuId) {
      // Kalau tekan menu sama, tak perlu close sidebar, mungkin just refresh content
      // Atau ikut logic asal: close flyout (kalau ada)
    } else {
      if (_activeMenuId != null) {
        _menuHistory.add(_activeMenuId!);
      }
      _activeMenuId = menuId;
    }

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      _isAnimating = false;
    });
  }

  void reset() {
    _activeMenuId = "HOME";
    _menuHistory.clear();
    _isAnimating = false;
    _isSidebarExpanded = true;
    notifyListeners();
  }
}
