import '../../domain/entities/payment_with_details.dart';
import '../../domain/entities/payment.dart';
import 'payment_model.dart';

class PaymentWithDetailsModel extends PaymentWithDetails {
  const PaymentWithDetailsModel({
    required super.payment,
    required super.memberName,
    required super.packageName,
    required super.packageLessonCount,
    super.scheduleId,
    super.scheduleStartDate,
    super.scheduleEndDate,
  });

  factory PaymentWithDetailsModel.fromJson(Map<String, dynamic> json) {
    // Payment data
    final paymentModel = PaymentModel.fromJson(json);

    // Member data
    final member = json['member'] as Map<String, dynamic>?;
    final firstName = member?['first_name'] as String? ?? '';
    final lastName = member?['last_name'] as String? ?? '';
    final memberName = '$firstName $lastName'.trim();

    // Package data
    final package = json['package'] as Map<String, dynamic>?;
    final packageName = package?['name'] as String? ?? 'Bilinmeyen Paket';
    final packageLessonCount = package?['lesson_count'] as int? ?? 0;

    // Schedule data
    final scheduleId = json['schedule_id'] as String?;
    DateTime? scheduleStartDate;
    DateTime? scheduleEndDate;
    
    final startDateStr = json['schedule_start_date'] as String?;
    if (startDateStr != null) {
      try {
        scheduleStartDate = DateTime.parse(startDateStr);
      } catch (e) {
        // Invalid date, leave as null
      }
    }
    
    final endDateStr = json['schedule_end_date'] as String?;
    if (endDateStr != null) {
      try {
        scheduleEndDate = DateTime.parse(endDateStr);
      } catch (e) {
        // Invalid date, leave as null
      }
    }

    return PaymentWithDetailsModel(
      payment: paymentModel,
      memberName: memberName.isEmpty ? 'Bilinmeyen Üye' : memberName,
      packageName: packageName,
      packageLessonCount: packageLessonCount,
      scheduleId: scheduleId,
      scheduleStartDate: scheduleStartDate,
      scheduleEndDate: scheduleEndDate,
    );
  }

  PaymentWithDetailsModel copyWith({
    Payment? payment,
    String? memberName,
    String? packageName,
    int? packageLessonCount,
    String? scheduleId,
    DateTime? scheduleStartDate,
    DateTime? scheduleEndDate,
  }) {
    return PaymentWithDetailsModel(
      payment: payment ?? this.payment,
      memberName: memberName ?? this.memberName,
      packageName: packageName ?? this.packageName,
      packageLessonCount: packageLessonCount ?? this.packageLessonCount,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduleStartDate: scheduleStartDate ?? this.scheduleStartDate,
      scheduleEndDate: scheduleEndDate ?? this.scheduleEndDate,
    );
  }
}
