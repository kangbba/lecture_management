import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/student.dart';
import 'models/lesson_record.dart';
import 'screens/mode_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(LessonRecordAdapter());
  Hive.registerAdapter(StudentAdapter());

  await Hive.openBox<Student>('students');

  runApp(const LectureApp());
}

class LectureApp extends StatelessWidget {
  const LectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '강의 관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ModeSelectScreen(),
    );
  }
}
