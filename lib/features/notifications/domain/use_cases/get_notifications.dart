import '../repositories/notifications_repository_interface.dart';
import '../../data/models/notification_model.dart';

class GetNotifications {
  final NotificationsRepositoryInterface _repository;

  GetNotifications(this._repository);

  Future<List<NotificationModel>> call() async {
    return await _repository.getNotifications();
  }
}
