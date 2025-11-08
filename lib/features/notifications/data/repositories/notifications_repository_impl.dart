import '../data_sources/notifications_remote_data_source.dart';
import '../../domain/repositories/notifications_repository_interface.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepositoryInterface {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _remoteDataSource.getNotifications();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      return await _remoteDataSource.getNotificationById(id);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(
    Map<String, dynamic> data,
  ) async {
    try {
      return await _remoteDataSource.createNotification(data);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<NotificationModel> updateNotification(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _remoteDataSource.updateNotification(id, data);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _remoteDataSource.deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getMemberNotifications() async {
    try {
      return await _remoteDataSource.getMemberNotifications();
    } catch (e) {
      throw Exception('Failed to get member notifications: $e');
    }
  }

  @override
  Future<void> createNotificationTargets(
    String notificationId,
    List<Map<String, dynamic>> targets,
  ) async {
    try {
      await _remoteDataSource.createNotificationTargets(
        notificationId,
        targets,
      );
    } catch (e) {
      throw Exception('Failed to create notification targets: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
