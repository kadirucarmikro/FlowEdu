import '../repositories/events_repository_interface.dart';

class DeleteEvent {
  DeleteEvent(this._repository);

  final EventsRepository _repository;

  Future<void> call(String id) async {
    return await _repository.deleteEvent(id);
  }
}
