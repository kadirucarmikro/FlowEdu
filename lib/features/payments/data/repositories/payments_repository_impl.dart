import '../../domain/entities/payment.dart';
import '../../domain/entities/lesson_package.dart';
import '../../domain/entities/payment_with_details.dart';
import '../../domain/repositories/payments_repository.dart';
import '../data_sources/payments_remote_data_source.dart';
import '../models/payment_model.dart';
import '../models/lesson_package_model.dart';
import '../models/payment_with_details_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Payment>> getPayments() async {
    try {
      final payments = await _remoteDataSource.getPayments();
      return payments;
    } catch (e) {
      throw Exception('Failed to get payments: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentWithDetails>> getPaymentsWithDetails() async {
    try {
      final paymentsData =
          await (_remoteDataSource as PaymentsRemoteDataSourceImpl)
              .getPaymentsWithDetails();
      return paymentsData
          .map((json) => PaymentWithDetailsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments with details: ${e.toString()}');
    }
  }

  @override
  Future<Payment> getPaymentById(String id) async {
    try {
      final payment = await _remoteDataSource.getPaymentById(id);
      return payment;
    } catch (e) {
      throw Exception('Failed to get payment: ${e.toString()}');
    }
  }

  @override
  Future<List<Payment>> getPaymentsByMemberId(String memberId) async {
    try {
      final payments = await _remoteDataSource.getPaymentsByMemberId(memberId);
      return payments;
    } catch (e) {
      throw Exception('Failed to get payments by member: ${e.toString()}');
    }
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    try {
      final paymentModel = PaymentModel(
        id: payment.id,
        memberId: payment.memberId,
        packageId: payment.packageId,
        amount: payment.amount,
        discountAmount: payment.discountAmount,
        status: payment.status,
        dueDate: payment.dueDate,
        paidAt: payment.paidAt,
        createdAt: payment.createdAt,
      );

      final createdPayment = await _remoteDataSource.createPayment(
        paymentModel,
      );
      return createdPayment;
    } catch (e) {
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }

  @override
  Future<Payment> updatePayment(Payment payment) async {
    try {
      final paymentModel = PaymentModel(
        id: payment.id,
        memberId: payment.memberId,
        packageId: payment.packageId,
        amount: payment.amount,
        discountAmount: payment.discountAmount,
        status: payment.status,
        dueDate: payment.dueDate,
        paidAt: payment.paidAt,
        createdAt: payment.createdAt,
      );

      final updatedPayment = await _remoteDataSource.updatePayment(
        paymentModel,
      );
      return updatedPayment;
    } catch (e) {
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePayment(String id) async {
    try {
      await _remoteDataSource.deletePayment(id);
    } catch (e) {
      throw Exception('Failed to delete payment: ${e.toString()}');
    }
  }

  @override
  Future<List<LessonPackage>> getLessonPackages() async {
    try {
      final packages = await _remoteDataSource.getLessonPackages();
      return packages;
    } catch (e) {
      throw Exception('Failed to get lesson packages: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackage> getLessonPackageById(String id) async {
    try {
      final package = await _remoteDataSource.getLessonPackageById(id);
      return package;
    } catch (e) {
      throw Exception('Failed to get lesson package: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackage> createLessonPackage(LessonPackage package) async {
    try {
      final packageModel = LessonPackageModel(
        id: package.id,
        name: package.name,
        lessonCount: package.lessonCount,
        price: package.price,
        isActive: package.isActive,
        createdAt: package.createdAt,
      );

      final createdPackage = await _remoteDataSource.createLessonPackage(
        packageModel,
      );
      return createdPackage;
    } catch (e) {
      throw Exception('Failed to create lesson package: ${e.toString()}');
    }
  }

  @override
  Future<LessonPackage> updateLessonPackage(LessonPackage package) async {
    try {
      final packageModel = LessonPackageModel(
        id: package.id,
        name: package.name,
        lessonCount: package.lessonCount,
        price: package.price,
        isActive: package.isActive,
        createdAt: package.createdAt,
      );

      final updatedPackage = await _remoteDataSource.updateLessonPackage(
        packageModel,
      );
      return updatedPackage;
    } catch (e) {
      throw Exception('Failed to update lesson package: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteLessonPackage(String id) async {
    try {
      await _remoteDataSource.deleteLessonPackage(id);
    } catch (e) {
      throw Exception('Failed to delete lesson package: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMemberPackagePriceAndDiscount(
    String memberId,
    String packageId, [
    String? specificScheduleId,
  ]) async {
    try {
      return await (_remoteDataSource as PaymentsRemoteDataSourceImpl)
          .getMemberPackagePriceAndDiscount(memberId, packageId, specificScheduleId);
    } catch (e) {
      // Hata durumunda null döndür
      return null;
    }
  }

  @override
  Future<bool> checkExistingPaymentForSchedule(
    String memberId,
    String packageId,
    String scheduleId,
  ) async {
    try {
      return await (_remoteDataSource as PaymentsRemoteDataSourceImpl)
          .checkExistingPaymentForSchedule(memberId, packageId, scheduleId);
    } catch (e) {
      // Hata durumunda false döndür (devam et)
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMemberPackageSchedules(
    String memberId,
    String packageId,
  ) async {
    try {
      return await (_remoteDataSource as PaymentsRemoteDataSourceImpl)
          .getMemberPackageSchedules(memberId, packageId);
    } catch (e) {
      return [];
    }
  }
}
