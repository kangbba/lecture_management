import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'attendance_screen.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  void _navigateToAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('비밀번호 입력'),
          content: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            onChanged: (val) => input = val,
            decoration: const InputDecoration(hintText: '0000'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (input == '0000') {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 틀렸습니다')),
                  );
                }
              },
              child: const Text('확인'),
            )
          ],
        );
      },
    );
  }

  void _navigateToStudent(BuildContext context) {
    // TODO: 출석화면으로 연결 예정
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모드 선택')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _navigateToStudent(context),
              icon: const Icon(Icons.person),
              label: const Text('수강생 모드'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _navigateToAdmin(context),
              icon: const Icon(Icons.lock),
              label: const Text('관리자 모드'),
            ),
          ],
        ),
      ),
    );
  }
}
