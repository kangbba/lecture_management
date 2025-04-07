import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';

class StudentRegisterScreen extends StatefulWidget {
  final Student? student;

  const StudentRegisterScreen({super.key, this.student});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _editMode;
  late Student? _target;

  String _name = '';
  String _phone = '';
  String? _gender;
  String? _email;
  int _monthlyLessonCount = 4;
  DateTime _registeredDate = DateTime.now();
  DateTime? _tuitionPaidDate;

  @override
  void initState() {
    super.initState();
    _editMode = widget.student != null;
    _target = widget.student;

    if (_editMode && _target != null) {
      _name = _target!.name;
      _phone = _target!.phone;
      _gender = _target!.gender;
      _email = _target!.email;
      _monthlyLessonCount = _target!.monthlyLessonCount;
      _registeredDate = _target!.registeredAt;
      _tuitionPaidDate = _target!.tuitionPaidDate;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final box = Hive.box<Student>('students');

    if (_editMode && _target != null) {
      _target!
        ..name = _name
        ..phone = _phone
        ..gender = _gender
        ..email = _email
        ..monthlyLessonCount = _monthlyLessonCount
        ..registeredAt = _registeredDate
        ..tuitionPaidDate = _tuitionPaidDate;
      await _target!.save();
    } else {
      final newStudent = Student(
        name: _name,
        phone: _phone,
        gender: _gender,
        email: _email,
        registeredAt: _registeredDate,
        monthlyLessonCount: _monthlyLessonCount,
        tuitionPaidDate: _tuitionPaidDate,
      );
      await box.add(newStudent);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editMode ? '수정 완료' : '등록 완료')),
    );

    if (!_editMode) {
      _formKey.currentState?.reset();
      setState(() {
        _gender = null;
        _monthlyLessonCount = 4;
        _registeredDate = DateTime.now();
        _tuitionPaidDate = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate(Function(DateTime) onPicked) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: '이름'),
                onSaved: (val) => _name = val ?? '',
                validator: (val) => val == null || val.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: '전화번호'),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phone = val ?? '',
                validator: (val) => val == null || val.length < 10 ? '전화번호를 입력하세요' : null,
              ),
              Row(
                children: ['남', '여'].map((g) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _gender == g ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          g,
                          style: TextStyle(
                            color: _gender == g ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: '이메일'),
                onSaved: (val) => _email = val,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('등록일'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_registeredDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _pickDate((d) => setState(() => _registeredDate = d)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [4, 8].map((e) {
                  return Row(
                    children: [
                      Radio(
                        value: e,
                        groupValue: _monthlyLessonCount,
                        onChanged: (val) => setState(() => _monthlyLessonCount = val as int),
                      ),
                      Text('${e}회'),
                    ],
                  );
                }).toList(),
              ),
              ListTile(
                title: const Text('첫 납부일'),
                subtitle: Text(_tuitionPaidDate != null
                    ? DateFormat('yyyy-MM-dd').format(_tuitionPaidDate!)
                    : '미지정'),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _pickDate((d) => setState(() => _tuitionPaidDate = d)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_editMode ? '저장' : '등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
