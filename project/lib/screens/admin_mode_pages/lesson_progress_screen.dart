import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../lesson_bar_guide.dart';
import '../lesson_payment_bar.dart';
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: const LessonBarGuide(mode: LessonBarMode.attendance),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<Student> box, _) {
              final students = box.values.toList();

              if (students.isEmpty) {
                return const Center(child: Text('등록된 수강생이 없습니다.'));
              }

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (_, index) {
                  final s = students[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1.5,
                    child: ListTile(
                      onTap: () => _goToDetail(context, s),
                      title: Text(s.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('최종 수업일: ${_formatDate(_getLastLesson(s))}',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          LessonPaymentBar(
                            student: s,
                            mode: LessonBarMode.attendance,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
