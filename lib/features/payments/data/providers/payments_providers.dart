import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data_sources/payments_remote_data_source.dart';
import '../repositories/payments_repository_impl.dart';
import '../../domain/repositories/payments_repository.dart';

// Data Source Provider
final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return PaymentsRemoteDataSourceImpl(supabase);
});

// Repository Provider
final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final remoteDataSource = ref.read(paymentsRemoteDataSourceProvider);
  return PaymentsRepositoryImpl(remoteDataSource);
});
