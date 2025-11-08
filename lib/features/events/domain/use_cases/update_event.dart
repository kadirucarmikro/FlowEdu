import '../entities/event.dart';
import '../repositories/events_repository_interface.dart';

class UpdateEvent {
  UpdateEvent(this._repository);

  final EventsRepository _repository;

  Future<Event> call({
    required String id,
    String? title,
    String? description,
    String? richDescription,
    String? imageUrl,
    EventType? type,
    bool? isMultipleChoice,
    DateTime? startAt,
    DateTime? endAt,
    String? location,
    int? maxParticipants,
    DateTime? registrationDeadline,
    List<String>? optionTexts,
  }) async {
    return await _repository.updateEvent(
      id: id,
      title: title,
      description: description,
      richDescription: richDescription,
      imageUrl: imageUrl,
      type: type,
      isMultipleChoice: isMultipleChoice,
      startAt: startAt,
      endAt: endAt,
      location: location,
      maxParticipants: maxParticipants,
      registrationDeadline: registrationDeadline,
      optionTexts: optionTexts,
    );
  }
}
