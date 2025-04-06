import 'package:flutter/material.dart';
import 'screens/student_register_page.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase(); // DB 먼저 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '학원 관리 앱',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const StudentRegisterPage(),
    );
  }
}
