// lib/utils/constants.dart - ENHANCED AAA PALETTE
import 'package:flutter/material.dart';

// ===== ENHANCED COLOR SYSTEM =====
// Primary Gold - Lebih vibrant & warm
const Color kPrimaryGold = Color(0xFFFFD700); // Pure gold
const Color kGoldLight = Color(0xFFFFE55C); // Light gold highlight
const Color kGoldDark = Color(0xFFB8860B); // Dark goldenrod
const Color kGoldAccent = Color(0xFFFFA500); // Orange gold

// Background - Richer blacks with subtle variations
const Color kBackgroundDark = Color(0xFF0A0A0A); // Deep black
const Color kBackgroundMid = Color(0xFF1A1A1A); // Mid black
const Color kCardDark = Color(0xFF1E1E1E); // Card background
const Color kCardElevated = Color(0xFF252525); // Elevated cards

// Accent Colors - More vibrant & diverse
const Color kAccentOlive = Color(0xFF90C695); // Softer green
const Color kAccentEmerald = Color(0xFF50C878); // Emerald accent
const Color kAccentTeal = Color(0xFF00CED1); // Teal highlight
const Color kAccentCyan = Color(0xFF00FFFF); // Bright cyan

// Text - Better hierarchy
const Color kTextPrimary = Color(0xFFFFFFFFF); // Pure white
const Color kTextSecondary = Color(0xFFB0B0B0); // Medium gray
const Color kTextTertiary = Color(0xFF707070); // Subtle gray
const Color kTextMuted = Color(0xFF404040); // Very subtle

// Status Colors - More distinctive
const Color kWarningRed = Color(0xFFFF4444); // Bright red
const Color kSuccessGreen = Color(0xFF4CAF50); // Material green
const Color kInfoBlue = Color(0xFF2196F3); // Info blue
const Color kWarningOrange = Color(0xFFFF9800); // Warning orange

// ===== ENHANCED GRADIENTS =====
const LinearGradient kGoldGradient = LinearGradient(
  colors: [kGoldLight, kPrimaryGold, kGoldDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kShimmerGoldGradient = LinearGradient(
  colors: [Colors.white10, kPrimaryGold, kGoldLight, Colors.white10],
  stops: [0.0, 0.4, 0.6, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [kBackgroundDark, kBackgroundMid, Color(0xFF0F0F0F)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Gradient untuk cards - subtle & elegant
const LinearGradient kCardGradient = LinearGradient(
  colors: [kCardElevated, kCardDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient untuk glass effect
const LinearGradient kGlassGradient = LinearGradient(
  colors: [
    Color(0x20FFFFFF),
    Color(0x10FFFFFF),
    Color(0x05FFFFFF),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ===== DEFAULT LOCATION =====
const double DEFAULT_LATITUDE = 3.140853;
const double DEFAULT_LONGITUDE = 101.693207;

// ===== ENHANCED SIZES =====
class AppSizes {
  static const double sidebarWidth = 60.0;
  static const double flyoutWidth = 320.0; // Slightly wider
  
  static const double cardRadius = 16.0; // Increased from 12
  static const double cardRadiusLg = 24.0; // Increased from 20
  static const double cardRadiusXl = 32.0; // Increased from 30
  
  static const double buttonHeightMd = 48.0; // Increased from 45
  static const double buttonHeightLg = 56.0; // Increased from 55
  
  static const double iconXs = 14.0;
  static const double iconSm = 18.0; // Increased from 16
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  
  static const double treeContainer = 320.0;
  static const double treeGlow = 300.0;
  static const double treeImage = 250.0;
  
  // New: Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
}

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  static const double screenH = 4.0;
  static const double screenV = 20.0;
}

class AppFontSizes {
  static const double xxs = 9.0;
  static const double xs = 11.0; // Increased from 10
  static const double sm = 13.0; // Increased from 12
  static const double md = 15.0; // Increased from 14
  static const double lg = 17.0; // Increased from 16
  static const double xl = 21.0; // Increased from 20
  static const double xxl = 26.0; // Increased from 24
  static const double xxxl = 32.0; // New
}

// ===== DURATIONS =====
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  
  static const Duration leafFall = Duration(seconds: 6);
  static const Duration buttonPress = Duration(milliseconds: 150);
  static const Duration buttonRelease = Duration(milliseconds: 200);
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
  static const Curve snap = Curves.easeInOutCubic;
}

// ===== ASSETS =====
class AppAssets {
  static const String imagesPath = 'assets/images/';
  static const String audioPath = 'assets/sounds/';
  static const String dataPath = 'assets/data/';
  
  static const String logo = '${imagesPath}logo.png';
  static const String profileDefault = '${imagesPath}profile_default.png';
  
  // Dynamic Backgrounds
  static const String bgDay = '${imagesPath}sunnah_mekah.png';
  static const String bgNight = '${imagesPath}masjid_nabawi.png';
  static const String bgPattern = '${imagesPath}latar_corak.png';
  
  // Tree phases
  static const String treePhase1 = '${imagesPath}pokok_level1.png';
  static const String treePhase2 = '${imagesPath}pokok_level2.png';
  static const String treePhase3 = '${imagesPath}pokok_level3.png';
  static const String treePhase4 = '${imagesPath}pokok_level4.png';
  static const String treePhase5 = '${imagesPath}pokok_level5.png';
  
  // Audio
  static const String intro = '${audioPath}intro.mp3';
  static const String adhan = '${audioPath}adhan.mp3';
  static const String splash = '${audioPath}siraman.mp3';
  static const String suaraAlhamdulillah = '${audioPath}suara_alhamdulillah.mp3';
  static const String suaraInsyaAllah = '${audioPath}suara_insyaaallah.mp3';
  static const String suaraHi = '${audioPath}suara_hi.mp3';
  
  // JSON Data
  static const String sirahData = '${dataPath}sirah_data.json';
  static const String eventData = '${dataPath}events.json';
  static const String amalanSunnahData = '${dataPath}amalan_sunnah.json';
}

// ===== SHADOWS =====
class AppShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: kPrimaryGold.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}

// ===== BORDERS =====
class AppBorders {
  static Border get subtle => Border.all(
    color: Colors.white.withOpacity(0.05),
    width: 1,
  );
  
  static Border get normal => Border.all(
    color: Colors.white.withOpacity(0.1),
    width: 1,
  );
  
  static Border get gold => Border.all(
    color: kPrimaryGold.withOpacity(0.3),
    width: 1,
  );
  
  static Border get goldBright => Border.all(
    color: kPrimaryGold,
    width: 2,
  );
}
