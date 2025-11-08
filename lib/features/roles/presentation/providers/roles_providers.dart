import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_sources/roles_remote_data_source.dart';
import '../../data/repositories/roles_repository_impl.dart';
import '../../domain/use_cases/get_roles.dart';
import '../../domain/use_cases/create_role.dart';
import '../../domain/use_cases/update_role.dart';
import '../../domain/use_cases/delete_role.dart';

// Data Source Provider
final rolesRemoteDataSourceProvider = Provider<RolesRemoteDataSource>((ref) {
  return RolesRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository Provider
final rolesRepositoryProvider = Provider<RolesRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(rolesRemoteDataSourceProvider);
  return RolesRepositoryImpl(remoteDataSource);
});

// Use Cases Providers
final getRolesProvider = Provider<GetRoles>((ref) {
  final repository = ref.watch(rolesRepositoryProvider);
  return GetRoles(repository);
});

final createRoleProvider = Provider<CreateRole>((ref) {
  final repository = ref.watch(rolesRepositoryProvider);
  return CreateRole(repository);
});

final updateRoleProvider = Provider<UpdateRole>((ref) {
  final repository = ref.watch(rolesRepositoryProvider);
  return UpdateRole(repository);
});

final deleteRoleProvider = Provider<DeleteRole>((ref) {
  final repository = ref.watch(rolesRepositoryProvider);
  return DeleteRole(repository);
});

// Roles List Provider
final rolesListProvider = FutureProvider((ref) async {
  final getRoles = ref.watch(getRolesProvider);
  return await getRoles();
});
