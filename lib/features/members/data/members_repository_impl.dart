import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/member_entity.dart';
import '../domain/members_repository.dart';

class MembersRepositoryImpl implements MembersRepository {
  MembersRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<MemberEntity?> getCurrentMember() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final data = await _client
          .from('members')
          .select(
            'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
          )
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return _mapToEntity(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MemberEntity>> getAllMembers() async {
    final data = await _client
        .from('members')
        .select(
          'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
        )
        .order('created_at', ascending: false);

    return data.map((row) => _mapToEntity(row)).toList();
  }

  @override
  Future<MemberEntity> updateCurrentMember({
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthDate,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No current user');
    }
    // Ensure row exists first to avoid NOT NULL role_id constraint on insert
    final existing = await getCurrentMember();
    if (existing == null) {
      await _client.rpc(
        'ensure_member_for_current_user',
        params: {'p_email': user.email ?? ''},
      );
    }

    // Update fields for current user
    final updated = await _client
        .from('members')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'birth_date': birthDate?.toIso8601String().split('T')[0],
        })
        .eq('user_id', user.id)
        .select(
          'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
        )
        .maybeSingle();

    final Map<String, dynamic> row =
        (updated ??
                await _client
                    .from('members')
                    .select(
                      'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
                    )
                    .eq('user_id', user.id)
                    .maybeSingle())
            as Map<String, dynamic>;
    return _mapToEntity(row);
  }

  @override
  Future<MemberEntity> updateMemberRoleAndGroup({
    required String memberId,
    String? roleId,
    String? groupId,
  }) async {
    final updateData = <String, dynamic>{};
    if (roleId != null) updateData['role_id'] = roleId;
    if (groupId != null) updateData['group_id'] = groupId;

    if (updateData.isEmpty) {
      throw ArgumentError('At least one of roleId or groupId must be provided');
    }

    final updated = await _client
        .from('members')
        .update(updateData)
        .eq('id', memberId)
        .select(
          'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
        )
        .single();

    return _mapToEntity(updated);
  }

  // Admin için member güncelleme metodu
  Future<MemberEntity> updateMember({
    required String memberId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String roleId,
    required String groupId,
    required bool isSuspended,
    bool isInstructor = false,
    String? specialization,
    String? instructorBio,
    String? instructorExperience,
  }) async {
    final data = await _client
        .from('members')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'role_id': roleId,
          'group_id': groupId,
          'is_suspended': isSuspended,
          'is_instructor': isInstructor,
          'specialization': specialization,
          'instructor_bio': instructorBio,
          'instructor_experience': instructorExperience,
        })
        .eq('id', memberId)
        .select(
          'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
        )
        .single();
    return _mapToEntity(data);
  }

  // Admin için member silme metodu
  Future<void> deleteMember(String memberId) async {
    await _client.from('members').delete().eq('id', memberId);
  }

  // Admin için yeni member ekleme metodu
  Future<MemberEntity> addMember({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String roleId,
    required String groupId,
    DateTime? birthDate,
  }) async {
    // Önce Supabase Auth ile user oluştur
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Kullanıcı oluşturulamadı');
    }

    // Sonra member kaydı oluştur
    final data = await _client
        .from('members')
        .insert({
          'user_id': authResponse.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role_id': roleId,
          'group_id': groupId,
          'birth_date': birthDate?.toIso8601String().split('T')[0],
          'is_suspended': false,
        })
        .select(
          'id,user_id,email,first_name,last_name,phone,role_id,group_id,is_suspended,birth_date,created_at,is_instructor,specialization,instructor_bio,instructor_experience, roles(name), groups(name)',
        )
        .single();

    return _mapToEntity(data);
  }

  MemberEntity _mapToEntity(Map<String, dynamic> row) {
    return MemberEntity(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      email: row['email'] as String? ?? '',
      firstName: row['first_name'] as String? ?? '',
      lastName: row['last_name'] as String? ?? '',
      phone: row['phone'] as String?,
      roleId: row['role_id'] as String?,
      groupId: row['group_id'] as String?,
      isSuspended: row['is_suspended'] as bool? ?? false,
      roleName: (row['roles']?['name'] as String?) ?? '',
      groupName: (row['groups']?['name'] as String?) ?? '',
      birthDate: row['birth_date'] != null
          ? DateTime.parse(row['birth_date'] as String)
          : null,
      createdDate: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      isInstructor: row['is_instructor'] as bool? ?? false,
      specialization: row['specialization'] as String?,
      instructorBio: row['instructor_bio'] as String?,
      instructorExperience: row['instructor_experience'] as String?,
    );
  }
}
