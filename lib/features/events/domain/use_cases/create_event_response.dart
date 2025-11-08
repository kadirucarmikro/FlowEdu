import '../entities/event.dart';
import '../repositories/events_repository_interface.dart';

class CreateEventResponse {
  CreateEventResponse(this._repository);

  final EventsRepository _repository;

  Future<EventResponse> call({
    required String eventId,
    String? optionId,
    String? responseText,
  }) async {
    return await _repository.createEventResponse(
      eventId: eventId,
      optionId: optionId,
      responseText: responseText,
    );
  }
}
