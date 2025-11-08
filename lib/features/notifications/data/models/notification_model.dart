import '../../domain/entities/notification.dart' as domain;

class NotificationModel extends domain.Notification {
  String? targetType;
  String? targetId;
  String? targetName;

  NotificationModel({
    required super.id,
    required super.title,
    super.body,
    super.createdBy,
    required super.createdAt,
    super.isRead = false,
    super.hasResponse = false,
    this.targetType,
    this.targetId,
    this.targetName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      hasResponse: json['has_response'] as bool? ?? false,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as String?,
      targetName: json['target_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'has_response': hasResponse,
      'target_type': targetType,
      'target_id': targetId,
      'target_name': targetName,
    };
  }

  @override
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? createdBy,
    DateTime? createdAt,
    bool? isRead,
    bool? hasResponse,
    String? targetType,
    String? targetId,
    String? targetName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      hasResponse: hasResponse ?? this.hasResponse,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
    );
  }
}
