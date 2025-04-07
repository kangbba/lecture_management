import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/lesson_record.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Student> matches = [];
  Student? selectedStudent;

  void _searchStudent() {
    final box = Hive.box<Student>('students');
    final input = _controller.text.trim();

    if (input.length < 3) {
      setState(() {
        matches = [];
        selectedStudent = null;
      });
      return;
    }

    final result = box.values
        .where((s) => s.phone.endsWith(input))
        .toList();

    setState(() {
      matches = result;
      selectedStudent = result.length == 1 ? result.first : null;
    });
  }

  void _confirmAttendance() async {
    if (selectedStudent == null) return;

    final student = selectedStudent!;
    final now = DateTime.now();
    final lessonRounds = student.lessonRecords.map((r) => r.round).toList();
    final nextRound = lessonRounds.isEmpty ? 1 : lessonRounds.reduce((a, b) => a > b ? a : b) + 1;

    student.lessonRecords.add(
      LessonRecord(date: now, round: nextRound, status: '완료'),
    );

    await student.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('출석이 완료되었습니다.')),
    );

    setState(() {});
  }

  String _format(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  Widget _buildStudentInfo() {
    if (selectedStudent == null) return const SizedBox.shrink();

    final s = selectedStudent!;
    final lessonRounds = s.lessonRecords.map((r) => r.round).toList();
    final maxRound = lessonRounds.isEmpty ? 0 : lessonRounds.reduce((a, b) => a > b ? a : b);
    final nextRound = maxRound + 1;

    String nextPayText;
    if (s.nextEnrollDate != null) {
      nextPayText = '다음 납부일은 ${_format(s.nextEnrollDate!)} 입니다.';
    } else {
      final fallback = DateTime(
        s.registeredAt.year,
        s.registeredAt.month + 1,
        s.registeredAt.day,
      );
      nextPayText = '별도 설정된 납부일이 없습니다.\n기본 납부일은 ${_format(fallback)} 입니다.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('${s.name}님은 $nextRound회차 입니다.', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text('등록일: ${_format(s.registeredAt)}'),
        Text('누적 출석 기록 수: ${s.lessonRecords.length}'),
        const SizedBox(height: 12),
        Text(nextPayText, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('출석 완료하기', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _confirmAttendance,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출석 확인')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('전화번호 뒷자리 3~4자리를 입력하세요'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '예: 1234'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchStudent,
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (matches.isEmpty)
              const Text('검색 결과가 없습니다.')
            else if (matches.length > 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('여러 명이 검색되었습니다. 선택하세요:'),
                  const SizedBox(height: 8),
                  ...matches.map((s) => ListTile(
                    title: Text(s.name),
                    subtitle: Text(s.phone),
                    trailing: selectedStudent == s
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => setState(() => selectedStudent = s),
                  )),
                ],
              ),
            const SizedBox(height: 10),
            _buildStudentInfo(),
          ],
        ),
      ),
    );
  }
}
