import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../models/payment_record.dart';

class PaymentEditScreen extends StatefulWidget {
  final Student student;
  const PaymentEditScreen({super.key, required this.student});

  @override
  State<PaymentEditScreen> createState() => _PaymentEditScreenState();
}

class _PaymentEditScreenState extends State<PaymentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  int _lessonCount = 4;
  int _amount = 0;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newPayment = PaymentRecord(
      date: _date,
      lessonCount: _lessonCount,
      amount: _amount,
    );

    setState(() {
      widget.student.payments.add(newPayment);
      _formKey.currentState?.reset();
      _lessonCount = 4;
      _amount = 0;
      _date = DateTime.now();
    });

    await widget.student.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('납부 등록 완료')),
    );
  }

  void _editPayment(int index) async {
    final payment = widget.student.payments[index];
    DateTime editedDate = payment.date;
    int editedAmount = payment.amount;
    int editedCount = payment.lessonCount;

    await showDialog(
      context: context,
      builder: (context) {
        final _editForm = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('납부 수정'),
          content: Form(
            key: _editForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('납부일'),
                  subtitle: Text(DateFormat('yyyy.MM.dd').format(editedDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: editedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => editedDate = picked);
                      }
                    },
                  ),
                ),
                TextFormField(
                  initialValue: editedAmount.toString(),
                  decoration: const InputDecoration(labelText: '납부 금액'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => editedAmount = int.tryParse(val!) ?? 0,
                ),
                TextFormField(
                  initialValue: editedCount.toString(),
                  decoration: const InputDecoration(labelText: '레슨 횟수'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => editedCount = int.tryParse(val!) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                _editForm.currentState?.save();
                setState(() {
                  widget.student.payments[index] = PaymentRecord(
                    date: editedDate,
                    amount: editedAmount,
                    lessonCount: editedCount,
                  );
                });
                widget.student.save();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _deletePayment(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 납부 내역을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        widget.student.payments.removeAt(index);
      });
      await widget.student.save();
    }
  }

  String _format(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  @override
  Widget build(BuildContext context) {
    final payments = [...widget.student.payments]..sort((a, b) => b.date.compareTo(a.date));
    final total = widget.student.payments.fold(0, (sum, p) => sum + p.lessonCount);
    final used = widget.student.lessonRecords.where((r) => r.status == '완료').length;
    final remain = total - used;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.student.name} 납부 정보')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('🆕 연장 등록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('납부일'),
                    subtitle: Text(_format(_date)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '납부 금액 (원)'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? '금액을 입력하세요' : null,
                    onSaved: (val) => _amount = int.tryParse(val!) ?? 0,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '레슨 횟수'),
                    initialValue: '4',
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? '횟수를 입력하세요' : null,
                    onSaved: (val) => _lessonCount = int.tryParse(val!) ?? 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('납부 등록하기'),
            ),
            const SizedBox(height: 20),
            const Divider(height: 32),
            const Text('💳 납부 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('누적 납부 수업: $total회'),
            Text('사용된 수업: $used회'),
            Text(
              remain >= 0
                  ? '잔여 수업: $remain회'
                  : '초과 수업: ${-remain}회',
              style: TextStyle(color: remain < 0 ? Colors.red : Colors.black),
            ),

            const Divider(height: 32),
            const Text('📋 납부 내역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (payments.isEmpty)
              const Text('납부 내역이 없습니다.')
            else
              ...payments.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return ListTile(
                  title: Text('${_format(p.date)} - ${p.lessonCount}회'),
                  subtitle: Text('${p.amount}원'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editPayment(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePayment(i),
                      ),
                    ],
                  ),
                );
              }),
            const Divider(height: 32),
          ],
        ),
      ),
    );
  }
}
