import 'package:flutter/material.dart';
import 'student_list_screen.dart';
import 'student_register_screen.dart';
// TODO: 나머지 화면은 추후 구현
// import 'tuition_screen.dart';
// import 'lesson_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentListScreen(),
    const StudentRegisterScreen(),
    const Placeholder(child: Center(child: Text('수강료 관리 예정'))),
    const Placeholder(child: Center(child: Text('수업진행 관리 예정'))),
  ];

  final List<String> _titles = [
    '수강생 목록',
    '수강생 등록',
    '수강료 관리',
    '수업진행 관리',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '수강생 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: '수강생 등록'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: '수강료 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '수업진행 관리'),
        ],
      ),
    );
  }
}
