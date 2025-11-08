import '../../domain/entities/screen.dart';

class ScreenModel extends Screen {
  const ScreenModel({
    required super.id,
    required super.name,
    required super.route,
    super.description,
    required super.isActive,
    required super.createdAt,
  });

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    return ScreenModel(
      id: json['id'] as String,
      name: json['name'] as String,
      route: json['route'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'route': route,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScreenModel.fromEntity(Screen screen) {
    return ScreenModel(
      id: screen.id,
      name: screen.name,
      route: screen.route,
      description: screen.description,
      isActive: screen.isActive,
      createdAt: screen.createdAt,
    );
  }

  Screen toEntity() {
    return Screen(
      id: id,
      name: name,
      route: route,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
