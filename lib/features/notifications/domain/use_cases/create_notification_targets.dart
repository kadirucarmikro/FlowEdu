import '../repositories/notifications_repository_interface.dart';

class CreateNotificationTargets {
  final NotificationsRepositoryInterface _repository;

  CreateNotificationTargets(this._repository);

  Future<void> call(
    String notificationId,
    List<Map<String, dynamic>> targets,
  ) async {
    await _repository.createNotificationTargets(notificationId, targets);
  }
}
