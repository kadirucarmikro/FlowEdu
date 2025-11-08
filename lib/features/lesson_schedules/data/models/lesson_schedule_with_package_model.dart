import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/entities/lesson_schedule.dart';

class LessonScheduleWithPackageModel extends LessonScheduleWithPackage {
  const LessonScheduleWithPackageModel({
    required super.id,
    required super.packageId,
    required super.packageName,
    required super.packageLessonCount,
    required super.packageIsActive,
    super.instructorId,
    super.instructorName,
    super.instructorSpecialization,
    super.instructorExperience,
    super.roomId,
    super.roomName,
    super.roomCapacity,
    super.roomFeatures,
    super.attendeeIds,
    super.attendeeInstructors,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.createdAt,
    super.lessonNumber,
    super.status,
    super.actualDateDay,
    super.actualDateMonth,
    super.actualDateYear,
    super.rescheduledDate,
    super.rescheduleReason,
  });

  factory LessonScheduleWithPackageModel.fromJson(Map<String, dynamic> json) {
    // Package bilgilerini al
    final package = json['lesson_packages'] as Map<String, dynamic>?;
    final packageName = package?['name'] as String? ?? '';
    final packageLessonCount = package?['lesson_count'] as int? ?? 0;
    final packageIsActive = package?['is_active'] as bool? ?? true;

    // Instructor bilgilerini al
    final instructor = json['members'] as Map<String, dynamic>?;
    final instructorId = json['instructor_id'] as String?;
    final instructorName = instructor != null
        ? '${instructor['first_name']} ${instructor['last_name']}'
        : null;
    final instructorSpecialization = instructor?['specialization'] as String?;
    final instructorExperience =
        instructor?['instructor_experience'] as String?;

    // Room bilgilerini al
    final room = json['rooms'] as Map<String, dynamic>?;
    final roomId = json['room_id'] as String?;
    final roomName = room?['name'] as String?;
    final roomCapacity = room?['capacity'] as int?;
    final roomFeatures = room?['features'] as String?;

    // Attendee eğitmen bilgilerini al
    final attendees = json['lesson_attendees'] as List<dynamic>?;
    final attendeeInstructors = <Map<String, dynamic>>[];

    if (attendees != null) {
      for (final attendee in attendees) {
        final member = attendee['members'] as Map<String, dynamic>?;
        if (member != null) {
          attendeeInstructors.add({
            'id': member['id'],
            'first_name': member['first_name'],
            'last_name': member['last_name'],
            'specialization': member['specialization'],
            'instructor_experience': member['instructor_experience'],
          });
        }
      }
    }

    return LessonScheduleWithPackageModel(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      packageName: packageName,
      packageLessonCount: packageLessonCount,
      packageIsActive: packageIsActive,
      instructorId: instructorId,
      instructorName: instructorName,
      instructorSpecialization: instructorSpecialization,
      instructorExperience: instructorExperience,
      roomId: roomId,
      roomName: roomName,
      roomCapacity: roomCapacity,
      roomFeatures: roomFeatures,
      attendeeIds:
          (json['attendee_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      attendeeInstructors: attendeeInstructors,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lessonNumber: json['lesson_number'] as int?,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'package_name': packageName,
      'package_lesson_count': packageLessonCount,
      'package_is_active': packageIsActive,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'instructor_specialization': instructorSpecialization,
      'instructor_experience': instructorExperience,
      'room_id': roomId,
      'room_name': roomName,
      'room_capacity': roomCapacity,
      'room_features': roomFeatures,
      'attendee_ids': attendeeIds,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt.toIso8601String(),
      'lesson_number': lessonNumber,
      'status': status.name,
      'actual_date_day': actualDateDay,
      'actual_date_month': actualDateMonth,
      'actual_date_year': actualDateYear,
      'rescheduled_date': rescheduledDate?.toIso8601String(),
      'reschedule_reason': rescheduleReason,
    };
  }

  factory LessonScheduleWithPackageModel.fromEntity(
    LessonScheduleWithPackage entity,
  ) {
    return LessonScheduleWithPackageModel(
      id: entity.id,
      packageId: entity.packageId,
      packageName: entity.packageName,
      packageLessonCount: entity.packageLessonCount,
      packageIsActive: entity.packageIsActive,
      instructorId: entity.instructorId,
      instructorName: entity.instructorName,
      instructorSpecialization: entity.instructorSpecialization,
      instructorExperience: entity.instructorExperience,
      roomId: entity.roomId,
      roomName: entity.roomName,
      roomCapacity: entity.roomCapacity,
      roomFeatures: entity.roomFeatures,
      attendeeIds: entity.attendeeIds,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      createdAt: entity.createdAt,
      lessonNumber: entity.lessonNumber,
      status: entity.status,
      actualDateDay: entity.actualDateDay,
      actualDateMonth: entity.actualDateMonth,
      actualDateYear: entity.actualDateYear,
      rescheduledDate: entity.rescheduledDate,
      rescheduleReason: entity.rescheduleReason,
    );
  }

  LessonScheduleWithPackage toEntity() {
    final entity = LessonScheduleWithPackage(
      id: id,
      packageId: packageId,
      packageName: packageName,
      packageLessonCount: packageLessonCount,
      packageIsActive: packageIsActive,
      instructorId: instructorId,
      instructorName: instructorName,
      instructorSpecialization: instructorSpecialization,
      instructorExperience: instructorExperience,
      roomId: roomId,
      roomName: roomName,
      roomCapacity: roomCapacity,
      roomFeatures: roomFeatures,
      attendeeIds: attendeeIds,
      attendeeInstructors: attendeeInstructors,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      lessonNumber: lessonNumber,
      status: status,
      actualDateDay: actualDateDay,
      actualDateMonth: actualDateMonth,
      actualDateYear: actualDateYear,
      rescheduledDate: rescheduledDate,
      rescheduleReason: rescheduleReason,
    );
    return entity;
  }
}
