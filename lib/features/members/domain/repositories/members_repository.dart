import '../entities/member.dart';

abstract class MembersRepository {
  Future<List<Member>> getMembers();
  Future<Member> getMemberById(String id);
  Future<Member> createMember(Member member);
  Future<Member> updateMember(Member member);
  Future<void> deleteMember(String id);
  Future<List<Member>> getActiveMembers();
  Future<List<Member>> getInstructorMembers();
  Future<Member?> getCurrentMember();
}
