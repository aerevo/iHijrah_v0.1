// lib/utils/constants.dart
// FINAL SAFE + EMBUN ORIGINAL
import 'package:flutter/material.dart';

// ===== WARNA TERAS (EMBUN JIWA) =====
const Color kPrimaryGold = Color(0xFFF6E7C1);
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

// ===== SPACING =====
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const double screenH = 20;
  static const double screenV = 20;
}

// ===== SIZES =====
class AppSizes {
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;

  static const double treeContainer = 350;
  static const double treeImage = 300;
  static const double treeGlow = 200;

  static const double cardRadius = 12;
  static const double cardRadiusLg = 16;
  static const double cardRadiusXl = 20;

  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 50;
  static const double buttonHeightLg = 55;

  static const double sidebarWidth = 70;
  static const double flyoutWidth = 300;
}

// ===== FONT SIZES =====
class AppFontSizes {
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 24;
  static const double xxxl = 28;
}

// ===== DURATIONS =====
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(seconds: 1);
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
  static const String marakesh = '${imagesPath}marakesh.jpg';
  static const String profileDefault = '${imagesPath}profile_default.png';

  // Audio
  static const String intro = '${audioPath}intro.mp3';
  static const String adhan = '${audioPath}adhan.mp3';
  static const String splash = '${audioPath}siraman.mp3';
  static const String suaraAlhamdulillah = '${audioPath}suara_alhamdulillah.mp3';
  static const String suaraInsyaAllah = '${audioPath}suara_insyaaallah.mp3';
  static const String suaraHi = '${audioPath}suara_hi.mp3';

  // JSON
  static const String sirahData = '${dataPath}sirah_data.json';
  static const String eventData = '${dataPath}event_data.json';
  static const String amalanSunnahData = '${dataPath}amalan_sunnah.json';
}