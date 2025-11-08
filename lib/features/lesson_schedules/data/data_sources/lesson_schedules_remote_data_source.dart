import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson_schedule_model.dart';
import '../models/lesson_schedule_with_package_model.dart';
import '../../domain/entities/lesson_schedule.dart';

class LessonSchedulesRemoteDataSource {
  final SupabaseClient _supabase;

  LessonSchedulesRemoteDataSource({required SupabaseClient supabase})
    : _supabase = supabase;

  Future<List<LessonScheduleModel>> getLessonSchedules() async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
          .order('created_at', ascending: false);

      final schedules = response
          .map<LessonScheduleModel>(
            (json) => LessonScheduleModel.fromJson(json),
          )
          .toList();

      return schedules;
    } catch (e) {
      throw Exception('Failed to fetch lesson schedules: $e');
    }
  }

  Future<List<LessonScheduleWithPackageModel>>
  getLessonSchedulesWithPackages() async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            lesson_packages!left(
              id,
              name,
              lesson_count,
              is_active,
              created_at
            ),
            members!instructor_id(
              id,
              first_name,
              last_name,
              specialization,
              instructor_experience
            ),
            rooms!left(
              id,
              name,
              capacity,
              features
            ),
            lesson_attendees!left(
              member_id,
              members!member_id(
                id,
                first_name,
                last_name,
                specialization,
                instructor_experience
              )
            )
          ''')
          .order('created_at', ascending: false);

      final schedules = response
          .map<LessonScheduleWithPackageModel>(
            (json) => LessonScheduleWithPackageModel.fromJson(json),
          )
          .toList();

      return schedules;
    } catch (e) {
      throw Exception('Failed to fetch lesson schedules with packages: $e');
    }
  }

  Future<List<LessonScheduleModel>> getLessonSchedulesByPackage(
    String packageId,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
          .eq('package_id', packageId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      final schedules = response
          .map<LessonScheduleModel>(
            (json) => LessonScheduleModel.fromJson(json),
          )
          .toList();

      return schedules;
    } catch (e) {
      throw Exception('Failed to fetch lesson schedules by package: $e');
    }
  }

  /// Veritabanından unique ders sürelerini getir
  Future<List<int>> getUniqueLessonDurations() async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('start_time, end_time');

      final Set<int> durations = {};

      for (final row in response) {
        final startTime = row['start_time'] as String;
        final endTime = row['end_time'] as String;

        // Time formatı: "HH:MM:SS" veya "HH:MM"
        final startParts = startTime.split(':');
        final endParts = endTime.split(':');

        if (startParts.length >= 2 && endParts.length >= 2) {
          final startMinutes =
              int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMinutes =
              int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
          final duration = endMinutes - startMinutes;

          if (duration > 0) {
            durations.add(duration);
          }
        }
      }

      return durations.toList()..sort();
    } catch (e) {
      throw Exception('Failed to fetch unique lesson durations: $e');
    }
  }

  Future<LessonScheduleModel> getLessonScheduleById(String id) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
          .eq('id', id)
          .single();

      return LessonScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch lesson schedule: $e');
    }
  }

  Future<LessonScheduleModel> createLessonSchedule(
    LessonScheduleModel schedule,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .insert(schedule.toCreateJson())
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
          .single();

      return LessonScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lesson schedule: $e');
    }
  }

  Future<LessonScheduleModel> updateLessonSchedule(
    LessonScheduleModel schedule,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .update(schedule.toUpdateJson())
          .eq('id', schedule.id)
          .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
          .single();

      return LessonScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lesson schedule: $e');
    }
  }

  Future<List<LessonScheduleModel>> getMemberAssignedSchedules(
    String memberId,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_attendees')
          .select('''
            lesson_schedules!inner(
              id,
              package_id,
              instructor_id,
              room_id,
              day_of_week,
              start_time,
              end_time,
              created_at
            )
          ''')
          .eq('member_id', memberId);

      return response
          .map<LessonScheduleModel>(
            (json) => LessonScheduleModel.fromJson(json['lesson_schedules']),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch member assigned schedules: $e');
    }
  }

  Future<void> deleteLessonSchedule(String id) async {
    try {
      await _supabase.from('lesson_schedules').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete lesson schedule: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Yeni metodlar: Üye atama ve çakışma kontrolü
  Future<void> assignMembersToSchedule(
    String scheduleId,
    List<String> memberIds, {
    Map<String, double>? memberPrices, // memberId -> lesson_price
  }) async {
    try {
      // Önce mevcut katılımcıları sil
      await _supabase
          .from('lesson_attendees')
          .delete()
          .eq('schedule_id', scheduleId);

      // Yeni katılımcıları ekle
      if (memberIds.isNotEmpty) {
        final attendees = memberIds
            .map(
              (memberId) => {
                'schedule_id': scheduleId,
                'member_id': memberId,
                'lesson_price': memberPrices?[memberId] ?? 0.0,
              },
            )
            .toList();

        await _supabase.from('lesson_attendees').insert(attendees);
      }
    } catch (e) {
      throw Exception('Üye atama hatası: $e');
    }
  }

  Future<List<String>> getScheduleAttendees(String scheduleId) async {
    try {
      final response = await _supabase
          .from('lesson_attendees')
          .select('member_id')
          .eq('schedule_id', scheduleId);

      return response.map<String>((row) => row['member_id'] as String).toList();
    } catch (e) {
      throw Exception('Katılımcılar getirilemedi: $e');
    }
  }

  Future<bool> checkMemberConflict(
    String memberId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_attendees')
          .select('''
            schedule_id,
            lesson_schedules!inner(
              day_of_week,
              start_time,
              end_time
            )
          ''')
          .eq('member_id', memberId)
          .eq('lesson_schedules.day_of_week', _getDayOfWeek(date.weekday))
          .gte('lesson_schedules.start_time', startTime)
          .lte('lesson_schedules.end_time', endTime);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkRoomCapacity(String roomId, int attendeeCount) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('capacity')
          .eq('id', roomId)
          .single();

      final capacity = response['capacity'] as int;
      return attendeeCount <= capacity;
    } catch (e) {
      return false;
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  // Status update methods
  Future<LessonScheduleModel> updateLessonStatus(
    String scheduleId,
    LessonStatus status, {
    DateTime? rescheduledDate,
    String? rescheduleReason,
  }) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Supabase connection kontrolü
        if (_supabase.auth.currentUser == null) {
          throw Exception(
            'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
          );
        }

        // Mevcut kullanıcının member ID'sini al
        final currentUserId = _supabase.auth.currentUser?.id;
        String? currentMemberId;

        if (currentUserId != null) {
          final memberResponse = await _supabase
              .from('members')
              .select('id')
              .eq('user_id', currentUserId)
              .maybeSingle();
          currentMemberId = memberResponse?['id'] as String?;
        }

        final updateData = <String, dynamic>{
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': currentMemberId,
          'status_changed_by': currentMemberId,
        };

        if (rescheduledDate != null) {
          updateData['rescheduled_date'] = rescheduledDate.toIso8601String();
        }

        if (rescheduleReason != null) {
          updateData['reschedule_reason'] = rescheduleReason;
        }

        // Timeout ile Supabase isteği
        final response = await _supabase
            .from('lesson_schedules')
            .update(updateData)
            .eq('id', scheduleId)
            .select('''
            id,
            package_id,
            instructor_id,
            room_id,
            day_of_week,
            start_time,
            end_time,
            attendee_ids,
            created_at,
            lesson_number,
            total_lessons,
            status,
            actual_date_day,
            actual_date_month,
            actual_date_year,
            rescheduled_date,
            reschedule_reason,
            updated_by,
            updated_at,
            status_changed_by
          ''')
            .single()
            .timeout(const Duration(seconds: 30));

        return LessonScheduleModel.fromJson(response);
      } catch (e) {
        retryCount++;

        if (retryCount >= maxRetries) {
          throw Exception(
            'Failed to update lesson status after $maxRetries attempts: $e',
          );
        }

        // Exponential backoff
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    throw Exception('Unexpected error in updateLessonStatus');
  }

  Future<List<LessonScheduleModel>> updateAutoStatusForPastLessons() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Geçmiş dersleri bul (scheduled status'ta olan ve tarihi geçmiş olanlar)
      final pastLessons = await _supabase
          .from('lesson_schedules')
          .select('id, actual_date_day, actual_date_month, actual_date_year')
          .eq('status', 'scheduled')
          .not('actual_date_day', 'is', null)
          .not('actual_date_month', 'is', null)
          .not('actual_date_year', 'is', null);

      final updatedLessons = <LessonScheduleModel>[];

      for (final lesson in pastLessons) {
        final lessonDate = DateTime(
          lesson['actual_date_year'] as int,
          lesson['actual_date_month'] as int,
          lesson['actual_date_day'] as int,
        );

        // Eğer ders tarihi bugünden önceyse, otomatik olarak "completed" yap
        if (lessonDate.isBefore(today)) {
          final response = await _supabase
              .from('lesson_schedules')
              .update({'status': 'completed'})
              .eq('id', lesson['id'])
              .select('''
                id,
                package_id,
                instructor_id,
                room_id,
                day_of_week,
                start_time,
                end_time,
                attendee_ids,
                created_at,
                lesson_number,
                total_lessons,
                status,
                actual_date_day,
                actual_date_month,
                actual_date_year,
                rescheduled_date,
                reschedule_reason
              ''')
              .single();

          updatedLessons.add(LessonScheduleModel.fromJson(response));
        }
      }

      return updatedLessons;
    } catch (e) {
      throw Exception('Failed to update auto status for past lessons: $e');
    }
  }

  // Çakışma kontrolü metodları
  Future<bool> checkLessonConflict({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    String? excludeScheduleId, // Güncelleme sırasında mevcut kaydı hariç tut
  }) async {
    try {
      final startTimeStr = startTime.toIso8601String();
      final endTimeStr = endTime.toIso8601String();

      final response = await _supabase
          .from('lesson_schedules')
          .select(
            'id, actual_date_day, actual_date_month, actual_date_year, start_time, end_time',
          )
          .eq('room_id', roomId);

      for (final schedule in response) {
        if (excludeScheduleId != null && schedule['id'] == excludeScheduleId) {
          continue;
        }

        if (schedule['actual_date_day'] != null &&
            schedule['actual_date_month'] != null &&
            schedule['actual_date_year'] != null) {
          if (schedule['actual_date_day'] == startTime.day &&
              schedule['actual_date_month'] == startTime.month &&
              schedule['actual_date_year'] == startTime.year) {
            return true;
          }
        } else if (schedule['start_time'] ==
                startTimeStr.split('T')[1].substring(0, 8) &&
            schedule['end_time'] == endTimeStr.split('T')[1].substring(0, 8)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> checkMemberConflicts({
    required List<String> memberIds,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeScheduleId, // Güncelleme sırasında mevcut kaydı hariç tut
  }) async {
    try {
      final startTimeStr = startTime.toIso8601String();
      final endTimeStr = endTime.toIso8601String();
      final conflictingMembers = <String>[];

      // Her üye için çakışma kontrolü
      for (final memberId in memberIds) {
        final response = await _supabase
            .from('lesson_attendees')
            .select('''
              lesson_schedules!inner(
                id,
                actual_date_day,
                actual_date_month,
                actual_date_year,
                start_time,
                end_time
              )
            ''')
            .eq('member_id', memberId)
            .eq('lesson_schedules.actual_date_day', startTime.day)
            .eq('lesson_schedules.actual_date_month', startTime.month)
            .eq('lesson_schedules.actual_date_year', startTime.year)
            .gte(
              'lesson_schedules.start_time',
              startTimeStr.split('T')[1].substring(0, 8),
            )
            .lte(
              'lesson_schedules.end_time',
              endTimeStr.split('T')[1].substring(0, 8),
            );

        // Eğer bu üye için çakışma varsa
        if (response.isNotEmpty) {
          for (final attendee in response) {
            final schedule = attendee['lesson_schedules'];
            if (excludeScheduleId != null &&
                schedule['id'] == excludeScheduleId) {
              continue;
            }
            conflictingMembers.add(memberId);
            break; // Bu üye için çakışma bulundu, diğerlerini kontrol etme
          }
        }
      }

      return conflictingMembers;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> validateLessonSchedule({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    required List<String> memberIds,
    String? excludeScheduleId,
  }) async {
    try {

      // 1. Ders çakışma kontrolü - Detaylı kontrol
      final conflictDetails = await _checkDetailedLessonConflict(
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
        excludeScheduleId: excludeScheduleId,
      );

      if (conflictDetails['hasConflict']) {
        final dateStr =
            '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';
        final timeStr =
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

        return {
          'isValid': false,
          'errorType': 'lesson_conflict',
          'message':
              '$dateStr $timeStr saatleri arasında ${conflictDetails['roomName']} odasında tanımlı bir ders programı bulunmaktadır. Aynı tanım yeniden yapılamaz.',
          'conflictDetails': conflictDetails,
        };
      }

      // 2. Üye çakışma kontrolü
      final conflictingMembers = await checkMemberConflicts(
        memberIds: memberIds,
        startTime: startTime,
        endTime: endTime,
        excludeScheduleId: excludeScheduleId,
      );

      if (conflictingMembers.isNotEmpty) {
        return {
          'isValid': false,
          'errorType': 'member_conflict',
          'message':
              'Bazı üyeler bu tarih ve saatte başka bir derse atanmıştır.',
          'conflictingMembers': conflictingMembers,
        };
      }

      return {'isValid': true, 'message': 'Ders kaydı oluşturulabilir.'};
    } catch (e) {
      return {
        'isValid': false,
        'errorType': 'validation_error',
        'message': 'Çakışma kontrolü sırasında hata oluştu: $e',
      };
    }
  }

  // Detaylı ders çakışma kontrolü
  Future<Map<String, dynamic>> _checkDetailedLessonConflict({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeScheduleId,
  }) async {
    try {
      final startTimeStr = startTime.toIso8601String();
      final endTimeStr = endTime.toIso8601String();

      final roomResponse = await _supabase
          .from('rooms')
          .select('name')
          .eq('id', roomId)
          .maybeSingle();

      final roomName = roomResponse?['name'] ?? 'Bilinmeyen Oda';

      final response = await _supabase
          .from('lesson_schedules')
          .select(
            'id, actual_date_day, actual_date_month, actual_date_year, start_time, end_time',
          )
          .eq('room_id', roomId);

      for (final schedule in response) {
        if (excludeScheduleId != null && schedule['id'] == excludeScheduleId) {
          continue;
        }

        bool hasConflict = false;
        String conflictType = '';

        if (schedule['actual_date_day'] != null &&
            schedule['actual_date_month'] != null &&
            schedule['actual_date_year'] != null) {
          if (schedule['actual_date_day'] == startTime.day &&
              schedule['actual_date_month'] == startTime.month &&
              schedule['actual_date_year'] == startTime.year) {
            hasConflict = true;
            conflictType = 'actual_date';
          }
        }

        if (!hasConflict) {
          if (schedule['start_time'] ==
                  startTimeStr.split('T')[1].substring(0, 8) &&
              schedule['end_time'] ==
                  endTimeStr.split('T')[1].substring(0, 8)) {
            hasConflict = true;
            conflictType = 'start_end_time';
          }
        }

        if (hasConflict) {
          return {
            'hasConflict': true,
            'roomName': roomName,
            'conflictId': schedule['id'],
            'conflictType': conflictType,
          };
        }
      }

      return {'hasConflict': false};
    } catch (e) {
      return {'hasConflict': false};
    }
  }
}
