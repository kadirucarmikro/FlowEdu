import 'member_entity.dart';

abstract class MembersRepository {
  Future<MemberEntity?> getCurrentMember();
  Future<List<MemberEntity>> getAllMembers();
  Future<MemberEntity> updateCurrentMember({
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthDate,
  });
  Future<MemberEntity> updateMemberRoleAndGroup({
    required String memberId,
    String? roleId,
    String? groupId,
  });
}
