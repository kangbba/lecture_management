import 'package:flutter/material.dart';

class StudentRegisterPage extends StatelessWidget {
  const StudentRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수강생 등록')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이게 보이면 화면 렌더링 성공 🎉'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('등록하기 버튼'),
            ),
          ],
        ),
      ),
    );
  }
}
