import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/about_remote_data_source.dart';
import '../repositories/about_repository_impl.dart';

// Data Sources
final aboutRemoteDataSourceProvider = Provider<AboutRemoteDataSource>((ref) {
  return AboutRemoteDataSourceImpl();
});

// Repositories
final aboutRepositoryProvider = Provider<AboutRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(aboutRemoteDataSourceProvider);
  return AboutRepositoryImpl(remoteDataSource);
});
