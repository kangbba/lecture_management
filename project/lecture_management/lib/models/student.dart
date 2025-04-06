class Student {
  static const String tableName = 'students';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnPhone = 'phone';
  static const String columnGender = 'gender';
  static const String columnEmail = 'email';
  static const String columnRegisteredAt = 'registeredAt';
  static const String columnLessonCount = 'monthlyLessonCount';
  static const String columnTuitionPaidAt = 'tuitionPaidDate';

  final int? id;
  final String name;
  final String phone;
  final String? gender;
  final String? email;
  final DateTime registeredAt;
  final int monthlyLessonCount;
  final DateTime? tuitionPaidDate;

  Student({
    this.id,
    required this.name,
    required this.phone,
    this.gender,
    this.email,
    required this.registeredAt,
    required this.monthlyLessonCount,
    this.tuitionPaidDate,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map[columnId],
      name: map[columnName],
      phone: map[columnPhone],
      gender: map[columnGender],
      email: map[columnEmail],
      registeredAt: DateTime.parse(map[columnRegisteredAt]),
      monthlyLessonCount: map[columnLessonCount],
      tuitionPaidDate: map[columnTuitionPaidAt] != null
          ? DateTime.tryParse(map[columnTuitionPaidAt])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) columnId: id,
      columnName: name,
      columnPhone: phone,
      columnGender: gender,
      columnEmail: email,
      columnRegisteredAt: registeredAt.toIso8601String(),
      columnLessonCount: monthlyLessonCount,
      columnTuitionPaidAt: tuitionPaidDate?.toIso8601String(),
    };
  }
}
