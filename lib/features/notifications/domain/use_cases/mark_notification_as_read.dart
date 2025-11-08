import '../repositories/notifications_repository_interface.dart';

class MarkNotificationAsRead {
  final NotificationsRepositoryInterface _repository;

  MarkNotificationAsRead(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.markNotificationAsRead(notificationId);
  }
}
