class NotificationTarget {
  final String id;
  final String notificationId;
  final String memberId;

  const NotificationTarget({
    required this.id,
    required this.notificationId,
    required this.memberId,
  });

  NotificationTarget copyWith({
    String? id,
    String? notificationId,
    String? memberId,
  }) {
    return NotificationTarget(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      memberId: memberId ?? this.memberId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTarget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationTarget(id: $id, notificationId: $notificationId, memberId: $memberId)';
  }
}
