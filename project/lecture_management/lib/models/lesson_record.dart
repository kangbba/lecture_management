import 'package:hive/hive.dart';

part 'lesson_record.g.dart';

@HiveType(typeId: 1)
class LessonRecord {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String status; // "완료" or "노쇼"

  @HiveField(2)
  int round;

  LessonRecord({
    required this.date,
    this.status = '완료',
    required this.round,
  });
}
