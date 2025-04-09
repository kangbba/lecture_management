import 'package:hive/hive.dart';
import 'lesson_record.dart';
import 'payment_record.dart';

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
  int preferredLessonCount; // 참고용: 수강생이 보통 납부할 때 선택하는 레슨 회차 수 (예: 4회, 8회 등)

  @HiveField(6)
  List<LessonRecord> lessonRecords;

  @HiveField(7)
  DateTime? nextEnrollDate;

  @HiveField(8)
  List<PaymentRecord> payments;

  Student({
    required this.name,
    required this.phone,
    this.gender,
    this.email,
    required this.registeredAt,
    required this.preferredLessonCount,
    List<LessonRecord>? lessonRecords,
    this.nextEnrollDate,
    List<PaymentRecord>? payments,
  })  : lessonRecords = lessonRecords ?? [],
        payments = payments ?? [];
}
