import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/student.dart';
import 'models/lesson_record.dart';
import 'models/payment_record.dart';
import 'screens/mode_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(LessonRecordAdapter());
  Hive.registerAdapter(StudentAdapter());

  final studentBox = await Hive.openBox<Student>('students');

  // ✅ 더미 데이터 추가
  // final dummyStudents = [
  //   Student(
  //     name: '강진형',
  //     phone: '01088253708',
  //     gender: '남',
  //     registeredAt: DateTime.now(),
  //     preferredLessonCount: 4,
  //   ),
  //   Student(
  //     name: '강철호',
  //     phone: '01037423708',
  //     gender: '남',
  //     registeredAt: DateTime.now(),
  //     preferredLessonCount: 4,
  //   ),
  //   Student(
  //     name: '김현지',
  //     phone: '01094197679',
  //     gender: '여',
  //     registeredAt: DateTime.now(),
  //     preferredLessonCount: 4,
  //   ),
  //   Student(
  //     name: '홍길동',
  //     phone: '01012345678',
  //     gender: '남',
  //     registeredAt: DateTime.now(),
  //     preferredLessonCount: 4,
  //   ),
  //   Student(
  //     name: '김현숙',
  //     phone: '01066503708',
  //     gender: '여',
  //     registeredAt: DateTime.now(),
  //     preferredLessonCount: 4,
  //   ),
  // ];
  //
  // for (final s in dummyStudents) {
  //   final exists = studentBox.values.any((e) => e.phone == s.phone);
  //   if (!exists) {
  //     await studentBox.add(s);
  //   }
  // }

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
