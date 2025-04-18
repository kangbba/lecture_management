import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/student.dart';
import 'admin_home_screen.dart';
import 'attendance_screen.dart';
import 'student_export_table_screen.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  void _goToAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
    );
  }

  void _goToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
    );
  }

  Future<void> _importBackupFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: '백업 JSON 파일을 선택하세요 (예: student_backup_2024.json)',
    );

    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path!;
    if (!path.toLowerCase().endsWith('.json')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 JSON 파일이 아닙니다.')),
      );
      return;
    }

    try {
      final file = File(path);
      final content = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(content);

      final List<Student> students = decoded
          .map<Student>((s) => Student.fromJson(s as Map<String, dynamic>))
          .toList();

      final box = Hive.box<Student>('students');
      await box.clear();
      for (var s in students) {
        await box.add(s);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업 파일에서 수강생 데이터를 가져왔습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일을 불러오는 데 실패했습니다: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('모드를 선택하세요', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _goToAttendance(context),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('수강생 출석모드'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _goToAdmin(context),
              icon: const Icon(Icons.lock_open),
              label: const Text('관리자 모드'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentExportTableScreen()),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('전체 수강생 표 보기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _importBackupFile(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('백업 파일 가져오기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
