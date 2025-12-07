// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel()
      ..name = fields[0] as String
      ..birthdate = fields[1] as DateTime?
      ..hijriDOB = fields[11] as String?
      ..avatarPath = fields[12] as String?
      ..treeLevel = fields[2] as int
      ..totalPoints = fields[3] as int
      ..dailyFardhuLog = (fields[4] as Map).cast<String, bool>()
      ..dailyAmalanLog = (fields[5] as Map).cast<String, bool>()
      ..selawatCountToday = fields[6] as int
      ..lastResetDate = fields[7] as DateTime?
      ..adhanModeIndex = fields[10] as int;
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthdate)
      ..writeByte(11)
      ..write(obj.hijriDOB)
      ..writeByte(12)
      ..write(obj.avatarPath)
      ..writeByte(2)
      ..write(obj.treeLevel)
      ..writeByte(3)
      ..write(obj.totalPoints)
      ..writeByte(4)
      ..write(obj.dailyFardhuLog)
      ..writeByte(5)
      ..write(obj.dailyAmalanLog)
      ..writeByte(6)
      ..write(obj.selawatCountToday)
      ..writeByte(7)
      ..write(obj.lastResetDate)
      ..writeByte(10)
      ..write(obj.adhanModeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
