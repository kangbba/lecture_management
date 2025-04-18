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
  int preferredLessonCount;

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

  /// JSON 역직렬화 (백업 불러오기 등)
  factory Student.fromJson(Map<String, dynamic> s) {
    return Student(
      name: s['name'],
      phone: s['phone'],
      gender: s['gender'],
      email: s['email'],
      registeredAt: DateTime.parse(s['registeredAt']),
      preferredLessonCount: s['preferredLessonCount'],
      nextEnrollDate: s['nextEnrollDate'] != null
          ? DateTime.parse(s['nextEnrollDate'])
          : null,
      lessonRecords: (s['lessonRecords'] as List<dynamic>)
          .map((r) => LessonRecord.fromJson(r))
          .toList(),
      payments: (s['payments'] as List<dynamic>)
          .map((p) => PaymentRecord.fromJson(p))
          .toList(),
    );
  }

  /// JSON 직렬화 (백업 저장 등)
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'gender': gender,
    'email': email,
    'registeredAt': registeredAt.toIso8601String(),
    'preferredLessonCount': preferredLessonCount,
    'nextEnrollDate': nextEnrollDate?.toIso8601String(),
    'lessonRecords': lessonRecords.map((r) => r.toJson()).toList(),
    'payments': payments.map((p) => p.toJson()).toList(),
  };
}
