import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
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
    if (_editMode) {
      final s = widget.student!;
      _name = s.name;
      _phone = s.phone;
      _gender = s.gender;
      _email = s.email;
      _monthlyLessonCount = s.monthlyLessonCount;
      _registeredDate = s.registeredAt;
      _tuitionPaidDate = s.tuitionPaidDate;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final student = Student(
      id: widget.student?.id,
      name: _name,
      phone: _phone,
      gender: _gender,
      email: _email,
      registeredAt: _registeredDate,
      monthlyLessonCount: _monthlyLessonCount,
      tuitionPaidDate: _tuitionPaidDate,
    );

    if (_editMode) {
      await DatabaseHelper.instance.updateStudent(student);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정 완료')));
    } else {
      await DatabaseHelper.instance.insertStudent(student.toMap());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('등록 완료')));
    }

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
    return Scaffold(
      appBar: AppBar(title: Text(_editMode ? '수강생 수정' : '수강생 등록')),
      body: Padding(
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
                validator: (val) => val == null || val.length < 10 ? '유효한 번호를 입력하세요' : null,
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
                            fontWeight: FontWeight.bold,
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
              ListTile(
                title: const Text('등록일'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_registeredDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _pickDate((date) => setState(() => _registeredDate = date)),
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
                title: const Text('첫 수강료 납부일'),
                subtitle: Text(_tuitionPaidDate != null
                    ? DateFormat('yyyy-MM-dd').format(_tuitionPaidDate!)
                    : '미지정'),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _pickDate((date) => setState(() => _tuitionPaidDate = date)),
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
