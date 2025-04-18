import 'package:flutter/material.dart';
import 'lesson_payment_bar.dart'; // LessonBarMode enum 사용

class LessonBarGuide extends StatelessWidget {
  final LessonBarMode mode;

  const LessonBarGuide({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (mode == LessonBarMode.attendance) {
      items = [
        _legend(Colors.blue, '출석 완료'),
        _legend(Colors.yellow, '노쇼'),
        _legend(Colors.grey.shade400, '정보 없음'),
      ];
    } else {
      items = [
        _legend(Colors.green, '납부 + 출석됨'),
        _legend(Colors.grey.shade300, '납부만 완료'),
        _legend(Colors.red, '미납'),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: items,
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
