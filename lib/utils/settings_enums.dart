// lib/utils/settings_enums.dart

import 'package:hive_flutter/hive_flutter.dart';

part 'settings_enums.g.dart';

@HiveType(typeId: 1) // Pastikan typeId ini unik (jangan sama dengan UserModel)
enum AdhanMode {
  @HiveField(0)
  off,   /// Adhan dibisukan sepenuhnya (Senyap)

  @HiveField(1)
  full,  /// Adhan dimainkan sepenuhnya dari awal hingga akhir (Hidup Penuh)

  @HiveField(2)
  short, /// Adhan dimainkan selama 15 saat sahaja (Ringkas)
}

@HiveType(typeId: 2)
enum PrayerType {
  @HiveField(0)
  subuh,
  
  @HiveField(1)
  zohor,
  
  @HiveField(2)
  asar,
  
  @HiveField(3)
  maghrib,
  
  @HiveField(4)
  isyak,
}