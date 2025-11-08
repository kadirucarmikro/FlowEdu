import '../repositories/notifications_repository_interface.dart';
import '../../data/models/notification_model.dart';

class GetMemberNotifications {
  final NotificationsRepositoryInterface _repository;

  GetMemberNotifications(this._repository);

  Future<List<NotificationModel>> call() async {
    return await _repository.getMemberNotifications();
  }
}
