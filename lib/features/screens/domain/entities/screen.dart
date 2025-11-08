class Screen {
  final String id;
  final String name;
  final String route;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  const Screen({
    required this.id,
    required this.name,
    required this.route,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  Screen copyWith({
    String? id,
    String? name,
    String? route,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Screen(
      id: id ?? this.id,
      name: name ?? this.name,
      route: route ?? this.route,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Screen &&
        other.id == id &&
        other.name == name &&
        other.route == route &&
        other.description == description &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        route.hashCode ^
        description.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Screen(id: $id, name: $name, route: $route, description: $description, isActive: $isActive, createdAt: $createdAt)';
  }
}
