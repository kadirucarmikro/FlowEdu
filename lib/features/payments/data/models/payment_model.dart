import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.memberId,
    required super.packageId,
    required super.amount,
    required super.discountAmount,
    required super.status,
    super.dueDate,
    super.paidAt,
    required super.createdAt,
    super.scheduleId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      packageId: json['package_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduleId: json['schedule_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'package_id': packageId,
      'amount': amount,
      'discount_amount': discountAmount,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'schedule_id': scheduleId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'member_id': memberId,
      'package_id': packageId,
      'amount': amount,
      'discount_amount': discountAmount,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'schedule_id': scheduleId,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? memberId,
    String? packageId,
    double? amount,
    double? discountAmount,
    PaymentStatus? status,
    DateTime? dueDate,
    DateTime? paidAt,
    DateTime? createdAt,
    String? scheduleId,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      packageId: packageId ?? this.packageId,
      amount: amount ?? this.amount,
      discountAmount: discountAmount ?? this.discountAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      scheduleId: scheduleId ?? this.scheduleId,
    );
  }
}
