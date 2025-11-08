class Role {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const Role({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  Role copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        other.id == id &&
        other.name == name &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isActive.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, isActive: $isActive, createdAt: $createdAt)';
  }
}
