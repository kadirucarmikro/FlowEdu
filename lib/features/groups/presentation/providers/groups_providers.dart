import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_sources/groups_remote_data_source.dart';
import '../../data/repositories/groups_repository_impl.dart';
import '../../domain/use_cases/get_groups.dart';
import '../../domain/use_cases/create_group.dart';
import '../../domain/use_cases/update_group.dart';
import '../../domain/use_cases/delete_group.dart';

// Data Source Provider
final groupsRemoteDataSourceProvider = Provider<GroupsRemoteDataSource>((ref) {
  return GroupsRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository Provider
final groupsRepositoryProvider = Provider<GroupsRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(groupsRemoteDataSourceProvider);
  return GroupsRepositoryImpl(remoteDataSource);
});

// Use Cases Providers
final getGroupsProvider = Provider<GetGroups>((ref) {
  final repository = ref.watch(groupsRepositoryProvider);
  return GetGroups(repository);
});

final createGroupProvider = Provider<CreateGroup>((ref) {
  final repository = ref.watch(groupsRepositoryProvider);
  return CreateGroup(repository);
});

final updateGroupProvider = Provider<UpdateGroup>((ref) {
  final repository = ref.watch(groupsRepositoryProvider);
  return UpdateGroup(repository);
});

final deleteGroupProvider = Provider<DeleteGroup>((ref) {
  final repository = ref.watch(groupsRepositoryProvider);
  return DeleteGroup(repository);
});

// Groups List Provider
final groupsListProvider = FutureProvider((ref) async {
  final getGroups = ref.watch(getGroupsProvider);
  return await getGroups();
});
