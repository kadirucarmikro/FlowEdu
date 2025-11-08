class Notification {
  final String id;
  final String title;
  final String? body;
  final String? createdBy;
  final DateTime createdAt;
  final bool isRead;
  final bool hasResponse;

  const Notification({
    required this.id,
    required this.title,
    this.body,
    this.createdBy,
    required this.createdAt,
    this.isRead = false,
    this.hasResponse = false,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? createdBy,
    DateTime? createdAt,
    bool? isRead,
    bool? hasResponse,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      hasResponse: hasResponse ?? this.hasResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, isRead: $isRead)';
  }
}
