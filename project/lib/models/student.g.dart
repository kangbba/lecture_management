// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 0;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      name: fields[0] as String,
      phone: fields[1] as String,
      gender: fields[2] as String?,
      email: fields[3] as String?,
      registeredAt: fields[4] as DateTime,
      preferredLessonCount: fields[5] as int,
      lessonRecords: (fields[6] as List?)?.cast<LessonRecord>(),
      nextEnrollDate: fields[7] as DateTime?,
      payments: (fields[8] as List?)?.cast<PaymentRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.registeredAt)
      ..writeByte(5)
      ..write(obj.preferredLessonCount)
      ..writeByte(6)
      ..write(obj.lessonRecords)
      ..writeByte(7)
      ..write(obj.nextEnrollDate)
      ..writeByte(8)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
