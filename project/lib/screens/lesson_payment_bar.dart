import 'package:flutter/material.dart';
import '../models/lesson_record.dart';
import '../models/student.dart';

enum LessonBarMode { attendance, payment }

class LessonPaymentBar extends StatefulWidget {
  final Student student;
  final LessonBarMode mode;

  const LessonPaymentBar({
    super.key,
    required this.student,
    required this.mode,
  });

  @override
  State<LessonPaymentBar> createState() => _LessonPaymentBarState();
}

class _LessonPaymentBarState extends State<LessonPaymentBar> {
  int _totalPaidLessons(Student s) =>
      s.payments.fold(0, (sum, p) => sum + p.lessonCount);

  int _maxRound(Student s) =>
      s.lessonRecords.map((r) => r.round).fold(0, (prev, r) => r > prev ? r : prev);

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final paid = _totalPaidLessons(s);
    final usedRounds = s.lessonRecords.map((r) => r.round).toSet();
    final maxUsedRound = _maxRound(s);
    final maxBarCount = paid > maxUsedRound ? paid : maxUsedRound;
    final startIndex = (maxBarCount - 16).clamp(0, maxBarCount);

    final bars = List.generate(maxBarCount, (i) => i + 1)
        .skip(startIndex)
        .map((round) {
      final record = s.lessonRecords.firstWhere(
            (r) => r.round == round,
        orElse: () => LessonRecord(
          date: DateTime.now(),
          round: round,
          status: '유실',
        ),
      );

      Color color;
      if (widget.mode == LessonBarMode.attendance) {
        if (record.status == '완료') {
          color = Colors.blue;
        } else if (record.status == '노쇼') {
          color = Colors.yellow;
        } else {
          color = Colors.grey.shade400;
        }
      } else {
        if (round <= paid) {
          color = usedRounds.contains(round)
              ? Colors.green
              : Colors.grey.shade300;
        } else {
          color = Colors.red;
        }
      }

      return Container(
        width: 14,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: record.status == '유실'
            ? Align(alignment : Alignment.center, child: const Text('?', style: TextStyle(fontSize: 10, color: Colors.white)))
            : null,
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: bars,
    );
  }
}
