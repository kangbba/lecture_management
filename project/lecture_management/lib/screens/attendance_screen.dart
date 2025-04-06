import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/student.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _controller = TextEditingController();
  Student? foundStudent;
  int attendanceCount = 0;
  String? nextEnrollDate;

  void _searchStudent() {
    final box = Hive.box<Student>('students');
    final input = _controller.text.trim();

    if (input.length < 3) return;

    final matches = box.values
        .where((s) => s.phone.endsWith(input))
        .toList();

    if (matches.isEmpty) {
      setState(() {
        foundStudent = null;
        attendanceCount = 0;
        nextEnrollDate = null;
      });
    } else if (matches.length == 1) {
      _selectStudent(matches.first);
    } else {
      _showStudentSelectionDialog(matches);
    }
  }

  void _selectStudent(Student student) {
    setState(() {
      foundStudent = student;
      attendanceCount = student.attendances.length;
      nextEnrollDate = student.nextEnrollDate != null
          ? DateFormat('M월 d일').format(student.nextEnrollDate!)
          : null;
    });
  }

  void _showStudentSelectionDialog(List<Student> matches) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: matches.map((student) {
            return ListTile(
              title: Text(student.name),
              subtitle: Text(student.phone),
              onTap: () {
                Navigator.pop(context);
                _selectStudent(student);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _confirmAttendance() async {
    if (foundStudent == null) return;

    final now = DateTime.now();
    foundStudent!
      ..attendances.add(now)
      ..save();

    setState(() {
      attendanceCount = foundStudent!.attendances.length;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('출석이 완료되었습니다.')),
    );
  }

  Widget _studentInfoCard() {
    if (foundStudent == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          '${foundStudent!.name} 님은',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '$attendanceCount회차 입니다.',
          style: const TextStyle(fontSize: 22, color: Colors.red),
        ),
        const SizedBox(height: 16),
        if (nextEnrollDate != null)
          Text(
            '다음등록일은 $nextEnrollDate 입니다',
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _confirmAttendance,
          child: const Text('출석확인'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석관리'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '전화번호 뒷자리 4자를 입력하세요',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchStudent,
              icon: const Icon(Icons.search),
              label: const Text('검색'),
            ),
            const SizedBox(height: 20),
            _studentInfoCard(),
          ],
        ),
      ),
    );
  }
}
