import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';

// 전역 데이터베이스 객체
late Database db;

/// 데이터베이스 초기화 (앱 시작 시 호출)
Future<void> initDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'academy.db');

  db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          gender TEXT,
          phone TEXT,
          email TEXT,
          registerDate TEXT,
          monthlyCount INTEGER,
          firstPayment TEXT
        )
      ''');
    },
  );
}

/// 수강생 삽입
Future<void> insertStudent(Student student) async {
  await db.insert('students', student.toMap());
}

/// 모든 수강생 조회
Future<List<Student>> getAllStudents() async {
  final List<Map<String, dynamic>> maps = await db.query('students');
  return maps.map((map) => Student.fromMap(map)).toList();
}

/// 수강생 업데이트
Future<void> updateStudent(Student student) async {
  await db.update(
    'students',
    student.toMap(),
    where: 'id = ?',
    whereArgs: [student.id],
  );
}

/// 수강생 삭제
Future<void> deleteStudent(int id) async {
  await db.delete(
    'students',
    where: 'id = ?',
    whereArgs: [id],
  );
}
