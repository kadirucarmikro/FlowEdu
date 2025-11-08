import '../repositories/notifications_repository_interface.dart';

class DeleteNotification {
  final NotificationsRepositoryInterface _repository;

  DeleteNotification(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteNotification(id);
  }
}
