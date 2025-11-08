class Room {
  final String id;
  final String name;
  final int capacity;
  final String? features;
  final bool isActive;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    this.features,
    required this.isActive,
    required this.createdAt,
  });

  // JSON serialization
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      features: json['features'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'features': features,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String get displayName => '$name (Kapasite: $capacity)';

  String get featuresDisplay => features ?? 'Özellik belirtilmemiş';

  Room copyWith({
    String? id,
    String? name,
    int? capacity,
    String? features,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, capacity: $capacity, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
