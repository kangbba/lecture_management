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
    setState(() {});  // UI 갱신
  }

  void _deleteRecord(int round) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('수업 삭제 확인'),
        content: const Text('이 수업 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        widget.student.lessonRecords.removeWhere((r) => r.round == round);
      });
      await widget.student.save();
    }
  }

  void _addMissingRecord(int round) async {
    DateTime selectedDate = DateTime.now();
    String selectedStatus = '완료';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$round회차 유실 데이터 추가'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('날짜 선택'),
                    subtitle: Text(DateFormat('yyyy.MM.dd').format(selectedDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: '완료', child: Text('완료')),
                      DropdownMenuItem(value: '노쇼', child: Text('노쇼')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedStatus = val);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () async {
                final newRecord = LessonRecord(
                  date: selectedDate,
                  round: round,
                  status: selectedStatus,
                );
                setState(() {
                  widget.student.lessonRecords.add(newRecord);
                });
                await widget.student.save();
                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = [...widget.student.lessonRecords];
    records.sort((a, b) => a.round.compareTo(b.round));
    final existingRounds = records.map((e) => e.round).toSet();

    // 회차 유실 탐색
    final maxRound = records.isNotEmpty ? records.last.round : 0;
    final List<int> missingRounds = [];
    for (int i = 1; i <= maxRound; i++) {
      if (!existingRounds.contains(i)) missingRounds.add(i);
    }

    final List<Widget> children = [];

    for (int i = 1; i <= maxRound; i++) {
      if (missingRounds.contains(i)) {
        children.add(
          ListTile(
            title: Text('$i회차 - [유실된 데이터]'),
            trailing: ElevatedButton(
              onPressed: () => _addMissingRecord(i),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('추가'),
            ),
          ),
        );
      } else {
        final r = records.firstWhere((r) => r.round == i);
        children.add(
          ListTile(
            title: Text('${r.round}회차 - ${_format(r.date)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: r.status,
                  items: const [
                    DropdownMenuItem(value: '완료', child: Text('완료')),
                    DropdownMenuItem(value: '노쇼', child: Text('노쇼')),
                  ],
                  onChanged: (val) {
                    if (val != null) _updateStatus(r.round, val);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRecord(r.round),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.student.name} 수업 이력')),
      body: children.isEmpty
          ? const Center(child: Text('기록된 수업이 없습니다.'))
          : ListView.separated(
        itemCount: children.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}
