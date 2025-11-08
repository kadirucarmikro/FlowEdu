class NotificationResponse {
  final String id;
  final String notificationId;
  final String memberId;
  final String? responseText;
  final String? optionValue;
  final DateTime createdAt;

  const NotificationResponse({
    required this.id,
    required this.notificationId,
    required this.memberId,
    this.responseText,
    this.optionValue,
    required this.createdAt,
  });

  NotificationResponse copyWith({
    String? id,
    String? notificationId,
    String? memberId,
    String? responseText,
    String? optionValue,
    DateTime? createdAt,
  }) {
    return NotificationResponse(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      memberId: memberId ?? this.memberId,
      responseText: responseText ?? this.responseText,
      optionValue: optionValue ?? this.optionValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationResponse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationResponse(id: $id, notificationId: $notificationId, memberId: $memberId)';
  }
}
