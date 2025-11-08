import '../../domain/entities/member.dart';

class MemberModel extends Member {
  MemberModel({
    required super.id,
    required super.userId,
    required super.roleId,
    super.groupId,
    required super.firstName,
    required super.lastName,
    super.phone,
    required super.email,
    super.birthDate,
    super.isSuspended = false,
    required super.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roleId: json['role_id'] as String,
      groupId: json['group_id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      isSuspended: json['is_suspended'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role_id': roleId,
      'group_id': groupId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'birth_date': birthDate?.toIso8601String(),
      'is_suspended': isSuspended,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'group_id': groupId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'birth_date': birthDate?.toIso8601String(),
      'is_suspended': isSuspended,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};
    if (firstName.isNotEmpty) json['first_name'] = firstName;
    if (lastName.isNotEmpty) json['last_name'] = lastName;
    if (phone != null) json['phone'] = phone;
    if (email.isNotEmpty) json['email'] = email;
    if (birthDate != null) json['birth_date'] = birthDate!.toIso8601String();
    json['is_suspended'] = isSuspended;
    return json;
  }
}
