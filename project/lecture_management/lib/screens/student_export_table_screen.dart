import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../models/lesson_record.dart';
import '../models/payment_record.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StudentExportTableScreen extends StatelessWidget {
  const StudentExportTableScreen({super.key});

  String _d(DateTime? d) => d == null ? '-' : DateFormat('yyyy.MM.dd').format(d);

  String _lessonSummary(List<LessonRecord> records) {
    if (records.isEmpty) return '없음';
    return records
        .map((r) => '• ${_d(r.date)} (${r.round}회, ${r.status})')
        .join('\n');
  }

  String _paymentSummary(List<PaymentRecord> records) {
    if (records.isEmpty) return '없음';
    return records
        .map((p) => '• ${_d(p.date)} - ${p.lessonCount}회 / ${p.amount}원')
        .join('\n');
  }

  String _generateText(List<Student> students) {
    final buffer = StringBuffer();

    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      buffer.writeln('[${i + 1}] ${s.name} / ${s.phone} / ${s.gender ?? '-'} / ${s.email ?? '-'}');
      buffer.writeln('- 등록일: ${_d(s.registeredAt)} / 희망횟수: ${s.preferredLessonCount} / 다음등록일: ${_d(s.nextEnrollDate)}');
      buffer.writeln('- 수업기록:\n${_lessonSummary(s.lessonRecords)}');
      buffer.writeln('- 결제기록:\n${_paymentSummary(s.payments)}');
      buffer.writeln('------------------------------------------------------------');
    }

    return buffer.toString();
  }

  Future<void> _shareAsText(BuildContext context, List<Student> students) async {
    final text = _generateText(students);
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공유할 수강생 정보가 없습니다.')));
      return;
    }

    await Share.share(text);
  }

  Future<void> _shareAsFile(BuildContext context, List<Student> students) async {
    final data = students.map((s) => s.toJson()).toList(); // ← 변경
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/student_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: '수강생 데이터 백업 파일');
  }


  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');
    final students = box.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 수강생 표'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: '표 공유',
            onPressed: () => _shareAsText(context, students),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: '데이터 백업 공유',
            onPressed: () => _shareAsFile(context, students),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(80),
              3: FixedColumnWidth(180),
              4: FixedColumnWidth(100),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(100),
              7: FixedColumnWidth(300),
              8: FixedColumnWidth(300),
            },
            children: [
              _tableHeader([
                '이름',
                '연락처',
                '성별',
                '이메일',
                '등록일',
                '희망횟수',
                '다음등록일',
                '수업기록',
                '결제기록',
              ]),
              ...students.map((s) => TableRow(
                children: [
                  _cell(s.name),
                  _cell(s.phone),
                  _cell(s.gender ?? '-'),
                  _cell(s.email ?? '-'),
                  _cell(_d(s.registeredAt)),
                  _cell('${s.preferredLessonCount}'),
                  _cell(_d(s.nextEnrollDate)),
                  _cell(_lessonSummary(s.lessonRecords)),
                  _cell(_paymentSummary(s.payments)),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableHeader(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
      children: headers.map((h) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, softWrap: true),
    );
  }
}
