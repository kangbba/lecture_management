import 'package:flutter/material.dart';
import '../models/lesson_record.dart';
import '../models/student.dart';

enum LessonBarMode { attendance, payment }

class LessonPaymentBar extends StatelessWidget {
  final Student student;
  final LessonBarMode mode;

  const LessonPaymentBar({
    super.key,
    required this.student,
    required this.mode,
  });

  int _totalPaidLessons(Student s) =>
      s.payments.fold(0, (sum, p) => sum + p.lessonCount);

  int _maxRound(Student s) =>
      s.lessonRecords.map((r) => r.round).fold(0, (prev, r) => r > prev ? r : prev);

  @override
  Widget build(BuildContext context) {
    final paid = _totalPaidLessons(student);
    final records = student.lessonRecords;
    final maxUsedRound = _maxRound(student);
    final usedRounds = records.map((r) => r.round).toSet();
    final maxBarCount = paid > maxUsedRound ? paid : maxUsedRound;

    return Row(
      children: List.generate(maxBarCount, (i) {
        final round = i + 1;
        final record = records.firstWhere(
              (r) => r.round == round,
          orElse: () => LessonRecord(
            date: DateTime.now(),
            round: round,
            status: '유실',
          ),
        );

        Color color;
        Widget bar;

        if (mode == LessonBarMode.attendance) {
          // ✅ attendance 모드: status 기준
          if (record.status == '완료') {
            color = Colors.blue;
          } else if (record.status == '노쇼') {
            color = Colors.lightBlue.shade200;
          } else {
            color = Colors.grey.shade400;
          }

          bar = Container(
            width: 12,
            height: 14,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
            child: record.status == '유실'
                ? const Text('?', style: TextStyle(fontSize: 10, color: Colors.white))
                : null,
          );
        } else {
          // ✅ payment 모드: 납부 기준
          if (round <= paid) {
            if (usedRounds.contains(round)) {
              color = Colors.green; // 출석된 납부 회차
            } else {
              color = Colors.grey.shade300; // 잔여 회차
            }
          } else {
            color = Colors.red; // 미납 회차
          }

          bar = Container(
            width: 12,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }

        return bar;
      }),
    );
  }
}
