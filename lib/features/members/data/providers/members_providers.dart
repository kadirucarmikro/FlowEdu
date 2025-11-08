import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../data_sources/members_remote_data_source.dart';
import '../repositories/members_repository_impl.dart';
import '../../domain/entities/member.dart';

// Data Source Provider
final membersRemoteDataSourceProvider = Provider<MembersRemoteDataSource>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return MembersRemoteDataSource(supabase: supabase.client);
});

// Repository Provider
final membersRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(membersRemoteDataSourceProvider);
  return MembersRepositoryImpl(remoteDataSource: remoteDataSource);
});

// All Members Provider
final membersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  return await repository.getMembers();
});

// Active Members Provider
final activeMembersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  return await repository.getActiveMembers();
});

// Instructor Members Provider (Eğitmen olan üyeler)
final instructorMembersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  return await repository.getInstructorMembers();
});

// Current Member Provider (Giriş yapan kullanıcının bilgileri)
final currentMemberProvider = FutureProvider<Member?>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  try {
    return await repository.getCurrentMember();
  } catch (e) {
    return null;
  }
});
