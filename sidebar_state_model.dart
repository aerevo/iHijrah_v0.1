import 'package:flutter/material.dart';

/// Model untuk manage sidebar & flyout panel state
/// 
/// UPGRADED FEATURES:
/// - Expandable Sidebar logic (Width animation)
/// - Menu history tracking (Kekal dari kod asal)
/// - Auto-close logic
class SidebarStateModel extends ChangeNotifier {
  // ===== CONSTANTS =====
  static const double _collapsedWidth = 80.0; // Lebar bila tutup (Logo shj)
  static const double _expandedWidth = 260.0; // Lebar bila buka
  static const double _defaultFlyoutWidth = 300.0;

  // ===== STATE =====
  String? _activeMenuId;
  final List<String> _menuHistory = []; // Kekalkan history
  bool _isAnimating = false;
  
  // State baru untuk Sidebar Expand/Collapse
  bool _isSidebarExpanded = false; 

  // ===== GETTERS =====
  String? get activeMenuId => _activeMenuId;
  bool get isMenuOpen => _activeMenuId != null;
  bool get isClosed => _activeMenuId == null;
  bool get isAnimating => _isAnimating;
  bool get isSidebarExpanded => _isSidebarExpanded;

  // Dynamic Width (Kunci animasi sidebar)
  double get currentSidebarWidth => _isSidebarExpanded ? _expandedWidth : _collapsedWidth;
  double get flyoutWidth => _defaultFlyoutWidth;

  // Get last opened menu
  String? get previousMenu => _menuHistory.isNotEmpty ? _menuHistory.last : null;

  // ===== ACTIONS: SIDEBAR EXPANSION =====
  
  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  void setSidebarExpanded(bool value) {
    if (_isSidebarExpanded != value) {
      _isSidebarExpanded = value;
      notifyListeners();
    }
  }

  // ===== ACTIONS: MENU NAVIGATION =====

  void setActiveMenu(String menuId) {
    if (_isAnimating) return;
    _isAnimating = true;

    // Toggle logic
    if (_activeMenuId == menuId) {
      _closeMenuInternal(); // Tutup jika tekan menu sama
    } else {
      if (_activeMenuId != null) {
        _menuHistory.add(_activeMenuId!); // Simpan history
      }
      _activeMenuId = menuId;
      
      // OPTIONAL: Auto-expand sidebar bila pilih menu supaya nampak label?
      // Uncomment baris bawah jika mahu sidebar auto-buka bila pilih menu
      // _isSidebarExpanded = true; 
    }

    notifyListeners();

    // Reset flag animasi
    Future.delayed(const Duration(milliseconds: 400), () {
      _isAnimating = false;
    });
  }

  void closeMenu() {
    if (_activeMenuId == null) return;
    _closeMenuInternal();
    notifyListeners();
  }

  void _closeMenuInternal() {
    _activeMenuId = null;
    _menuHistory.clear();
  }

  // Back Navigation (Untuk butang back fizikal atau UI)
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

  // Special Handler untuk Infaq (Logic asal Kapten)
  void handleInfaqMenu() {
    closeMenu();
  }
}