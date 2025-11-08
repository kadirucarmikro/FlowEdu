import '../../domain/entities/member.dart';
import '../../domain/repositories/members_repository.dart';
import '../data_sources/members_remote_data_source.dart';

class MembersRepositoryImpl implements MembersRepository {
  final MembersRemoteDataSource _remoteDataSource;

  MembersRepositoryImpl({required MembersRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Member>> getMembers() async {
    return await _remoteDataSource.getMembers();
  }

  @override
  Future<Member> getMemberById(String id) async {
    return await _remoteDataSource.getMemberById(id);
  }

  @override
  Future<Member> createMember(Member member) async {
    return await _remoteDataSource.createMember(member);
  }

  @override
  Future<Member> updateMember(Member member) async {
    return await _remoteDataSource.updateMember(member);
  }

  @override
  Future<void> deleteMember(String id) async {
    return await _remoteDataSource.deleteMember(id);
  }

  @override
  Future<List<Member>> getActiveMembers() async {
    return await _remoteDataSource.getActiveMembers();
  }

  @override
  Future<List<Member>> getInstructorMembers() async {
    return await _remoteDataSource.getInstructorMembers();
  }

  @override
  Future<Member?> getCurrentMember() async {
    return await _remoteDataSource.getCurrentMember();
  }
}
