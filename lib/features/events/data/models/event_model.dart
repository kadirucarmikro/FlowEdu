import '../../domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.title,
    super.description,
    super.richDescription,
    super.imageUrl,
    super.mediaUrls = const [],
    required super.type,
    required super.isMultipleChoice,
    super.responseType = EventResponseType.text,
    super.startAt,
    super.endAt,
    super.location,
    super.maxParticipants,
    super.registrationDeadline,
    super.isActive = true,
    super.createdBy,
    required super.createdAt,
    super.options = const [],
    super.organizers = const [],
    super.instructors = const [],
    super.participants = const [],
    super.questions = const [],
    super.media = const [],
  }) {
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final richDesc = json['rich_description'] as String?;

    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      richDescription: richDesc,
      imageUrl: json['image_url'] as String?,
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
              ?.map((url) => url as String)
              .toList() ??
          [],
      type: EventType.fromString(json['type'] as String),
      isMultipleChoice: json['is_multiple_choice'] as bool? ?? false,
      responseType: EventResponseType.fromString(
        json['response_type'] as String? ?? 'text',
      ),
      startAt: json['start_at'] != null
          ? DateTime.parse(json['start_at'] as String)
          : null,
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      location: json['location'] as String?,
      maxParticipants: json['max_participants'] as int?,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (option) =>
                    EventOptionModel.fromJson(option as Map<String, dynamic>),
              )
              .toList() ??
          [],
      organizers:
          (json['organizers'] as List<dynamic>?)
              ?.map(
                (organizer) => EventOrganizerModel.fromJson(
                  organizer as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      instructors:
          (json['instructors'] as List<dynamic>?)
              ?.map(
                (instructor) => EventInstructorModel.fromJson(
                  instructor as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (participant) => EventParticipantModel.fromJson(
                  participant as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (question) => EventQuestionModel.fromJson(
                  question as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      media:
          (json['media'] as List<dynamic>?)
              ?.map(
                (media) =>
                    EventMediaModel.fromJson(media as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rich_description': richDescription,
      'image_url': imageUrl,
      'media_urls': mediaUrls,
      'type': type.value,
      'is_multiple_choice': isMultipleChoice,
      'response_type': responseType.value,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'options': options
          .map((option) => (option as EventOptionModel).toJson())
          .toList(),
      'organizers': organizers
          .map((organizer) => (organizer as EventOrganizerModel).toJson())
          .toList(),
      'instructors': instructors
          .map((instructor) => (instructor as EventInstructorModel).toJson())
          .toList(),
      'participants': participants
          .map((participant) => (participant as EventParticipantModel).toJson())
          .toList(),
      'questions': questions
          .map((question) => (question as EventQuestionModel).toJson())
          .toList(),
      'media': media
          .map((media) => (media as EventMediaModel).toJson())
          .toList(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'rich_description': richDescription,
      'image_url': imageUrl,
      'media_urls': mediaUrls,
      'type': type.value,
      'is_multiple_choice': isMultipleChoice,
      'response_type': responseType.value,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};
    if (title.isNotEmpty) json['title'] = title;
    if (description != null) json['description'] = description;
    if (richDescription != null) json['rich_description'] = richDescription;
    if (imageUrl != null) json['image_url'] = imageUrl;
    json['media_urls'] = mediaUrls;
    json['type'] = type.value;
    json['is_multiple_choice'] = isMultipleChoice;
    json['response_type'] = responseType.value;
    if (startAt != null) json['start_at'] = startAt!.toIso8601String();
    if (endAt != null) json['end_at'] = endAt!.toIso8601String();
    if (location != null) json['location'] = location;
    if (maxParticipants != null) json['max_participants'] = maxParticipants;
    if (registrationDeadline != null) {
      json['registration_deadline'] = registrationDeadline!.toIso8601String();
    }
    json['is_active'] = isActive;
    return json;
  }
}

class EventOptionModel extends EventOption {
  EventOptionModel({
    required super.id,
    required super.eventId,
    required super.optionText,
  });

  factory EventOptionModel.fromJson(Map<String, dynamic> json) {
    return EventOptionModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      optionText: json['option_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'event_id': eventId, 'option_text': optionText};
  }

  Map<String, dynamic> toCreateJson() {
    return {'event_id': eventId, 'option_text': optionText};
  }
}

class EventResponseModel extends EventResponse {
  EventResponseModel({
    required super.id,
    required super.eventId,
    required super.memberId,
    super.optionId,
    super.responseText,
    required super.createdAt,
    super.memberName,
    super.memberSurname,
  });

  factory EventResponseModel.fromJson(Map<String, dynamic> json) {
    return EventResponseModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
      optionId: json['option_id'] as String?,
      responseText: json['response_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberName: json['member_name'] as String?,
      memberSurname: json['member_surname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'member_id': memberId,
      'option_id': optionId,
      'response_text': responseText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'event_id': eventId,
      'member_id': memberId, // Add member_id explicitly
      'option_id': optionId,
      'response_text': responseText,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {'option_id': optionId, 'response_text': responseText};
  }
}

// Yeni Model Sınıfları

class EventOrganizerModel extends EventOrganizer {
  EventOrganizerModel({
    required super.id,
    required super.eventId,
    required super.memberId,
    required super.role,
    required super.createdAt,
    super.memberName,
  });

  factory EventOrganizerModel.fromJson(Map<String, dynamic> json) {
    // Member bilgilerini çek
    final member = json['member'] as Map<String, dynamic>?;
    final memberName = member != null
        ? '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}'.trim()
        : null;

    return EventOrganizerModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberName: memberName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'member_id': memberId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'member_name': memberName,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'event_id': eventId, 'member_id': memberId, 'role': role};
  }
}

class EventInstructorModel extends EventInstructor {
  EventInstructorModel({
    required super.id,
    required super.eventId,
    required super.memberId,
    required super.role,
    required super.createdAt,
    super.memberName,
  });

  factory EventInstructorModel.fromJson(Map<String, dynamic> json) {
    // Member bilgilerini çek
    final member = json['member'] as Map<String, dynamic>?;
    final memberName = member != null
        ? '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}'.trim()
        : null;

    return EventInstructorModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberName: memberName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'member_id': memberId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'member_name': memberName,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'event_id': eventId, 'member_id': memberId, 'role': role};
  }
}

class EventParticipantModel extends EventParticipant {
  EventParticipantModel({
    required super.id,
    required super.eventId,
    required super.memberId,
    required super.registrationDate,
    required super.status,
    super.notes,
    super.memberName,
  });

  factory EventParticipantModel.fromJson(Map<String, dynamic> json) {
    return EventParticipantModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
      registrationDate: DateTime.parse(json['registration_date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      memberName: json['member_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'member_id': memberId,
      'registration_date': registrationDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'member_name': memberName,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'event_id': eventId,
      'member_id': memberId,
      'status': status,
      'notes': notes,
    };
  }
}

class EventQuestionModel extends EventQuestion {
  EventQuestionModel({
    required super.id,
    required super.eventId,
    required super.questionText,
    required super.questionType,
    required super.isRequired,
    required super.sortOrder,
    required super.createdAt,
    super.options = const [],
  });

  factory EventQuestionModel.fromJson(Map<String, dynamic> json) {
    return EventQuestionModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (option) => EventQuestionOptionModel.fromJson(
                  option as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'question_text': questionText,
      'question_type': questionType,
      'is_required': isRequired,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'options': options
          .map((option) => (option as EventQuestionOptionModel).toJson())
          .toList(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'event_id': eventId,
      'question_text': questionText,
      'question_type': questionType,
      'is_required': isRequired,
      'sort_order': sortOrder,
    };
  }
}

class EventQuestionOptionModel extends EventQuestionOption {
  EventQuestionOptionModel({
    required super.id,
    required super.questionId,
    required super.optionText,
    required super.sortOrder,
    required super.createdAt,
  });

  factory EventQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return EventQuestionOptionModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      optionText: json['option_text'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'question_id': questionId,
      'option_text': optionText,
      'sort_order': sortOrder,
    };
  }
}

class EventQuestionResponseModel extends EventQuestionResponse {
  EventQuestionResponseModel({
    required super.id,
    required super.questionId,
    required super.memberId,
    super.optionId,
    super.responseText,
    required super.createdAt,
    super.memberName,
    super.memberSurname,
  });

  factory EventQuestionResponseModel.fromJson(Map<String, dynamic> json) {
    // Member bilgilerini çek
    final member = json['member'] as Map<String, dynamic>?;
    final memberName = member != null
        ? '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}'.trim()
        : null;

    return EventQuestionResponseModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      memberId: json['member_id'] as String,
      optionId: json['option_id'] as String?,
      responseText: json['response_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberName: memberName,
      memberSurname: member?['last_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'member_id': memberId,
      'option_id': optionId,
      'response_text': responseText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'question_id': questionId,
      'option_id': optionId,
      'response_text': responseText,
    };
  }
}

class EventMediaModel extends EventMedia {
  EventMediaModel({
    required super.id,
    required super.eventId,
    required super.fileName,
    required super.fileUrl,
    required super.fileType,
    super.fileSize,
    super.uploadedBy,
    required super.createdAt,
  });

  factory EventMediaModel.fromJson(Map<String, dynamic> json) {

    return EventMediaModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int?,
      uploadedBy: json['uploaded_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'event_id': eventId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
    };
  }
}
