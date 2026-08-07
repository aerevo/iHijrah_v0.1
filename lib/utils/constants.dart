// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
// WARNA TERAS — Tema Cerah
// ═══════════════════════════════════════════

// ── Latar & Permukaan ──────────────────────
const Color kBgBase       = Color(0xFFF7F8FA);
const Color kBgSoft       = Color(0xFFEDF0F4);
const Color kSurfaceCard  = Color(0xFFFFFFFF);

// ── LATAR EDITORIAL EPUB ─────────────────────────────────────
// Dipakai oleh Scaffold feed (home.dart → palette.background siang).
// V7 FeedCard dah unboxed — post terapung terus atas warna ini.
// Pilih mana-mana satu, set sebagai FeedPalette.day.background.
const Color kScreenCream  = Color(0xFFF7F3EA); // ← aktif (Dribbble Radiant)
const Color kEpubLight    = Color(0xFFFAF6EE); // lebih cerah, macam Kindle
const Color kEpubSepia    = Color(0xFFEDE8DC); // lebih pekat, vintage

// ── Navy/Teal — WARNA UTAMA ──────────────────
const Color kPrimaryNavy     = Color(0xFF1B3A63);
const Color kPrimaryNavyDeep = Color(0xFF12294A);
const Color kPrimaryTeal     = Color(0xFF1AA3B0);
const Color kRailIconMuted   = Color(0xFFB8C4D6);

// ── Emas 3D — rel kiri ───────────────────────
const Color kGoldHighlight = Color(0xFFFBEBC0);
const Color kGoldMid       = Color(0xFFE0AC2E);
const Color kGoldDeep      = Color(0xFF8A6215);
const Color kGoldBronze    = Color(0xFF4A3410);
const Color kRailTextDark  = Color(0xFF3D2E0F);

const LinearGradient kRailGoldGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [kGoldHighlight, kGoldMid, kGoldMid, kGoldDeep, kGoldBronze],
  stops: [0.0, 0.22, 0.68, 0.9, 1.0],
);

// ── Hijau Muda — rel ────────────────────────
const Color kRailGreenLight  = Color(0xFFEAF7EE);
const Color kRailGreenMid    = Color(0xFFCDEBD6);
const Color kRailGreenDeep   = Color(0xFFA9DDBC);
const Color kRailGreenText   = Color(0xFF2F6B47);
const Color kRailGreenActive = Color(0xFF0F6B3E);

const LinearGradient kRailGreenGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [kRailGreenLight, kRailGreenMid, kRailGreenDeep],
  stops: [0.0, 0.55, 1.0],
);

// ═══════════════════════════════════════════
// REL KIRI — TEMA KACA GELAP
// ═══════════════════════════════════════════
const Color kGlassRailBase   = Color(0xFF13233F);
const Color kGlassRailDeep   = Color(0xFF070D1A);
const Color kGlassRailBorder = Color(0x26FFFFFF);
const Color kGlassTextDim    = Color(0xFFA9B8CE);
const Color kGlassTextBright = Color(0xFFF5ECD8);

const LinearGradient kGlassRailGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xE01A2C4C), Color(0xE013233F), Color(0xF2070D1A)],
  stops: [0.0, 0.55, 1.0],
);

const Color kGlassRailBaseGreen = Color(0xFF13301D);
const Color kGlassRailDeepGreen = Color(0xFF060F09);
const LinearGradient kGlassRailGradientGreen = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xE01F4A2C), Color(0xE013301D), Color(0xF2060F09)],
  stops: [0.0, 0.55, 1.0],
);

const LinearGradient kGlassActiveGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kGoldLight, kPrimaryGold, kGoldDark],
);

// ── Jenama Emas — aksen ──────────────────────
const Color kPrimaryGold = Color(0xFFC79A38);
const Color kGoldLight   = Color(0xFFE8C46B);
const Color kGoldDark    = Color(0xFF96721F);

const Color kRailGoldActive   = Color(0xFFF5D97A);
const Color kRailGoldInactive = Color(0xFF9B7B34);

// ── Aksen Fungsian ────────────────────────────
const Color kAccentBlue    = Color(0xFF4A90D9);
const Color kAccentCoral   = Color(0xFFFF6F5E);
const Color kAccentEmerald = Color(0xFF159E71);
const Color kAccentTeal    = Color(0xFF2AA7C4);

// ── Teks ──────────────────────────────────────
const Color kTextPrimary   = Color(0xFF1A1D24);
const Color kTextSecondary = Color(0xFF5F6672);
const Color kTextMuted     = Color(0xFF9AA1AC);

// ── Garis & Status ───────────────────────────
const Color kBorderSubtle = Color(0xFFE6E9EE);
const Color kWarningRed   = Color(0xFFEF4444);
const Color kSuccessGreen = Color(0xFF22C55E);

