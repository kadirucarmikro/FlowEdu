import '../entities/lesson_schedule.dart';
import '../entities/lesson_schedule_with_package.dart';

abstract class LessonSchedulesRepository {
  Future<List<LessonSchedule>> getLessonSchedules();
  Future<List<LessonScheduleWithPackage>> getLessonSchedulesWithPackages();
  Future<List<LessonSchedule>> getLessonSchedulesByPackage(String packageId);
  Future<List<LessonScheduleWithPackage>> getMemberAssignedSchedules(
    String memberId,
  );
  Future<LessonSchedule> getLessonScheduleById(String id);
  Future<LessonSchedule> createLessonSchedule(LessonSchedule schedule);
  Future<LessonSchedule> updateLessonSchedule(LessonSchedule schedule);
  Future<void> deleteLessonSchedule(String id);

  // Status update methods
  Future<LessonSchedule> updateLessonStatus(
    String scheduleId,
    LessonStatus status, {
    DateTime? rescheduledDate,
    String? rescheduleReason,
  });
  Future<List<LessonSchedule>> updateAutoStatusForPastLessons();

  // Conflict validation methods
  Future<bool> checkLessonConflict({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    String? excludeScheduleId,
  });
  Future<List<String>> checkMemberConflicts({
    required List<String> memberIds,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeScheduleId,
  });
  Future<Map<String, dynamic>> validateLessonSchedule({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    required List<String> memberIds,
    String? excludeScheduleId,
  });
}
