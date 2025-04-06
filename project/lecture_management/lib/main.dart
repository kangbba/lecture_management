import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'models/student.dart';
import 'screens/mode_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(StudentAdapter());
  await Hive.openBox<Student>('students'); // 꼭 먼저 열기!

  runApp(const LectureApp());
}


class LectureApp extends StatelessWidget {
  const LectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '강의 관리',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const ModeSelectScreen(),
    );
  }
}