// ── ALIAS WARISAN ─────────────────────────────
const Color kBackgroundDark = kBgBase;
const Color kSurfaceDark    = kBgSoft;
const Color kCardDark       = kSurfaceCard;
const Color kAccentOlive    = kAccentEmerald;
const Color kAccentGreen    = kAccentEmerald;

// ═══════════════════════════════════════════
// WARNA KOMUNITI & FEED (jenis kandungan)
// ═══════════════════════════════════════════
const Color kTypeVideo   = kAccentEmerald;
const Color kTypeArticle = kPrimaryGold;
const Color kTypeEvent   = kPrimaryNavy;
const Color kTypeQuote   = kGoldDark;
const Color kTypeHadith  = Color(0xFFC79A38);
const Color kTypeAmalan  = Color(0xFF33B673);
const Color kTypeSirah   = Color(0xFF2AA7C4);

// ── FEED — latar & permukaan hangat ──────────
// kFeedBgGradient & kFeedCardSurface kekal untuk skrin lain
// yang mungkin masih pakai. Feed utama kini guna kScreenCream
// melalui FeedPalette.day.background (feed_theme.dart).
const LinearGradient kFeedBgGradient = LinearGradient(
  colors: [Color(0xFFFAF8F4), Color(0xFFF5F2EB)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const Color kFeedCardSurface = Color(0xFFFCFCFA);

// ═══════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════
const LinearGradient kGoldGradient = LinearGradient(
  colors: [Color(0xFF96721F), Color(0xFFE8C46B), Color(0xFFC79A38)],
  stops: [0.0, 0.5, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kNavyGradient = LinearGradient(
  colors: [kPrimaryNavy, kPrimaryNavyDeep],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient kBgGradient = LinearGradient(
  colors: [Color(0xFFFBFCFD), Color(0xFFF7F8FA)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient kCardGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFFFCFAF5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ═══════════════════════════════════════════
// SHADOWS
// ═══════════════════════════════════════════
const List<Shadow> kTextShadow = [
  Shadow(color: Color(0x66000000), blurRadius: 6,  offset: Offset(0, 1)),
  Shadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 2)),
];

BoxShadow kGoldGlow({double opacity = 0.18}) => BoxShadow(
  color: kPrimaryGold.withOpacity(opacity),
  blurRadius: 20,
  spreadRadius: 2,
);

BoxShadow kCardShadow({double opacity = 0.05}) => BoxShadow(
  color: Colors.black.withOpacity(opacity),
  blurRadius: 18,
  offset: const Offset(0, 6),
);

// kFeedCardShadows — dikekalkan untuk kegunaan lain.
// FeedCard V7 (unboxed) tak guna shadows ini lagi.
List<BoxShadow> kFeedCardShadows() => [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 20,
    offset: const Offset(0, 8),
  ),
  BoxShadow(
    color: Colors.white.withOpacity(0.7),
    blurRadius: 0,
    spreadRadius: 0,
    offset: const Offset(0, -1),
  ),
];

// ═══════════════════════════════════════════
// LOKASI DEFAULT (Kuala Lumpur)
// ═══════════════════════════════════════════
const double DEFAULT_LATITUDE  = 3.140853;
const double DEFAULT_LONGITUDE = 101.693207;

// ═══════════════════════════════════════════
// SAIZ & SPACING
// ═══════════════════════════════════════════
class AppSizes {
  static const double sidebarWidth   = 72.0;
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

// ═══════════════════════════════════════════
// GLASS SYSTEM
// ═══════════════════════════════════════════
class AppBlur {
  static const double level1 = 9.0;
  static const double level2 = 18.0;
  static const double level3 = 32.0;
}

class AppStroke {
  static const double hairline = 0.6;
  static const double thin     = 0.8;
  static const double regular  = 1.0;
  static const double bold     = 1.4;
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
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
  static const Curve snap   = Curves.easeInOutCubic;
}

// ═══════════════════════════════════════════
// ASSETS
// ═══════════════════════════════════════════
class AppAssets {
  static const String imagesPath = 'assets/images/';
  static const String videosPath = 'assets/videos/';
  static const String audioPath  = 'assets/sounds/';
  static const String animPath   = 'assets/animations/';
  static const String dataPath   = 'assets/data/';
  static const String fontsPath  = 'assets/fonts/';

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
  static const String intro              = '${audioPath}intro.mp3';
  static const String adhan              = '${audioPath}adhan.mp3';
  static const String splash             = '${audioPath}siraman.mp3';
  static const String suaraAlhamdulillah = '${audioPath}suara_alhamdulillah.mp3';
  static const String suaraInsyaAllah    = '${audioPath}suara_insyaaallah.mp3';
  static const String suaraHi            = '${audioPath}suara_hi.mp3';

  // DATA
  static const String sirahData    = '${dataPath}sirah_data.json';
  static const String eventData    = '${dataPath}event_data.json';
  static const String amalanSunnah = '${dataPath}amalan_sunnah.json';
  static const String hadithData   = '${dataPath}hadith_data.json';
}
