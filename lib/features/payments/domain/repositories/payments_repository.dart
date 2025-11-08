import '../entities/payment.dart';
import '../entities/lesson_package.dart';
import '../entities/payment_with_details.dart';

abstract class PaymentsRepository {
  Future<List<Payment>> getPayments();
  Future<List<PaymentWithDetails>> getPaymentsWithDetails();
  Future<Payment> getPaymentById(String id);
  Future<List<Payment>> getPaymentsByMemberId(String memberId);
  Future<Payment> createPayment(Payment payment);
  Future<Payment> updatePayment(Payment payment);
  Future<void> deletePayment(String id);

  // Lesson Packages
  Future<List<LessonPackage>> getLessonPackages();
  Future<LessonPackage> getLessonPackageById(String id);
  Future<LessonPackage> createLessonPackage(LessonPackage package);
  Future<LessonPackage> updateLessonPackage(LessonPackage package);
  Future<void> deleteLessonPackage(String id);

  // Üye ve paket için lesson_attendees tablosundan tutar ve indirim bilgisini getir
  Future<Map<String, dynamic>?> getMemberPackagePriceAndDiscount(
    String memberId,
    String packageId, [
    String? specificScheduleId,
  ]);

  // Aynı üye-paket-schedule için ödeme kontrolü
  Future<bool> checkExistingPaymentForSchedule(
    String memberId,
    String packageId,
    String scheduleId,
  );

  // Üye ve paket için ders programlarını getir (dropdown için)
  Future<List<Map<String, dynamic>>> getMemberPackageSchedules(
    String memberId,
    String packageId,
  );
}
