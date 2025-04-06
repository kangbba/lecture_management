class Student {
  final int? id;
  final String name;
  final String gender;
  final String phone;
  final String? email;
  final String registerDate;
  final int monthlyCount;
  final String firstPayment;

  Student({
    this.id,
    required this.name,
    required this.gender,
    required this.phone,
    this.email,
    required this.registerDate,
    required this.monthlyCount,
    required this.firstPayment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'phone': phone,
      'email': email,
      'registerDate': registerDate,
      'monthlyCount': monthlyCount,
      'firstPayment': firstPayment,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      gender: map['gender'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      registerDate: map['registerDate'] as String,
      monthlyCount: map['monthlyCount'] as int,
      firstPayment: map['firstPayment'] as String,
    );
  }
}
