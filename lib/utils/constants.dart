// lib/utils/constants.dart
// FINAL SAFE + EMBUN ORIGINAL + TREE ASSETS
import 'package:flutter/material.dart';

// ===== WARNA TERAS (EMBUN JIWA - KEKAL) =====
const Color kPrimaryGold = Color(0xFFF6E7C1); // Original User Color
const Color kGoldDark = Color(0xFFC5A059);
const Color kBackgroundDark = Color(0xFF1A1A1A);
const Color kCardDark = Color(0xFF252525);
const Color kAccentOlive = Color(0xFF9DBA7F);
const Color kTextPrimary = Color(0xFFFAFAFA);
const Color kTextSecondary = Color(0xFFAAAAAA);
const Color kWarningRed = Color(0xFFCF6679);
const Color kSuccessGreen = Color(0xFF9DBA7F);

// ===== GRADIENT =====
const LinearGradient kShimmerGoldGradient = LinearGradient(
  colors: [Colors.white10, kPrimaryGold, Colors.white10],
  stops: [0.1, 0.5, 0.9],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [kBackgroundDark, Colors.black],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ===== DEFAULT LOCATION =====
const double DEFAULT_LATITUDE = 3.140853;
const double DEFAULT_LONGITUDE = 101.693207;

// ===== CONFIG =====
const int MIN_SELAWAT_DAILY = 100;

// ===== SIZES (Ditambah untuk support Sidebar) =====
class AppSizes {
  static const double sidebarWidth = 70.0;
  static const double flyoutWidth = 300.0;
  static const double cardRadius = 12.0;
  static const double cardRadiusLg = 20.0;
  static const double buttonHeightMd = 45.0;
  static const double buttonHeightLg = 55.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppFontSizes {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

// ===== DURATIONS =====
class AppDurations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 600);
  static const Duration slow = Duration(milliseconds: 1200);
  static const Duration pageTransition = Duration(milliseconds: 800);
  static const Duration leafFall = Duration(seconds: 6);

  static const Duration buttonPress = Duration(milliseconds: 200);
  static const Duration celebration = Duration(milliseconds: 1500);
  static const Duration levelUp = Duration(milliseconds: 3000);
}

// ===== CURVES =====
class AppCurves {
  static const Curve buttonPress = Curves.easeOut;
  static const Curve buttonRelease = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve springy = Curves.elasticOut;
}

// ===== ASSETS =====
class AppAssets {
  static const String imagesPath = 'assets/images/';
  static const String audioPath = 'assets/sounds/';
  static const String dataPath = 'assets/data/';

  // Images
  static const String logo = '${imagesPath}logo.png';
  static const String marakesh = '${imagesPath}marakesh.jpg';
  static const String profileDefault = '${imagesPath}profile_default.png';

  // ✅ INTEGRATED: POKOK ASSETS (pokok_level#.png)
  static const String treePhase1 = '${imagesPath}pokok_level1.png'; // Benih
  static const String treePhase2 = '${imagesPath}pokok_level2.png';
  static const String treePhase3 = '${imagesPath}pokok_level3.png';
  static const String treePhase4 = '${imagesPath}pokok_level4.png';
  static const String treePhase5 = '${imagesPath}pokok_level5.png'; // Matang

  // Audio
  static const String intro = '${audioPath}intro.mp3';
  static const String adhan = '${audioPath}adhan.mp3';
  static const String splash = '${audioPath}siraman.mp3';
  static const String suaraAlhamdulillah = '${audioPath}suara_alhamdulillah.mp3';
  static const String suaraInsyaAllah = '${audioPath}suara_insyaaallah.mp3';
  static const String suaraHi = '${audioPath}suara_hi.mp3';

  // JSON
  static const String sirahData = '${dataPath}sirah_data.json';
  static const String eventData = '${dataPath}events.json';
}

// ===== ENUMS =====
enum AdhanMode {
  Silent,
  Beep,
  Full,
}
