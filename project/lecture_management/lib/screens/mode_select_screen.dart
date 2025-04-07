import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'attendance_screen.dart'; // ← 이 줄 추가

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('모드를 선택하세요', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 32),
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
              onPressed: () => _goToAttendance(context), // ← 연결 완료
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('수강생 출석모드'),
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
