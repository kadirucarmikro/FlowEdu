class NotificationTargetModel {
  final String id;
  final String notificationId;
  final String targetType; // 'role', 'group', 'member', 'birthday'
  final String? targetId; // role_id, group_id, member_id (birthday için null)
  final DateTime createdAt;

  const NotificationTargetModel({
    required this.id,
    required this.notificationId,
    required this.targetType,
    this.targetId,
    required this.createdAt,
  });

  factory NotificationTargetModel.fromJson(Map<String, dynamic> json) {
    return NotificationTargetModel(
      id: json['id'] as String,
      notificationId: json['notification_id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'target_type': targetType,
      'target_id': targetId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationTargetModel copyWith({
    String? id,
    String? notificationId,
    String? targetType,
    String? targetId,
    DateTime? createdAt,
  }) {
    return NotificationTargetModel(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Target type validation
  bool get isValidTargetType {
    return ['role', 'group', 'member', 'birthday'].contains(targetType);
  }

  // Birthday target doesn't need target_id
  bool get isBirthdayTarget => targetType == 'birthday';

  // Other targets need target_id
  bool get needsTargetId => !isBirthdayTarget;
}
