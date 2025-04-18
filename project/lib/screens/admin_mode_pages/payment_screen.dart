import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../models/payment_record.dart';
import '../lesson_bar_guide.dart';
import '../lesson_payment_bar.dart';
import 'payment_edit_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  String _format(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy.MM.dd').format(date);
  }

  PaymentRecord? _latestPayment(Student s) {
    if (s.payments.isEmpty) return null;
    s.payments.sort((a, b) => b.date.compareTo(a.date));
    return s.payments.first;
  }

  int _totalPaidLessons(Student s) {
    return s.payments.fold(0, (sum, p) => sum + p.lessonCount);
  }

  int _completedLessons(Student s) {
    return s.lessonRecords.where((r) => r.status == '완료').length;
  }

  Widget _buildStudentTile(BuildContext context, Student s) {
    final latest = _latestPayment(s);
    final paid = _totalPaidLessons(s);
    final used = _completedLessons(s);
    final remain = paid - used;
    final isOverused = remain < 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1.5,
      child: ListTile(
        title: Text(s.name),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentEditScreen(student: s)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LessonPaymentBar(
              student: s,
              mode: LessonBarMode.payment,
            ),
            const SizedBox(height: 6),
            if (latest != null)
              Text(
                '최근 ${_format(latest.date)}에 ${latest.lessonCount}회분 납부완료',
                style: const TextStyle(fontSize: 12),
              )
            else
              const Text(
                '납부 이력이 없습니다.',
                style: TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            Text(
              isOverused
                  ? '초과 수업: ${-remain}회'
                  : '남은 수업: $remain회',
              style: TextStyle(
                fontSize: 12,
                color: isOverused ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: LessonBarGuide(mode: LessonBarMode.payment),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<Student> box, _) {
              final allStudents = box.values.toList();
              if (allStudents.isEmpty) {
                return const Center(child: Text('등록된 수강생이 없습니다.'));
              }

              final needToPay = allStudents.where((s) {
                final paid = _totalPaidLessons(s);
                final used = _completedLessons(s);
                return used > paid;
              }).toList();

              final okStudents = allStudents.where((s) {
                final paid = _totalPaidLessons(s);
                final used = _completedLessons(s);
                return used <= paid;
              }).toList();

              final List<Widget> items = [];

              if (needToPay.isNotEmpty) {
                items.add(
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '❗ 미납 수강생',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                    ),
                  ),
                );
                items.addAll(needToPay.map((s) => _buildStudentTile(context, s)));
              }

              if (needToPay.isNotEmpty && okStudents.isNotEmpty) {
                items.add(const Divider()); // 구간 사이에만 Divider
              }

              if (okStudents.isNotEmpty) {
                items.add(
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '✅ 납부 완료 수강생',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                    ),
                  ),
                );
                items.addAll(okStudents.map((s) => _buildStudentTile(context, s)));
              }

              return ListView(
                children: items,
              );
            },
          ),
        ),
      ],
    );
  }
}
