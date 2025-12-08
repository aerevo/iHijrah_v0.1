// lib/utils/settings_enums.dart

enum AdhanMode {
  /// Adhan dibisukan sepenuhnya (Senyap)
  off,

  /// Adhan dimainkan sepenuhnya dari awal hingga akhir (Hidup Penuh)
  full,

  /// Adhan dimainkan selama 15 saat sahaja (Ringkas)
  short,
}

// Enum untuk jenis-jenis solat fardhu
enum PrayerType {
  subuh,
  zohor,
  asar,
  maghrib,
  isyak,
}