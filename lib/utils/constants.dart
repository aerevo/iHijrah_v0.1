// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
// WARNA TERAS
// ═══════════════════════════════════════════
const Color kPrimaryGold    = Color(0xFFC9A84C); // Emas matang
const Color kGoldLight      = Color(0xFFE8C97A); // Emas cerah (heading)
const Color kGoldDark       = Color(0xFF8B6914); // Emas gelap (shadow)
const Color kBackgroundDark = Color(0xFF080C18); // Biru malam sangat gelap
const Color kSurfaceDark    = Color(0xFF0F1628); // Surface card
const Color kCardDark       = Color(0xFF151E35); // Kad
const Color kAccentOlive    = Color(0xFF9DBA7F); // Hijau zaitun
const Color kAccentTeal     = Color(0xFF38BDF8); // Biru sirah
const Color kAccentGreen    = Color(0xFF4ADE80); // Hijau amalan
const Color kTextPrimary    = Color(0xFFF1F5F9); // Putih lembut
const Color kTextSecondary  = Color(0xFF94A3B8); // Kelabu
const Color kTextMuted      = Color(0xFF475569); // Dim
const Color kWarningRed     = Color(0xFFEF4444);
const Color kSuccessGreen   = Color(0xFF22C55E);
const Color kBorderSubtle   = Color(0x1AFFFFFF); // Border 10% putih

// ═══════════════════════════════════════════
// WARNA KOMUNITI & FEED
// ═══════════════════════════════════════════
const Color kTypeVideo   = Color(0xFFEF4444);
const Color kTypeArticle = Color(0xFFF59E0B);
const Color kTypeEvent   = Color(0xFF34D399);
const Color kTypeQuote   = Color(0xFFA78BFA);
const Color kTypeHadith  = Color(0xFFC9A84C);
const Color kTypeAmalan  = Color(0xFF4ADE80);
const Color kTypeSirah   = Color(0xFF38BDF8);

// ═══════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════
const LinearGradient kGoldGradient = LinearGradient(
  colors: [Color(0xFF8B6914), Color(0xFFE8C97A), Color(0xFFC9A84C)],
  stops: [0.0, 0.5, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kBgGradient = LinearGradient(
  colors: [Color(0xFF0A0E1A), Color(0xFF080C18)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient kCardGradient = LinearGradient(
  colors: [Color(0xFF151E35), Color(0xFF0F1628)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ═══════════════════════════════════════════
// SHADOWS
// ═══════════════════════════════════════════
const List<Shadow> kTextShadow = [
  Shadow(color: Color(0xCC000000), blurRadius: 8,  offset: Offset(0, 1)),
  Shadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0, 3)),
];

BoxShadow kGoldGlow({double opacity = 0.25}) => BoxShadow(
  color: kPrimaryGold.withOpacity(opacity),
  blurRadius: 20,
  spreadRadius: 2,
);

// ═══════════════════════════════════════════
// LOKASI DEFAULT (Kuala Lumpur)
// ═══════════════════════════════════════════
const double DEFAULT_LATITUDE  = 3.140853;
const double DEFAULT_LONGITUDE = 101.693207;

// ═══════════════════════════════════════════
// SAIZ & SPACING
// ═══════════════════════════════════════════
class AppSizes {
  static const double sidebarWidth   = 65.0;
  static const double flyoutWidth    = 300.0;
  static const double cardRadius     = 14.0;
  static const double cardRadiusLg   = 20.0;
  static const double cardRadiusXl   = 28.0;
  static const double buttonHeightMd = 46.0;
  static const double buttonHeightLg = 56.0;
  static const double iconSm  = 16.0;
  static const double iconMd  = 24.0;
  static const double iconLg  = 32.0;
  static const double iconXl  = 48.0;
  static const double iconXxl = 64.0;
  static const double treeContainer = 320.0;
  static const double treeGlow      = 300.0;
  static const double treeImage     = 250.0;
  static const double avatarSm      = 32.0;
  static const double avatarMd      = 44.0;
  static const double avatarLg      = 64.0;
  static const double avatarXl      = 96.0;
}

class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double screenH = 4.0;
  static const double screenV = 20.0;
}

class AppFontSizes {
  static const double xs  = 10.0;
  static const double sm  = 12.0;
  static const double md  = 14.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double d3  = 30.0;
}

// ═══════════════════════════════════════════
// DURASI & ANIMASI
// ═══════════════════════════════════════════
class AppDurations {
  static const Duration fast        = Duration(milliseconds: 200);
  static const Duration normal      = Duration(milliseconds: 300);
  static const Duration medium      = Duration(milliseconds: 500);
  static const Duration slow        = Duration(milliseconds: 800);
  static const Duration leafFall    = Duration(seconds: 6);
  static const Duration celebration = Duration(milliseconds: 1500);
  static const Duration levelUp     = Duration(milliseconds: 3000);
}

class AppCurves {
  static const Curve smooth  = Curves.easeOutCubic;
  static const Curve bounce  = Curves.elasticOut;
  static const Curve spring  = Curves.easeOutBack;
  static const Curve snap    = Curves.easeInOutCubic;
}

// ═══════════════════════════════════════════
// ASSETS
// ═══════════════════════════════════════════
class AppAssets {
  static const String imagesPath    = 'assets/images/';
  static const String videosPath    = 'assets/videos/';
  static const String audioPath     = 'assets/sounds/';
  static const String animPath      = 'assets/animations/';
  static const String dataPath      = 'assets/data/';
  static const String fontsPath     = 'assets/fonts/';

  // IMEJ
  static const String logo           = '${imagesPath}logo.png';
  static const String profileDefault = '${imagesPath}profile_default.png';
  static const String langit         = '${imagesPath}langit.png';

  // POKOK HIJRAH — VIDEO
  static const String treeV1 = '${videosPath}tree_v1.mp4';
  static const String treeV2 = '${videosPath}tree_v2.mp4';
  static const String treeV3 = '${videosPath}tree_v3.mp4';
  static const String treeV4 = '${videosPath}tree_v4.mp4';
  static const String treeV5 = '${videosPath}tree_v5.mp4';

  // AUDIO
  static const String intro               = '${audioPath}intro.mp3';
  static const String adhan               = '${audioPath}adhan.mp3';
  static const String splash              = '${audioPath}siraman.mp3';
  static const String suaraAlhamdulillah  = '${audioPath}suara_alhamdulillah.mp3';
  static const String suaraInsyaAllah     = '${audioPath}suara_insyaaallah.mp3';
  static const String suaraHi             = '${audioPath}suara_hi.mp3';

  // DATA
  static const String sirahData      = '${dataPath}sirah_data.json';
  static const String eventData      = '${dataPath}event_data.json';
  static const String amalanSunnah   = '${dataPath}amalan_sunnah.json';
  static const String hadithData     = '${dataPath}hadith_data.json';
}
