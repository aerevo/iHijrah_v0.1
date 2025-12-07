// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdhanModeAdapter extends TypeAdapter<AdhanMode> {
  @override
  final int typeId = 1;

  @override
  AdhanMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdhanMode.off;
      case 1:
        return AdhanMode.full;
      case 2:
        return AdhanMode.short;
      default:
        return AdhanMode.off;
    }
  }

  @override
  void write(BinaryWriter writer, AdhanMode obj) {
    switch (obj) {
      case AdhanMode.off:
        writer.writeByte(0);
        break;
      case AdhanMode.full:
        writer.writeByte(1);
        break;
      case AdhanMode.short:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdhanModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrayerTypeAdapter extends TypeAdapter<PrayerType> {
  @override
  final int typeId = 2;

  @override
  PrayerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PrayerType.subuh;
      case 1:
        return PrayerType.zohor;
      case 2:
        return PrayerType.asar;
      case 3:
        return PrayerType.maghrib;
      case 4:
        return PrayerType.isyak;
      default:
        return PrayerType.subuh;
    }
  }

  @override
  void write(BinaryWriter writer, PrayerType obj) {
    switch (obj) {
      case PrayerType.subuh:
        writer.writeByte(0);
        break;
      case PrayerType.zohor:
        writer.writeByte(1);
        break;
      case PrayerType.asar:
        writer.writeByte(2);
        break;
      case PrayerType.maghrib:
        writer.writeByte(3);
        break;
      case PrayerType.isyak:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
