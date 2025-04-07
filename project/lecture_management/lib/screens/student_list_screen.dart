import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import 'student_register_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  String _format(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy.MM.dd').format(date);
  }

  void _navigateToEdit(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentRegisterScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<Student> box, _) {
        final students = box.values.toList();

        if (students.isEmpty) {
          return const Center(child: Text('등록된 수강생이 없습니다.'));
        }

        return ListView.separated(
          itemCount: students.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final s = students[index];
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${index + 1}. ${s.name} (${s.gender ?? '성별 미정'})'),
                  TextButton(
                    onPressed: () => _navigateToEdit(context, s),
                    child: const Text('수정'),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.phone),
                  if (s.email != null) Text(s.email!),
                  Text('등록일: ${_format(s.registeredAt)}'),
                  Text('수강횟수/월: ${s.monthlyLessonCount}'),
                  Text('납부일: ${_format(s.tuitionPaidDate)}'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
