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

    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentEditScreen(student: s)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(s.name),
          Text('최근 납부: ${latest?.lessonCount ?? '-'}회분'),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LessonPaymentBar(student: s, mode: LessonBarMode.payment,),
          const SizedBox(height: 4),
          Text('납부 수업: $paid회 / 출석: $used회 / ${remain >= 0 ? '잔여' : '초과'}: ${remain.abs()}회'),
        ],
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');

    return Stack(
      children: [
        SizedBox(height: 20, child: LessonBarGuide(mode: LessonBarMode.payment)),
        ValueListenableBuilder(
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
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '❗ 미납 수강생',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              );
              items.addAll(needToPay.map((s) => _buildStudentTile(context, s)));
            }

            if (okStudents.isNotEmpty) {
              items.add(
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '✅ 납부 완료 수강생',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                    ),
                  ),
                ),
              );
              items.addAll(okStudents.map((s) => _buildStudentTile(context, s)));
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) => items[index],
            );
          },
        ),
      ],
    );
  }
}
