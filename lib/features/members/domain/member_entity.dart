class MemberEntity {
  MemberEntity({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.roleId,
    this.groupId,
    required this.isSuspended,
    this.roleName = '',
    this.groupName = '',
    this.birthDate,
    this.createdDate,
    this.isInstructor = false,
    this.specialization,
    this.instructorBio,
    this.instructorExperience,
  });

  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? roleId;
  final String? groupId;
  final bool isSuspended;
  final String roleName;
  final String groupName;
  final DateTime? birthDate;
  final DateTime? createdDate;
  final bool isInstructor;
  final String? specialization;
  final String? instructorBio;
  final String? instructorExperience;
}
