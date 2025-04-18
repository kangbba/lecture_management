// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonRecordAdapter extends TypeAdapter<LessonRecord> {
  @override
  final int typeId = 1;

  @override
  LessonRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonRecord(
      date: fields[0] as DateTime,
      status: fields[1] as String,
      round: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LessonRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.round);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
