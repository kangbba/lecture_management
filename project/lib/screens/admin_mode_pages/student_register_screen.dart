import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';

class StudentRegisterScreen extends StatefulWidget {
  final Student? student;
  final bool canDelete;

  const StudentRegisterScreen({
    super.key,
    this.student,
    required this.canDelete,
  });

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
  int _preferredLessonCount = 4;
  DateTime _registeredDate = DateTime.now();

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
      _preferredLessonCount = _target!.preferredLessonCount;
      _registeredDate = _target!.registeredAt;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final box = Hive.box<Student>('students');
    final trimmedPhone = _phone.trim();

    // ✅ 중복 전화번호 확인 (편집 모드가 아닌 경우에만)
    if (!_editMode) {
      final isDuplicate = box.values.any((s) => s.phone == trimmedPhone);
      if (isDuplicate) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('중복된 전화번호'),
            content: const Text('이미 등록된 전화번호입니다.\n다시 확인해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (_editMode && _target != null) {
      _target!
        ..name = _name.trim()
        ..phone = _phone.trim()
        ..gender = _gender
        ..email = _email?.trim()
        ..preferredLessonCount = _preferredLessonCount
        ..registeredAt = _registeredDate;
      await _target!.save();
    } else {
      final newStudent = Student(
        name: _name.trim(),
        phone: _phone.trim(),
        gender: _gender,
        email: _email?.trim(),
        registeredAt: _registeredDate,
        preferredLessonCount: _preferredLessonCount,
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
        _preferredLessonCount = 4;
        _registeredDate = DateTime.now();
      });
    } else {
      Navigator.pop(context);
    }
  }


  void _delete() async {
    if (_target == null) return;

    final hasRecords = _target!.lessonRecords.isNotEmpty || _target!.payments.isNotEmpty;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수강생 삭제 확인'),
        content: Text(
          hasRecords
              ? '이 수강생은 수업 기록 또는 납부 기록이 있습니다.\n삭제 시 모든 데이터가 사라집니다.\n정말 삭제하시겠습니까?'
              : '정말로 이 수강생을 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _target!.delete();
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate(Function(DateTime) onPicked) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registeredDate,
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
                decoration: const InputDecoration(
                  labelText: '이름 (*)',
                  labelStyle: TextStyle(fontSize: 14),
                  hintText: '예: 홍길동',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.black26), // 힌트 텍스트 크기 줄임
                ),
                onSaved: (val) => _name = val ?? '',
                validator: (val) => val == null || val.isEmpty ? '이름을 입력하세요' : null,
              ),

              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(
                  labelText: '전화번호 (*)',
                  labelStyle: TextStyle(fontSize: 14),
                  hintText: '예: 01012345678',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                ),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phone = val ?? '',
                validator: (val) => val == null || val.length < 10 ? '전화번호를 입력하세요' : null,
              ),

              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  labelStyle: TextStyle(fontSize: 14),
                  hintText: '예: example@email.com',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
                ),
                onSaved: (val) => _email = val,
              ),

              // Row(
              //   children: ['남', '여'].map((g) {
              //     return Expanded(
              //       child: GestureDetector(
              //         onTap: () => setState(() => _gender = g),
              //         child: Container(
              //           margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              //           padding: const EdgeInsets.symmetric(vertical: 14),
              //           decoration: BoxDecoration(
              //             color: _gender == g ? Colors.blue : Colors.grey[300],
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           alignment: Alignment.center,
              //           child: Text(
              //             g,
              //             style: TextStyle(
              //               color: _gender == g ? Colors.white : Colors.black,
              //             ),
              //           ),
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('최초 등록일'),
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
                        groupValue: _preferredLessonCount,
                        onChanged: (val) => setState(() => _preferredLessonCount = val as int),
                      ),
                      Text('${e}회'),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_editMode ? '저장' : '등록하기'),
              ),
              if (_editMode && widget.canDelete) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _delete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                  label: const Text('수강생 삭제'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
