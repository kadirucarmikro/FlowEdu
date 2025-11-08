import 'package:equatable/equatable.dart';
import 'lesson_schedule.dart';

class LessonScheduleWithPackage extends Equatable {
  final String id;
  final String packageId;
  final String packageName;
  final int packageLessonCount;
  final bool packageIsActive;
  final String? instructorId;
  final String? instructorName;
  final String? instructorSpecialization;
  final String? instructorExperience;
  final String? memberId;
  final String? memberName;
  final String? memberEmail;
  final String? memberPhone;
  final String? roomId;
  final String? roomName;
  final int? roomCapacity;
  final String? roomFeatures;
  final String? roomLocation;
  final List<String> attendeeIds;
  final List<Map<String, dynamic>>
  attendeeInstructors; // Katılımcı eğitmen bilgileri
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final int? lessonNumber; // Paket içindeki ders sırası (1, 2, 3...)
  final LessonStatus status; // Ders durumu
  final int? actualDateDay; // Gerçek ders günü (1-31)
  final int? actualDateMonth; // Gerçek ders ayı (1-12)
  final int? actualDateYear; // Gerçek ders yılı
  final DateTime? rescheduledDate; // Yeniden planlanan tarih
  final String? rescheduleReason; // Yeniden planlama sebebi

  const LessonScheduleWithPackage({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.packageLessonCount,
    required this.packageIsActive,
    this.instructorId,
    this.instructorName,
    this.instructorSpecialization,
    this.instructorExperience,
    this.memberId,
    this.memberName,
    this.memberEmail,
    this.memberPhone,
    this.roomId,
    this.roomName,
    this.roomCapacity,
    this.roomFeatures,
    this.roomLocation,
    this.attendeeIds = const [],
    this.attendeeInstructors = const [],
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.lessonNumber,
    this.status = LessonStatus.scheduled,
    this.actualDateDay,
    this.actualDateMonth,
    this.actualDateYear,
    this.rescheduledDate,
    this.rescheduleReason,
  });

  @override
  List<Object?> get props => [
    id,
    packageId,
    packageName,
    packageLessonCount,
    packageIsActive,
    instructorId,
    instructorName,
    instructorSpecialization,
    instructorExperience,
    memberId,
    memberName,
    memberEmail,
    memberPhone,
    roomId,
    roomName,
    roomCapacity,
    roomFeatures,
    roomLocation,
    attendeeIds,
    attendeeInstructors,
    dayOfWeek,
    startTime,
    endTime,
    createdAt,
    lessonNumber,
    status,
    actualDateDay,
    actualDateMonth,
    actualDateYear,
    rescheduledDate,
    rescheduleReason,
  ];

  LessonSchedule toLessonSchedule() {
    return LessonSchedule(
      id: id,
      packageId: packageId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      lessonNumber: lessonNumber ?? 1,
      totalLessons: packageLessonCount,
      status: status,
      actualDateDay: actualDateDay,
      actualDateMonth: actualDateMonth,
      actualDateYear: actualDateYear,
      rescheduledDate: rescheduledDate,
      rescheduleReason: rescheduleReason,
    );
  }

  LessonScheduleWithPackage copyWith({
    String? id,
    String? packageId,
    String? packageName,
    int? packageLessonCount,
    bool? packageIsActive,
    String? instructorId,
    String? instructorName,
    String? instructorSpecialization,
    String? instructorExperience,
    String? memberId,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    String? roomId,
    String? roomName,
    int? roomCapacity,
    String? roomFeatures,
    String? roomLocation,
    List<String>? attendeeIds,
    List<Map<String, dynamic>>? attendeeInstructors,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    int? lessonNumber,
    LessonStatus? status,
    int? actualDateDay,
    int? actualDateMonth,
    int? actualDateYear,
    DateTime? rescheduledDate,
    String? rescheduleReason,
  }) {
    return LessonScheduleWithPackage(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      packageLessonCount: packageLessonCount ?? this.packageLessonCount,
      packageIsActive: packageIsActive ?? this.packageIsActive,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorSpecialization:
          instructorSpecialization ?? this.instructorSpecialization,
      instructorExperience: instructorExperience ?? this.instructorExperience,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      memberEmail: memberEmail ?? this.memberEmail,
      memberPhone: memberPhone ?? this.memberPhone,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      roomCapacity: roomCapacity ?? this.roomCapacity,
      roomFeatures: roomFeatures ?? this.roomFeatures,
      roomLocation: roomLocation ?? this.roomLocation,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      attendeeInstructors: attendeeInstructors ?? this.attendeeInstructors,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      status: status ?? this.status,
      actualDateDay: actualDateDay ?? this.actualDateDay,
      actualDateMonth: actualDateMonth ?? this.actualDateMonth,
      actualDateYear: actualDateYear ?? this.actualDateYear,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
    );
  }
}
