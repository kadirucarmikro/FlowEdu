import '../../domain/entities/lesson_package.dart';

class LessonPackageModel extends LessonPackage {
  const LessonPackageModel({
    required super.id,
    required super.name,
    required super.lessonCount,
    required super.price,
    required super.isActive,
    required super.createdAt,
  });

  factory LessonPackageModel.fromJson(Map<String, dynamic> json) {
    return LessonPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lessonCount: json['lesson_count'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lesson_count': lessonCount,
      'price': price,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'lesson_count': lessonCount,
      'price': price,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'lesson_count': lessonCount,
      'price': price,
      'is_active': isActive,
    };
  }

  LessonPackageModel copyWith({
    String? id,
    String? name,
    int? lessonCount,
    double? price,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return LessonPackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lessonCount: lessonCount ?? this.lessonCount,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
