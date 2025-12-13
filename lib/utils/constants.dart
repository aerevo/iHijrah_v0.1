// lib/utils/constants.dart (UPGRADED EMBUN UI)
import 'package:flutter/material.dart';

// ===== WARNA TERAS (TEMA: EMBUN JIWA) =====
const kPrimaryGold = Color(0xFFF6E7C1);
const kGoldDark = Color(0xFFC5A059);
const kBackgroundDark = Color(0xFF1A1A1A);
const kCardDark = Color(0xFF252525);
const kAccentOlive = Color(0xFF9DBA7F);
const kTextPrimary = Color(0xFFFAFAFA);
const kTextSecondary = Color(0xFFAAAAAA);
const kWarningRed = Color(0xFFCF6679);
const kSuccessGreen = Color(0xFF9DBA7F); // ✅ Added

// ===== GRADIENT & SHADER =====
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

// ===== LOKASI DEFAULT (Kuala Lumpur) =====
const double DEFAULT_LATITUDE = 3.140853;
const double DEFAULT_LONGITUDE = 101.693207;

// ===== CONFIG =====
const int MIN_SELAWAT_DAILY = 100;

// ===== SPACING SYSTEM =====
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  static const double screenH = 20.0;
  static const double screenV = 20.0;
}

// ===== SIZE SYSTEM =====
class AppSizes {
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;

  static const double treeContainer = 350.0;
  static const double treeImage = 300.0;
  static const double treeGlow = 200.0;

  static const double cardRadius = 12.0;
  static const double cardRadiusLg = 16.0;
  static const double cardRadiusXl = 20.0;

  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 50.0;
  static const double buttonHeightLg = 55.0;

  static const double sidebarWidth = 70.0;
  static const double flyoutWidth = 300.0;
}

// ===== FONT SIZES =====
class AppFontSizes {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
}

// ===== DURATIONS =====
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(seconds: 1);
  static const Duration leafFall = Duration(seconds: 6);

  // ✅ EMBUN UI ADDITIONS
  static const Duration buttonPress = Duration(milliseconds: 200);
  static const Duration celebration = Duration(milliseconds: 1500);
  static const Duration levelUp = Duration(milliseconds: 3000);
}

// ===== ANIMATION CURVES =====
class AppCurves { // ✅ EMBUN UI ADDITIONS
  static const Curve buttonPress = Curves.easeOut;
  static const Curve buttonRelease = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve springy = Curves.elasticOut;
}

// ===== ASET PATH =====
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

  // JSON Data
  static const String sirahData = '${dataPath}sirah_data.json';
  static const String eventData = '${dataPath}event_data.json';
  static const String amalanSunnahData = '${dataPath}amalan_sunnah.json';
}