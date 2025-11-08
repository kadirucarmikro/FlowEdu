import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventsRemoteDataSource {
  EventsRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<EventModel>> getEvents() async {
    final response = await _client
        .from('events')
        .select('''
          id, title, description, rich_description, image_url, type, is_multiple_choice, 
          response_type, start_at, end_at, location, max_participants, registration_deadline,
          is_active, created_by, created_at,
          options:event_options(*),
          organizers:event_organizers(*, member:members(first_name, last_name)),
          instructors:event_instructors(*, member:members(first_name, last_name)),
          questions:event_questions(*),
          media:event_media(*)
        ''')
        .order('created_at', ascending: false);

    final events = (response as List<dynamic>)
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Her event için soruların seçeneklerini yükle
    for (final event in events) {
      for (final question in event.questions) {
        if (question.questionType == 'single_choice' ||
            question.questionType == 'multiple_choice') {
          try {
            final options = await getQuestionOptions(question.id);
            // Seçenekleri soruya ekle
            question.options.clear();
            question.options.addAll(options);
          } catch (e) {
            // Hata durumunda sessizce devam et
          }
        }
      }
    }

    return events;
  }

  Future<EventModel?> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select('''
          id, title, description, rich_description, image_url, type, is_multiple_choice, 
          response_type, start_at, end_at, location, max_participants, registration_deadline,
          is_active, created_by, created_at,
          options:event_options(*),
          organizers:event_organizers(*, member:members(first_name, last_name)),
          instructors:event_instructors(*, member:members(first_name, last_name)),
          questions:event_questions(*),
          media:event_media(*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final event = EventModel.fromJson(response);

    // Soruların seçeneklerini yükle
    for (final question in event.questions) {
      if (question.questionType == 'single_choice' ||
          question.questionType == 'multiple_choice') {
        try {
          final options = await getQuestionOptions(question.id);
          // Seçenekleri soruya ekle
          question.options.clear();
          question.options.addAll(options);
        } catch (e) {
          // Hata durumunda sessizce devam et
        }
      }
    }

    return event;
  }

  Future<EventModel> createEvent(EventModel event) async {
    final createJson = event.toCreateJson();

    final response = await _client.from('events').insert(createJson).select('''
          *,
          options:event_options(*),
          organizers:event_organizers(*, member:members(first_name, last_name)),
          instructors:event_instructors(*, member:members(first_name, last_name)),
          questions:event_questions(*),
          media:event_media(*)
        ''').single();

    return EventModel.fromJson(response);
  }

  Future<EventModel> updateEvent(EventModel event) async {
    final updateJson = event.toUpdateJson();

    final response = await _client
        .from('events')
        .update(updateJson)
        .eq('id', event.id)
        .select('''
          *,
          options:event_options(*),
          organizers:event_organizers(*, member:members(first_name, last_name)),
          instructors:event_instructors(*, member:members(first_name, last_name)),
          questions:event_questions(*),
          media:event_media(*)
        ''')
        .single();

    return EventModel.fromJson(response);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  // Event Options
  Future<List<EventOptionModel>> getEventOptions(String eventId) async {
    final response = await _client
        .from('event_options')
        .select('*')
        .eq('event_id', eventId);

    return (response as List<dynamic>)
        .map((json) => EventOptionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<EventOptionModel> createEventOption(EventOptionModel option) async {
    final response = await _client
        .from('event_options')
        .insert(option.toCreateJson())
        .select('*')
        .single();

    return EventOptionModel.fromJson(response);
  }

  Future<void> deleteEventOption(String optionId) async {
    await _client.from('event_options').delete().eq('id', optionId);
  }

  // Question Options
  Future<List<EventQuestionOptionModel>> getQuestionOptions(
    String questionId,
  ) async {
    final response = await _client
        .from('event_question_options')
        .select('*')
        .eq('question_id', questionId)
        .order('sort_order');

    return (response as List<dynamic>)
        .map(
          (json) =>
              EventQuestionOptionModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<EventQuestionOptionModel> createEventQuestionOption({
    required String questionId,
    required String optionText,
    required int sortOrder,
  }) async {
    final response = await _client
        .from('event_question_options')
        .insert({
          'question_id': questionId,
          'option_text': optionText,
          'sort_order': sortOrder,
        })
        .select('*')
        .single();

    return EventQuestionOptionModel.fromJson(response);
  }

  Future<void> updateQuestionResponse({
    required String questionId,
    required String memberId,
    String? optionId,
    required String responseText,
  }) async {
    await _client
        .from('event_question_responses')
        .update({'response_text': responseText, 'option_id': optionId})
        .eq('question_id', questionId)
        .eq('member_id', memberId);
  }

  // Event Responses
  Future<List<EventResponseModel>> getEventResponses(String eventId) async {
    final response = await _client
        .from('event_responses')
        .select('*')
        .eq('event_id', eventId);

    final responses = (response as List<dynamic>)
        .map((json) => EventResponseModel.fromJson(json))
        .toList();

    // Get member info for each response
    for (final response in responses) {
      try {
        final memberResponse = await _client
            .from('members')
            .select('name, surname')
            .eq('id', response.memberId)
            .maybeSingle();

        if (memberResponse != null) {
          response.memberName = memberResponse['name'] as String?;
          response.memberSurname = memberResponse['surname'] as String?;
        }
      } catch (e) {
        // Hata durumunda sessizce devam et
      }
    }

    return responses;
  }

  Future<EventResponseModel> createEventResponse(
    EventResponseModel response,
  ) async {
    final result = await _client
        .from('event_responses')
        .insert(response.toCreateJson())
        .select('*')
        .single();

    return EventResponseModel.fromJson(result);
  }

  Future<EventResponseModel?> getMemberEventResponse({
    required String eventId,
    required String memberId,
  }) async {
    final response = await _client
        .from('event_responses')
        .select('*')
        .eq('event_id', eventId)
        .eq('member_id', memberId)
        .maybeSingle();

    if (response == null) return null;
    return EventResponseModel.fromJson(response);
  }

  Future<EventResponseModel> updateEventResponse(
    EventResponseModel response,
  ) async {
    final result = await _client
        .from('event_responses')
        .update(response.toUpdateJson())
        .eq('id', response.id)
        .select('*')
        .single();

    return EventResponseModel.fromJson(result);
  }

  Future<void> deleteEventResponse(String responseId) async {
    await _client.from('event_responses').delete().eq('id', responseId);
  }

  // Get current member from auth
  Future<Map<String, dynamic>?> getCurrentMember() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await _client
        .from('members')
        .select('id, user_id, first_name, last_name')
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // Event Organizers
  Future<List<EventOrganizerModel>> getEventOrganizers(String eventId) async {
    final response = await _client
        .from('event_organizers')
        .select('''
          *,
          member:members!inner(first_name, last_name)
        ''')
        .eq('event_id', eventId);

    return (response as List<dynamic>)
        .map(
          (json) => EventOrganizerModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<EventOrganizerModel> createEventOrganizer(
    EventOrganizerModel organizer,
  ) async {
    final response = await _client
        .from('event_organizers')
        .insert(organizer.toCreateJson())
        .select('''
          *,
          member:members!inner(first_name, last_name)
        ''')
        .single();

    return EventOrganizerModel.fromJson(response);
  }

  Future<void> deleteEventOrganizer(String organizerId) async {
    await _client.from('event_organizers').delete().eq('id', organizerId);
  }

  Future<void> deleteEventOrganizersByEventId(String eventId) async {
    await _client.from('event_organizers').delete().eq('event_id', eventId);
  }

  // Event Instructors
  Future<List<EventInstructorModel>> getEventInstructors(String eventId) async {
    final response = await _client
        .from('event_instructors')
        .select('''
          *,
          member:members!inner(first_name, last_name)
        ''')
        .eq('event_id', eventId);

    return (response as List<dynamic>)
        .map(
          (json) => EventInstructorModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<EventInstructorModel> createEventInstructor(
    EventInstructorModel instructor,
  ) async {
    final response = await _client
        .from('event_instructors')
        .insert(instructor.toCreateJson())
        .select('''
          *,
          member:members!inner(first_name, last_name)
        ''')
        .single();

    return EventInstructorModel.fromJson(response);
  }

  Future<void> deleteEventInstructor(String instructorId) async {
    await _client.from('event_instructors').delete().eq('id', instructorId);
  }

  Future<void> deleteEventInstructorsByEventId(String eventId) async {
    await _client.from('event_instructors').delete().eq('event_id', eventId);
  }

  Future<EventQuestionModel> createEventQuestion({
    required String eventId,
    required String questionText,
    required String questionType,
    required bool isRequired,
    required int sortOrder,
  }) async {
    final response = await _client
        .from('event_questions')
        .insert({
          'event_id': eventId,
          'question_text': questionText,
          'question_type': questionType,
          'is_required': isRequired,
          'sort_order': sortOrder,
        })
        .select('''
          *
        ''')
        .single();

    return EventQuestionModel.fromJson(response);
  }

  Future<void> deleteEventQuestionsByEventId(String eventId) async {
    await _client.from('event_questions').delete().eq('event_id', eventId);
  }

  Future<EventMediaModel> createEventMedia({
    required String eventId,
    required String fileName,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? uploadedBy,
  }) async {
    final response = await _client
        .from('event_media')
        .insert({
          'event_id': eventId,
          'file_name': fileName,
          'file_url': fileUrl,
          'file_type': fileType,
          'file_size': fileSize,
          'uploaded_by': uploadedBy,
        })
        .select('*')
        .single();

    return EventMediaModel.fromJson(response);
  }

  Future<void> deleteEventMedia(String mediaId) async {
    await _client.from('event_media').delete().eq('id', mediaId);
  }

  Future<void> deleteEventMediaByEventId(String eventId) async {
    await _client.from('event_media').delete().eq('event_id', eventId);
  }

  // Question Responses
  Future<List<EventQuestionResponseModel>> getQuestionResponses({
    required String eventId,
    required String memberId,
  }) async {

    final questionIds = await _getQuestionIdsForEvent(eventId);

    if (questionIds.isEmpty) {
      return [];
    }

    final response = await _client
        .from('event_question_responses')
        .select('*')
        .eq('member_id', memberId)
        .inFilter('question_id', questionIds);


    final responses = (response as List<dynamic>)
        .map(
          (json) =>
              EventQuestionResponseModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();


    return responses;
  }

  Future<EventQuestionResponseModel> createQuestionResponse({
    required String questionId,
    required String memberId,
    String? optionId,
    String? responseText,
  }) async {
    final response = await _client
        .from('event_question_responses')
        .insert({
          'question_id': questionId,
          'member_id': memberId,
          'option_id': optionId,
          'response_text': responseText,
        })
        .select('*')
        .single();

    return EventQuestionResponseModel.fromJson(response);
  }

  // Admin için tüm üye yanıtlarını getir
  Future<List<EventQuestionResponseModel>> getAllQuestionResponsesForEvent(
    String eventId,
  ) async {

    // Önce etkinliğin sorularını al
    final questionIds = await _getQuestionIdsForEvent(eventId);

    if (questionIds.isEmpty) {
      return [];
    }

    // Tüm soru yanıtlarını al ve member bilgilerini join et
    final response = await _client
        .from('event_question_responses')
        .select('''
          *,
          member:members!inner(first_name, last_name)
        ''')
        .inFilter('question_id', questionIds)
        .order('created_at', ascending: false);


    final responses = (response as List<dynamic>)
        .map(
          (json) =>
              EventQuestionResponseModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return responses;
  }

  Future<List<String>> _getQuestionIdsForEvent(String eventId) async {
    final response = await _client
        .from('event_questions')
        .select('id')
        .eq('event_id', eventId);

    final questionIds = (response as List<dynamic>)
        .map((json) => json['id'] as String)
        .toList();

    return questionIds;
  }

  // Upload file to Supabase Storage
  Future<String> uploadFileToStorage({
    required String fileName,
    required Uint8List fileBytes,
    required String fileType,
  }) async {
    try {
      final base64String = base64Encode(fileBytes);
      final mimeType = _getContentType(fileType);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      rethrow;
    }
  }

  String _getContentType(String fileType) {
    switch (fileType) {
      case 'image':
        return 'image/jpeg';
      case 'video':
        return 'video/mp4';
      case 'audio':
        return 'audio/mpeg';
      case 'document':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
