import '../entities/event.dart';
import '../repositories/events_repository_interface.dart';

class GetEvents {
  GetEvents(this._repository);

  final EventsRepository _repository;

  Future<List<Event>> call() async {
    return await _repository.getEvents();
  }
}
