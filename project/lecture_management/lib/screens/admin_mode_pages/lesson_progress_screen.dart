import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import 'lesson_detail_screen.dart';

class LessonProgressScreen extends StatelessWidget {
  const LessonProgressScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy.MM.dd').format(date);
  }

  int _getTotalLessons(Student s) => s.lessonRecords.length;

  DateTime? _getLastLesson(Student s) {
    if (s.lessonRecords.isEmpty) return null;
    s.lessonRecords.sort((a, b) => b.date.compareTo(a.date));
    return s.lessonRecords.first.date;
  }

  void _goToDetail(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');

    return Material(
      child: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Student> box, _) {
          final students = box.values.toList();

          if (students.isEmpty) {
            return const Center(child: Text('등록된 수강생이 없습니다.'));
          }

          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final s = students[index];
              return ListTile(
                onTap: () => _goToDetail(context, s),
                title: Text('${s.name} (${s.monthlyLessonCount}회/월)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('최종 수업일: ${_formatDate(_getLastLesson(s))}'),
                    Text('누적 수업 횟수: ${_getTotalLessons(s)}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}
