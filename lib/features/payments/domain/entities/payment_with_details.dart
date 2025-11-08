import 'package:equatable/equatable.dart';
import 'payment.dart';

/// Payment entity with member and package details
class PaymentWithDetails extends Equatable {
  final Payment payment;
  final String memberName;
  final String packageName;
  final int packageLessonCount;
  final String? scheduleId;
  final DateTime? scheduleStartDate;
  final DateTime? scheduleEndDate;

  const PaymentWithDetails({
    required this.payment,
    required this.memberName,
    required this.packageName,
    required this.packageLessonCount,
    this.scheduleId,
    this.scheduleStartDate,
    this.scheduleEndDate,
  });

  // Payment properties delegate
  String get id => payment.id;
  String get memberId => payment.memberId;
  String get packageId => payment.packageId;
  double get amount => payment.amount;
  double get discountAmount => payment.discountAmount;
  PaymentStatus get status => payment.status;
  DateTime? get dueDate => payment.dueDate;
  DateTime? get paidAt => payment.paidAt;
  DateTime get createdAt => payment.createdAt;
  double get finalAmount => payment.finalAmount;
  bool get isPaid => payment.isPaid;
  bool get isPending => payment.isPending;
  bool get isFailed => payment.isFailed;

  @override
  List<Object?> get props => [
    payment,
    memberName,
    packageName,
    packageLessonCount,
    scheduleId,
    scheduleStartDate,
    scheduleEndDate,
  ];
}
