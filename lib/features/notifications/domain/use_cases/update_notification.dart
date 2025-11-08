import '../repositories/notifications_repository_interface.dart';
import '../../data/models/notification_model.dart';

class UpdateNotification {
  final NotificationsRepositoryInterface _repository;

  UpdateNotification(this._repository);

  Future<NotificationModel> call(String id, Map<String, dynamic> data) async {
    return await _repository.updateNotification(id, data);
  }
}
