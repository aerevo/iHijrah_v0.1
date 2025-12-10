import 'package:flutter/material.dart';

// ===== WARNA TERAS (AAA PREMIUM DARK THEME) =====
const kBackgroundDark = Color(0xFF0F0F0F);
const kCardDark = Color(0xFF1E1E1E);
const kTextPrimary = Color(0xFFFAFAFA);
const kTextSecondary = Color(0xFFB3B3B3);
const kAccentOlive = Color(0xFF9DBA7F);
const kWarningRed = Color(0xFFCF6679);
const kSuccessGreen = Color(0xFF4CAF50);
const kPrimaryGold = Color(0xFFFCF6BA); // Helper untuk gold biasa
const kGoldDark = Color(0xFFBF953F);


// ===== THE REAL GOLD (GRADIENTS) =====
const List<Color> kGoldGradientColors = [
  Color(0xFFBF953F), // Dark Gold
  Color(0xFFFCF6BA), // Light Gold / Highlight
  Color(0xFFB38728), // Dark Gold
  Color(0xFFFBF5B7), // Light Gold
  Color(0xFFAA771C), // Deep Bronze
];

const LinearGradient kGoldLinear = LinearGradient(
  colors: [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFAA771C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ===== SPACING & SIZES =====
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double screenH = 16.0;
}

class AppSizes {
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double cardRadius = 16.0;
  static const double cardRadiusLg = 24.0;
  static const double cardRadiusXl = 32.0;
  static const double buttonHeight = 55.0;
  static const double buttonHeightMd = 45.0;
  static const double sidebarWidth = 80.0;
  static const double flyoutWidth = 250.0;
}

class AppFontSizes {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration buttonPress = Duration(milliseconds: 150);
}

// ===== ASSETS (RE-MAPPED IKUT FAIL KAPTEN) =====
class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String sirahData = 'assets/data/sirah.json';
  
  // Audio Files (Pastikan nama fail sebiji dengan fail Kapten)
  static const String intro = 'assets/sounds/intro.mp3';
  static const String adhan = 'assets/sounds/adhan.mp3';
  static const String embunRingan = 'assets/sounds/embun_ringan.mp3'; // Guna utk KLIK
  static const String siraman = 'assets/sounds/siraman.mp3';
  static const String suaraAlhamdulillah = 'assets/sounds/suara_alhamdulillah.mp3'; // Guna utk REWARD
  static const String suaraInsyaAllah = 'assets/sounds/suara_insyaaallah.mp3';
  static const String suaraHi = 'assets/sounds/suara_hi.mp3';
}

const DEFAULT_LATITUDE = 3.1390;
const DEFAULT_LONGITUDE = 101.6869;
