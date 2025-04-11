import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/lesson_record.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Student> matches = [];
  Student? selectedStudent;
  bool searchMode = true;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.trim().length == 4;
      });
    });
  }

  void _searchStudent() {
    final input = _controller.text.trim();
    if (input.length != 4) return;

    final box = Hive.box<Student>('students');
    final result = box.values.where((s) => s.phone.endsWith(input)).toList();

    if (result.length == 1) {
      setState(() {
        selectedStudent = result.first;
        searchMode = false;
      });
    } else if (result.length > 1) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            contentPadding: const EdgeInsets.all(16),
            title: const Text('회원을 선택하세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 16),),
            content: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView(
                children: result.map((s) {
                  return ListTile(
                    title: Text(s.name, textAlign: TextAlign.center),
                    subtitle: Text(s.phone, textAlign: TextAlign.center),
                    onTap: () {
                      setState(() {
                        selectedStudent = s;
                        searchMode = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다.')),
      );
    }
  }

  Future<void> _confirmAttendance() async {
    if (selectedStudent == null) return;

    final student = selectedStudent!;
    final today = DateTime.now();

    final already = student.lessonRecords.any((record) =>
    record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day);

    if (already) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('이미 출석됨'),
          content: const Text('오늘 이미 출석 완료 내역이 있습니다.\n그래도 출석을 진행하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('네')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final lessonRounds = student.lessonRecords.map((r) => r.round).toList();
    final nextRound = lessonRounds.isEmpty ? 1 : lessonRounds.reduce((a, b) => a > b ? a : b) + 1;

    student.lessonRecords.add(
      LessonRecord(date: today, round: nextRound, status: '완료'),
    );
    await student.save();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('출석 완료'),
          ],
        ),
        content: Text('${student.name}님의 출석이 성공적으로 처리되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 닫기
              setState(() {
                searchMode = true;
                _controller.clear();
                isButtonEnabled = false;
              });
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _format(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  Widget _buildSearchSection() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('전화번호 뒷자리 4자리를 입력하세요'),
            const SizedBox(height: 18),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 80,
                  child: TextField(
                    controller: _controller,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28), // 텍스트 크기 증가
                    decoration: const InputDecoration(
                      hintText: '예: 1234',
                      hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                      counterText: '', // maxLength 아래 숫자 제거
                      isDense: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _searchStudent : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey.shade300; // 비활성화 상태일 때 색
                          }
                          return Colors.indigo; // 활성화 상태일 때 색
                        },
                      ),
                    ),
                    child: Text('검색', style : TextStyle(color : isButtonEnabled ? Colors.white : Colors.black))
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationSection() {
    final s = selectedStudent!;
    final today = DateFormat('yyyy년 MM월 dd일 (EEE)', 'ko').format(DateTime.now());

    return Center(
      child: SizedBox(
        width: 400,
        height: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: s.name,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' 님',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Text(
            //   today,
            //   style: const TextStyle(fontSize: 18, color: Colors.grey),
            // ),
            // const SizedBox(height: 28),
            Container(
              width: 200,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('출석하기', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _confirmAttendance,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 180,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.undo, color: Colors.white),
                label: const Text('돌아가기', style: TextStyle(color: Colors.white, fontSize: 16)),

                onPressed: () {
                  setState(() {
                    searchMode = true;
                    _controller.clear();
                    isButtonEnabled = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: searchMode ? _buildSearchSection() : _buildConfirmationSection(),
      ),
    );
  }
}
