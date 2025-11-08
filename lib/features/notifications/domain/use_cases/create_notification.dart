import '../repositories/notifications_repository_interface.dart';
import '../../data/models/notification_model.dart';

class CreateNotification {
  final NotificationsRepositoryInterface _repository;

  CreateNotification(this._repository);

  Future<NotificationModel> call(Map<String, dynamic> data) async {
    return await _repository.createNotification(data);
  }
}
