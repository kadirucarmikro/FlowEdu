import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
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

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      isActive: group.isActive,
      createdAt: group.createdAt,
    );
  }

  Group toEntity() {
    return Group(id: id, name: name, isActive: isActive, createdAt: createdAt);
  }
}
