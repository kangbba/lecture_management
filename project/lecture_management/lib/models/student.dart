import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String? gender;

  @HiveField(3)
  String? email;

  @HiveField(4)
  DateTime registeredAt;

  @HiveField(5)
  int monthlyLessonCount;

  @HiveField(6)
  DateTime? tuitionPaidDate;

  @HiveField(7)
  List<DateTime> attendances = [];

  @HiveField(8)
  DateTime? nextEnrollDate;
  Student({
    required this.name,
    required this.phone,
    this.gender,
    this.email,
    required this.registeredAt,
    required this.monthlyLessonCount,
    this.tuitionPaidDate,
    List<DateTime>? attendances,
    this.nextEnrollDate,
  }) : attendances = attendances ?? [];

}
