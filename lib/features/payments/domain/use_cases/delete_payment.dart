import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/payments_repository.dart';
import '../../data/providers/payments_providers.dart';

class DeletePaymentUseCase {
  final PaymentsRepository _repository;

  DeletePaymentUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deletePayment(id);
  }
}

final deletePaymentUseCaseProvider = Provider<DeletePaymentUseCase>((ref) {
  final repository = ref.read(paymentsRepositoryProvider);
  return DeletePaymentUseCase(repository);
});
