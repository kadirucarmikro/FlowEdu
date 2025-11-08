import '../../domain/entities/notification_response.dart';

class NotificationResponseModel extends NotificationResponse {
  const NotificationResponseModel({
    required super.id,
    required super.notificationId,
    required super.memberId,
    super.responseText,
    super.optionValue,
    required super.createdAt,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      id: json['id'] as String,
      notificationId: json['notification_id'] as String,
      memberId: json['member_id'] as String,
      responseText: json['response_text'] as String?,
      optionValue: json['option_value'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'member_id': memberId,
      'response_text': responseText,
      'option_value': optionValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationResponseModel.fromEntity(NotificationResponse response) {
    return NotificationResponseModel(
      id: response.id,
      notificationId: response.notificationId,
      memberId: response.memberId,
      responseText: response.responseText,
      optionValue: response.optionValue,
      createdAt: response.createdAt,
    );
  }

  NotificationResponse toEntity() {
    return NotificationResponse(
      id: id,
      notificationId: notificationId,
      memberId: memberId,
      responseText: responseText,
      optionValue: optionValue,
      createdAt: createdAt,
    );
  }
}
