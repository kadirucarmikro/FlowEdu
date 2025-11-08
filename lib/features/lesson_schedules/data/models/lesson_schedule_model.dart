import '../../domain/entities/lesson_schedule.dart';

class LessonScheduleModel extends LessonSchedule {
  const LessonScheduleModel({
    required super.id,
    required super.packageId,
    super.instructorId,
    super.roomId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    super.attendeeIds = const [],
    required super.createdAt,
    required super.lessonNumber,
    required super.totalLessons,
    super.status,
    super.actualDateDay,
    super.actualDateMonth,
    super.actualDateYear,
    super.rescheduledDate,
    super.rescheduleReason,
    super.updatedBy,
    super.updatedAt,
    super.statusChangedBy,
  });

  factory LessonScheduleModel.fromJson(Map<String, dynamic> json) {
    return LessonScheduleModel(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      instructorId: json['instructor_id'] as String?,
      roomId: json['room_id'] as String?,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      attendeeIds:
          (json['attendee_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      lessonNumber: json['lesson_number'] as int? ?? 1,
      totalLessons: json['total_lessons'] as int? ?? 1,
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.scheduled,
      ),
      actualDateDay: json['actual_date_day'] as int?,
      actualDateMonth: json['actual_date_month'] as int?,
      actualDateYear: json['actual_date_year'] as int?,
      rescheduledDate: json['rescheduled_date'] != null
          ? DateTime.parse(json['rescheduled_date'] as String)
          : null,
      rescheduleReason: json['reschedule_reason'] as String?,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      statusChangedBy: json['status_changed_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'instructor_id': instructorId,
      'room_id': roomId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'attendee_ids': attendeeIds,
      'created_at': createdAt.toIso8601String(),
      'lesson_number': lessonNumber,
      'total_lessons': totalLessons,
      'status': status.name,
      'actual_date_day': actualDateDay,
      'actual_date_month': actualDateMonth,
      'actual_date_year': actualDateYear,
      'rescheduled_date': rescheduledDate?.toIso8601String(),
      'reschedule_reason': rescheduleReason,
      'updated_by': updatedBy,
      'updated_at': updatedAt?.toIso8601String(),
      'status_changed_by': statusChangedBy,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = {
      'package_id': packageId,
      'instructor_id': instructorId,
      'room_id': roomId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'attendee_ids': attendeeIds,
      'lesson_number': lessonNumber,
      'total_lessons': totalLessons,
      'status': status.name,
      'actual_date_day': actualDateDay,
      'actual_date_month': actualDateMonth,
      'actual_date_year': actualDateYear,
      'rescheduled_date': rescheduledDate?.toIso8601String(),
      'reschedule_reason': rescheduleReason,
      'updated_by': updatedBy,
      'updated_at': updatedAt?.toIso8601String(),
      'status_changed_by': statusChangedBy,
    };

    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'package_id': packageId,
      'instructor_id': instructorId,
      'room_id': roomId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'attendee_ids': attendeeIds,
      'lesson_number': lessonNumber,
      'total_lessons': totalLessons,
      'status': status.name,
      'actual_date_day': actualDateDay,
      'actual_date_month': actualDateMonth,
      'actual_date_year': actualDateYear,
      'rescheduled_date': rescheduledDate?.toIso8601String(),
      'reschedule_reason': rescheduleReason,
      'updated_by': updatedBy,
      'updated_at': updatedAt?.toIso8601String(),
      'status_changed_by': statusChangedBy,
    };
  }

  factory LessonScheduleModel.fromEntity(LessonSchedule entity) {
    return LessonScheduleModel(
      id: entity.id,
      packageId: entity.packageId,
      instructorId: entity.instructorId,
      roomId: entity.roomId,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      attendeeIds: entity.attendeeIds,
      createdAt: entity.createdAt,
      lessonNumber: entity.lessonNumber,
      totalLessons: entity.totalLessons,
      status: entity.status,
      actualDateDay: entity.actualDateDay,
      actualDateMonth: entity.actualDateMonth,
      actualDateYear: entity.actualDateYear,
      rescheduledDate: entity.rescheduledDate,
      rescheduleReason: entity.rescheduleReason,
      updatedBy: entity.updatedBy,
      updatedAt: entity.updatedAt,
      statusChangedBy: entity.statusChangedBy,
    );
  }

  LessonSchedule toEntity() {
    return LessonSchedule(
      id: id,
      packageId: packageId,
      instructorId: instructorId,
      roomId: roomId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      attendeeIds: attendeeIds,
      createdAt: createdAt,
      lessonNumber: lessonNumber,
      totalLessons: totalLessons,
      status: status,
      actualDateDay: actualDateDay,
      actualDateMonth: actualDateMonth,
      actualDateYear: actualDateYear,
      rescheduledDate: rescheduledDate,
      rescheduleReason: rescheduleReason,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      statusChangedBy: statusChangedBy,
    );
  }
}
