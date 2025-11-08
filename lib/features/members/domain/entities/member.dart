class Member {
  Member({
    required this.id,
    required this.userId,
    required this.roleId,
    this.groupId,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.email,
    this.password,
    this.birthDate,
    this.isSuspended = false,
    this.isInstructor = false,
    this.specialization,
    this.instructorBio,
    this.instructorExperience,
    required this.createdAt,
    this.roleName,
  });

  final String id;
  final String userId;
  final String roleId;
  final String? groupId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String email;
  final String? password;
  final DateTime? birthDate;
  final bool isSuspended;
  final bool isInstructor;
  final String? specialization;
  final String? instructorBio;
  final String? instructorExperience;
  final DateTime createdAt;
  final String? roleName;

  // JSON serialization
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roleId: json['role_id'] as String,
      groupId: json['group_id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      isSuspended: json['is_suspended'] as bool? ?? false,
      isInstructor: json['is_instructor'] as bool? ?? false,
      specialization: json['specialization'] as String?,
      instructorBio: json['instructor_bio'] as String?,
      instructorExperience: json['instructor_experience'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      roleName: json['roles'] != null ? json['roles']['name'] as String? : null,
    );
  }

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
      'password': password,
      'birth_date': birthDate?.toIso8601String(),
      'is_suspended': isSuspended,
      'is_instructor': isInstructor,
      'specialization': specialization,
      'instructor_bio': instructorBio,
      'instructor_experience': instructorExperience,
      'created_at': createdAt.toIso8601String(),
      'role_name': roleName,
    };
  }

  // Helper methods
  String get fullName => '$firstName $lastName';

  String get displayName =>
      isInstructor ? '$fullName (${specialization ?? 'Eğitmen'})' : fullName;

  Member copyWith({
    String? id,
    String? userId,
    String? roleId,
    String? groupId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
    DateTime? birthDate,
    bool? isSuspended,
    bool? isInstructor,
    String? specialization,
    String? instructorBio,
    String? instructorExperience,
    DateTime? createdAt,
    String? roleName,
  }) {
    return Member(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      groupId: groupId ?? this.groupId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      isSuspended: isSuspended ?? this.isSuspended,
      isInstructor: isInstructor ?? this.isInstructor,
      specialization: specialization ?? this.specialization,
      instructorBio: instructorBio ?? this.instructorBio,
      instructorExperience: instructorExperience ?? this.instructorExperience,
      createdAt: createdAt ?? this.createdAt,
      roleName: roleName ?? this.roleName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Member(id: $id, name: $fullName, email: $email, isInstructor: $isInstructor)';
  }
}
