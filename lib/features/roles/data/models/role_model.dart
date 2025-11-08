import '../../domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.createdAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoleModel.fromEntity(Role role) {
    return RoleModel(
      id: role.id,
      name: role.name,
      isActive: role.isActive,
      createdAt: role.createdAt,
    );
  }

  Role toEntity() {
    return Role(id: id, name: name, isActive: isActive, createdAt: createdAt);
  }
}
