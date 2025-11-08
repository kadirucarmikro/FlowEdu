import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, paid, failed }

class Payment extends Equatable {
  final String id;
  final String memberId;
  final String packageId;
  final double amount;
  final double discountAmount;
  final PaymentStatus status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final String? scheduleId;

  const Payment({
    required this.id,
    required this.memberId,
    required this.packageId,
    required this.amount,
    required this.discountAmount,
    required this.status,
    this.dueDate,
    this.paidAt,
    required this.createdAt,
    this.scheduleId,
  });

  double get finalAmount => amount - discountAmount;

  bool get isPaid => status == PaymentStatus.paid;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;

  @override
  List<Object?> get props => [
    id,
    memberId,
    packageId,
    amount,
    discountAmount,
    status,
    dueDate,
    paidAt,
    createdAt,
    scheduleId,
  ];
}
