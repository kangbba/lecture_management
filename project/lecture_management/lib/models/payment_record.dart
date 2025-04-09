import 'package:hive/hive.dart';

part 'payment_record.g.dart';

@HiveType(typeId: 2)
class PaymentRecord {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int lessonCount;

  @HiveField(2)
  int amount;

  PaymentRecord({
    required this.date,
    required this.lessonCount,
    required this.amount,
  });
}
