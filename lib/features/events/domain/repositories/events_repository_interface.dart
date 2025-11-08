import '../entities/event.dart';

abstract class EventsRepository {
  // CRUD Operations
  Future<List<Event>> getEvents();
  Future<Event?> getEventById(String id);
  Future<Event> createEvent({
    required String title,
    String? description,
    String? richDescription,
    String? imageUrl,
    required EventType type,
    required bool isMultipleChoice,
    DateTime? startAt,
    DateTime? endAt,
    String? location,
    int? maxParticipants,
    DateTime? registrationDeadline,
    List<String>? optionTexts,
  });
  Future<Event> updateEvent({
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
  });
  Future<void> deleteEvent(String id);

  // Event Options
  Future<List<EventOption>> getEventOptions(String eventId);
  Future<EventOption> createEventOption({
    required String eventId,
    required String optionText,
  });
  Future<void> deleteEventOption(String optionId);

  // Event Responses
  Future<List<EventResponse>> getEventResponses(String eventId);
  Future<EventResponse> createEventResponse({
    required String eventId,
    String? optionId,
    String? responseText,
  });
  Future<EventResponse?> getMemberEventResponse({
    required String eventId,
    required String memberId,
  });
  Future<EventResponse> updateEventResponse({
    required String responseId,
    String? optionId,
    String? responseText,
  });
  Future<void> deleteEventResponse(String responseId);

  // Event Organizers
  Future<List<EventOrganizer>> getEventOrganizers(String eventId);
  Future<EventOrganizer> createEventOrganizer({
    required String eventId,
    required String memberId,
    required String role,
  });
  Future<void> deleteEventOrganizer(String organizerId);
  Future<void> deleteEventOrganizersByEventId(String eventId);

  // Event Instructors
  Future<List<EventInstructor>> getEventInstructors(String eventId);
  Future<EventInstructor> createEventInstructor({
    required String eventId,
    required String memberId,
    required String role,
  });
  Future<void> deleteEventInstructor(String instructorId);
  Future<void> deleteEventInstructorsByEventId(String eventId);

  // Event Questions
  Future<EventQuestion> createEventQuestion({
    required String eventId,
    required String questionText,
    required String questionType,
    required bool isRequired,
    required int sortOrder,
  });
  Future<void> deleteEventQuestionsByEventId(String eventId);

  Future<EventQuestionOption> createEventQuestionOption({
    required String questionId,
    required String optionText,
    required int sortOrder,
  });

  Future<List<EventQuestionOption>> getQuestionOptions(String questionId);

  Future<void> updateQuestionResponse({
    required String questionId,
    required String memberId,
    String? optionId,
    required String responseText,
  });

  // Event Media
  Future<EventMedia> createEventMedia({
    required String eventId,
    required String fileName,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? uploadedBy,
  });
  Future<void> deleteEventMedia(String mediaId);
  Future<void> deleteEventMediaByEventId(String eventId);

  // Current Member
  Future<Map<String, dynamic>?> getCurrentMember();

  // Question Responses
  Future<List<EventQuestionResponse>> getQuestionResponses({
    required String eventId,
    required String memberId,
  });
  Future<EventQuestionResponse> createQuestionResponse({
    required String questionId,
    required String memberId,
    String? optionId,
    String? responseText,
  });

  // Admin için tüm üye yanıtlarını getir
  Future<List<EventQuestionResponse>> getAllQuestionResponsesForEvent(
    String eventId,
  );

  // File Upload
  Future<String> uploadFileToStorage({
    required String fileName,
    required List<int> fileBytes,
    required String fileType,
  });
}
