import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Student.tableName} (
        ${Student.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Student.columnName} TEXT NOT NULL,
        ${Student.columnPhone} TEXT NOT NULL,
        ${Student.columnGender} TEXT,
        ${Student.columnEmail} TEXT,
        ${Student.columnRegisteredAt} TEXT NOT NULL,
        ${Student.columnLessonCount} INTEGER NOT NULL,
        ${Student.columnTuitionPaidAt} TEXT
      )
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(Student.tableName, data);
  }

  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    final db = await instance.database;
    return await db.query(
      Student.tableName,
      orderBy: '${Student.columnName} ASC',
    );
  }
  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return await db.update(
      Student.tableName,
      student.toMap(),
      where: '${Student.columnId} = ?',
      whereArgs: [student.id],
    );
  }
  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      Student.tableName,
      where: '${Student.columnId} = ?',
      whereArgs: [id],
    );
  }


}
