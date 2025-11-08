import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';
import '../../data/providers/payments_providers.dart';

class UpdatePaymentUseCase {
  final PaymentsRepository _repository;

  UpdatePaymentUseCase(this._repository);

  Future<Payment> call(Payment payment) async {
    return await _repository.updatePayment(payment);
  }
}

final updatePaymentUseCaseProvider = Provider<UpdatePaymentUseCase>((ref) {
  final repository = ref.read(paymentsRepositoryProvider);
  return UpdatePaymentUseCase(repository);
});
