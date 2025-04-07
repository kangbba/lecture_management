import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../models/lesson_record.dart';

class LessonDetailScreen extends StatefulWidget {
  final Student student;
  const LessonDetailScreen({super.key, required this.student});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  String _format(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  void _updateStatus(int round, String newStatus) async {
    final i = widget.student.lessonRecords.indexWhere((r) => r.round == round);
    if (i == -1) return;

    final current = widget.student.lessonRecords[i];
    widget.student.lessonRecords[i] = LessonRecord(
      date: current.date,
      round: current.round,
      status: newStatus,
    );
    await widget.student.save();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final records = [...widget.student.lessonRecords];
    records.sort((a, b) => a.round.compareTo(b.round)); // 회차 순 정렬

    return Scaffold(
      appBar: AppBar(title: Text('${widget.student.name} 수업 이력')),
      body: records.isEmpty
          ? const Center(child: Text('기록된 수업이 없습니다.'))
          : ListView.separated(
        itemCount: records.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final r = records[index];
          return ListTile(
            title: Text('${r.round}회차 - ${_format(r.date)}'),
            trailing: DropdownButton<String>(
              value: r.status,
              items: const [
                DropdownMenuItem(value: '완료', child: Text('완료')),
                DropdownMenuItem(value: '노쇼', child: Text('노쇼')),
              ],
              onChanged: (val) {
                if (val != null) _updateStatus(r.round, val);
              },
            ),
          );
        },
      ),
    );
  }
}
