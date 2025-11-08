import 'package:equatable/equatable.dart';

enum LessonStatus { scheduled, completed, missed, rescheduled }

class LessonSchedule extends Equatable {
  final String id;
  final String packageId;
  final String? instructorId;
  final String? roomId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final List<String> attendeeIds;
  final DateTime createdAt;
  final int lessonNumber; // 1/8, 2/8 gibi
  final int totalLessons; // 8 gibi
  final LessonStatus status;
  final int? actualDateDay; // Gerçek ders günü (1-31)
  final int? actualDateMonth; // Gerçek ders ayı (1-12)
  final int? actualDateYear; // Gerçek ders yılı
  final DateTime? rescheduledDate; // Yeniden planlanan tarih
  final String? rescheduleReason; // Yeniden planlama sebebi
  final String? updatedBy; // Güncellemeyi yapan kullanıcı
  final DateTime? updatedAt; // Güncelleme tarihi
  final String? statusChangedBy; // Durum değişikliğini yapan kullanıcı

  const LessonSchedule({
    required this.id,
    required this.packageId,
    this.instructorId,
    this.roomId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.attendeeIds = const [],
    required this.createdAt,
    required this.lessonNumber,
    required this.totalLessons,
    this.status = LessonStatus.scheduled,
    this.actualDateDay,
    this.actualDateMonth,
    this.actualDateYear,
    this.rescheduledDate,
    this.rescheduleReason,
    this.updatedBy,
    this.updatedAt,
    this.statusChangedBy,
  });

  @override
  List<Object?> get props => [
    id,
    packageId,
    instructorId,
    roomId,
    dayOfWeek,
    startTime,
    endTime,
    attendeeIds,
    createdAt,
    lessonNumber,
    totalLessons,
    status,
    actualDateDay,
    actualDateMonth,
    actualDateYear,
    rescheduledDate,
    rescheduleReason,
    updatedBy,
    updatedAt,
    statusChangedBy,
  ];

  LessonSchedule copyWith({
    String? id,
    String? packageId,
    String? instructorId,
    String? roomId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    List<String>? attendeeIds,
    DateTime? createdAt,
    int? lessonNumber,
    int? totalLessons,
    LessonStatus? status,
    int? actualDateDay,
    int? actualDateMonth,
    int? actualDateYear,
    DateTime? rescheduledDate,
    String? rescheduleReason,
    String? updatedBy,
    DateTime? updatedAt,
    String? statusChangedBy,
  }) {
    return LessonSchedule(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      instructorId: instructorId ?? this.instructorId,
      roomId: roomId ?? this.roomId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      createdAt: createdAt ?? this.createdAt,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      totalLessons: totalLessons ?? this.totalLessons,
      status: status ?? this.status,
      actualDateDay: actualDateDay ?? this.actualDateDay,
      actualDateMonth: actualDateMonth ?? this.actualDateMonth,
      actualDateYear: actualDateYear ?? this.actualDateYear,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      statusChangedBy: statusChangedBy ?? this.statusChangedBy,
    );
  }
}
