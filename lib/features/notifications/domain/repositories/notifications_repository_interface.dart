import '../../data/models/notification_model.dart';

abstract class NotificationsRepositoryInterface {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> getNotificationById(String id);
  Future<NotificationModel> createNotification(Map<String, dynamic> data);
  Future<NotificationModel> updateNotification(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteNotification(String id);
  Future<List<NotificationModel>> getMemberNotifications();
  Future<void> createNotificationTargets(
    String notificationId,
    List<Map<String, dynamic>> targets,
  );
  Future<void> markNotificationAsRead(String notificationId);
}
