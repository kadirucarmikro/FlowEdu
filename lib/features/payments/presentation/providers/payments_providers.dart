import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/providers/payments_providers.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/lesson_package.dart';
import '../../domain/entities/payment_with_details.dart';
import '../../domain/use_cases/get_payments.dart';
import '../../domain/use_cases/create_payment.dart';
import '../../domain/use_cases/update_payment.dart';
import '../../domain/use_cases/delete_payment.dart';

// Payments List Provider (old - basic)
final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final getPayments = ref.read(getPaymentsUseCaseProvider);
  return await getPayments();
});

// Payments with Details Provider (new - with member and package names)
final paymentsWithDetailsProvider = FutureProvider<List<PaymentWithDetails>>((
  ref,
) async {
  final repository = ref.read(paymentsRepositoryProvider);
  return await repository.getPaymentsWithDetails();
});

// Payment by ID Provider
final paymentProvider = FutureProvider.family<Payment, String>((ref, id) async {
  final repository = ref.read(paymentsRepositoryProvider);
  return await repository.getPaymentById(id);
});

// Payments by Member ID Provider
final paymentsByMemberProvider = FutureProvider.family<List<Payment>, String>((
  ref,
  memberId,
) async {
  final repository = ref.read(paymentsRepositoryProvider);
  return await repository.getPaymentsByMemberId(memberId);
});

// Lesson Packages Provider
final lessonPackagesProvider = FutureProvider<List<LessonPackage>>((ref) async {
  final repository = ref.read(paymentsRepositoryProvider);
  return await repository.getLessonPackages();
});

// Member Package Price and Discount Provider
final memberPackagePriceAndDiscountProvider =
    FutureProvider.family<Map<String, dynamic>?, Map<String, String>>((ref, params) async {
  final repository = ref.read(paymentsRepositoryProvider);
  return await repository.getMemberPackagePriceAndDiscount(
    params['memberId']!,
    params['packageId']!,
  );
});

// Create Payment Provider
final createPaymentProvider = Provider<CreatePaymentUseCase>((ref) {
  return ref.read(createPaymentUseCaseProvider);
});

// Update Payment Provider
final updatePaymentProvider = Provider<UpdatePaymentUseCase>((ref) {
  return ref.read(updatePaymentUseCaseProvider);
});

// Delete Payment Provider
final deletePaymentProvider = Provider<DeletePaymentUseCase>((ref) {
  return ref.read(deletePaymentUseCaseProvider);
});

// Real Members Provider - Supabase'den gerçek veri çekiyor
final realMembersProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('members')
        .select('id, first_name, last_name')
        .order('first_name');

    return response.map<Map<String, String>>((member) {
      final firstName = member['first_name'] as String? ?? '';
      final lastName = member['last_name'] as String? ?? '';
      return {
        'id': member['id'] as String,
        'name': '$firstName $lastName'.trim(),
      };
    }).toList();
  } catch (e) {
    // Hata durumunda mock veri döndür
    return [
      {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Ali Yılmaz'},
      {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Ayşe Demir'},
      {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Mehmet Kaya'},
    ];
  }
});

// Mock Members Provider (fallback)
final mockMembersProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Ali Yılmaz'},
    {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Ayşe Demir'},
    {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Mehmet Kaya'},
  ];
});

// Mock Packages Provider (geçici - gerçek packages provider'ı eklenene kadar)
final mockPackagesProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'name': '8 Derslik Paket'},
    {'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'name': '12 Derslik Paket'},
    {'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'name': '16 Derslik Paket'},
  ];
});
