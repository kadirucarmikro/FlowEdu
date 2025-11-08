import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';
import '../../data/providers/payments_providers.dart';

class GetPaymentsUseCase {
  final PaymentsRepository _repository;

  GetPaymentsUseCase(this._repository);

  Future<List<Payment>> call() async {
    return await _repository.getPayments();
  }
}

final getPaymentsUseCaseProvider = Provider<GetPaymentsUseCase>((ref) {
  final repository = ref.read(paymentsRepositoryProvider);
  return GetPaymentsUseCase(repository);
});
