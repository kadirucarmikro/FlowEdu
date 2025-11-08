class Event {
  Event({
    required this.id,
    required this.title,
    this.description,
    this.richDescription,
    this.imageUrl,
    this.mediaUrls = const [],
    required this.type,
    required this.isMultipleChoice,
    this.responseType = EventResponseType.text,
    this.startAt,
    this.endAt,
    this.location,
    this.maxParticipants,
    this.registrationDeadline,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    this.options = const [],
    this.organizers = const [],
    this.instructors = const [],
    this.participants = const [],
    this.questions = const [],
    this.media = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String? richDescription; // HTML formatında zengin açıklama
  final String? imageUrl;
  final List<String> mediaUrls; // Medya URL'leri
  final EventType type;
  final bool isMultipleChoice;
  final EventResponseType responseType;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final int? maxParticipants;
  final DateTime? registrationDeadline;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final List<EventOption> options;
  final List<EventOrganizer> organizers;
  final List<EventInstructor> instructors;
  final List<EventParticipant> participants;
  final List<EventQuestion> questions;
  final List<EventMedia> media;
}

enum EventType {
  normal('normal'),
  interactive('interactive'),
  poll('poll'),
  workshop('workshop'),
  seminar('seminar'),
  conference('conference');

  const EventType(this.value);
  final String value;

  static EventType fromString(String value) {
    switch (value) {
      case 'normal':
        return EventType.normal;
      case 'interactive':
        return EventType.interactive;
      case 'poll':
        return EventType.poll;
      case 'workshop':
        return EventType.workshop;
      case 'seminar':
        return EventType.seminar;
      case 'conference':
        return EventType.conference;
      default:
        return EventType.normal;
    }
  }
}

enum EventResponseType {
  text('text'),
  singleChoice('single_choice'),
  multipleChoice('multiple_choice');

  const EventResponseType(this.value);
  final String value;

  static EventResponseType fromString(String value) {
    switch (value) {
      case 'text':
        return EventResponseType.text;
      case 'single_choice':
        return EventResponseType.singleChoice;
      case 'multiple_choice':
        return EventResponseType.multipleChoice;
      default:
        return EventResponseType.text;
    }
  }
}

class EventOption {
  EventOption({
    required this.id,
    required this.eventId,
    required this.optionText,
  });

  final String id;
  final String eventId;
  final String optionText;
}

class EventResponse {
  EventResponse({
    required this.id,
    required this.eventId,
    required this.memberId,
    this.optionId,
    this.responseText,
    required this.createdAt,
    this.memberName,
    this.memberSurname,
  });

  final String id;
  final String eventId;
  final String memberId;
  final String? optionId;
  final String? responseText;
  final DateTime createdAt;
  String? memberName;
  String? memberSurname;
}

// Yeni Entity'ler

class EventOrganizer {
  EventOrganizer({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.role,
    required this.createdAt,
    this.memberName,
  });

  final String id;
  final String eventId;
  final String memberId;
  final String role; // organizer, co-organizer, assistant
  final DateTime createdAt;
  final String? memberName; // JOIN'den gelen isim
}

class EventInstructor {
  EventInstructor({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.role,
    required this.createdAt,
    this.memberName,
  });

  final String id;
  final String eventId;
  final String memberId;
  final String role; // instructor, co-instructor, assistant
  final DateTime createdAt;
  final String? memberName; // JOIN'den gelen isim
}

class EventParticipant {
  EventParticipant({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.registrationDate,
    required this.status,
    this.notes,
    this.memberName,
  });

  final String id;
  final String eventId;
  final String memberId;
  final DateTime registrationDate;
  final String status; // registered, confirmed, attended, cancelled
  final String? notes;
  final String? memberName; // JOIN'den gelen isim
}

class EventQuestion {
  EventQuestion({
    required this.id,
    required this.eventId,
    required this.questionText,
    required this.questionType,
    required this.isRequired,
    required this.sortOrder,
    required this.createdAt,
    this.options = const [],
  });

  final String id;
  final String eventId;
  final String questionText;
  final String questionType; // text, single_choice, multiple_choice
  final bool isRequired;
  final int sortOrder;
  final DateTime createdAt;
  final List<EventQuestionOption> options;
}

class EventQuestionOption {
  EventQuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String questionId;
  final String optionText;
  final int sortOrder;
  final DateTime createdAt;
}

class EventQuestionResponse {
  EventQuestionResponse({
    required this.id,
    required this.questionId,
    required this.memberId,
    this.optionId,
    this.responseText,
    required this.createdAt,
    this.memberName,
    this.memberSurname,
  });

  final String id;
  final String questionId;
  final String memberId;
  final String? optionId;
  final String? responseText;
  final DateTime createdAt;
  final String? memberName;
  final String? memberSurname;
}

class EventMedia {
  EventMedia({
    required this.id,
    required this.eventId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    this.uploadedBy,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String fileName;
  final String fileUrl;
  final String fileType; // image, video, document, audio
  final int? fileSize;
  final String? uploadedBy;
  final DateTime createdAt;
}
