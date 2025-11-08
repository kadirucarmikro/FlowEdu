import '../entities/lesson_schedule_with_package.dart';
import '../entities/lesson_schedule.dart';

class LessonStatusService {
  /// Ders tarihi geçmişse otomatik olarak "İşlendi" olarak işaretle
  static LessonScheduleWithPackage updateAutoStatus(
    LessonScheduleWithPackage schedule,
  ) {
    // Eğer ders zaten işlenmiş veya işlenmemiş olarak işaretlenmişse, değiştirme
    if (schedule.status == LessonStatus.completed ||
        schedule.status == LessonStatus.missed) {
      return schedule;
    }

    // Ders tarihi kontrolü
    if (schedule.actualDateDay != null &&
        schedule.actualDateMonth != null &&
        schedule.actualDateYear != null) {
      final lessonDate = DateTime(
        schedule.actualDateYear!,
        schedule.actualDateMonth!,
        schedule.actualDateDay!,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Eğer ders tarihi bugünden önceyse, otomatik olarak "İşlendi" yap
      if (lessonDate.isBefore(today)) {
        return schedule.copyWith(status: LessonStatus.completed);
      }
    }

    return schedule;
  }

  /// Ders durumunu manuel olarak güncelle
  static LessonScheduleWithPackage updateManualStatus(
    LessonScheduleWithPackage schedule,
    LessonStatus newStatus, {
    DateTime? rescheduledDate,
    String? rescheduleReason,
  }) {
    return schedule.copyWith(
      status: newStatus,
      rescheduledDate: rescheduledDate,
      rescheduleReason: rescheduleReason,
    );
  }

  /// Ders işlenmedi olarak işaretlendiğinde yeniden planlama tarihi oluştur
  static LessonScheduleWithPackage markAsMissed(
    LessonScheduleWithPackage schedule,
    DateTime rescheduledDate,
    String reason,
  ) {
    return schedule.copyWith(
      status: LessonStatus.missed,
      rescheduledDate: rescheduledDate,
      rescheduleReason: reason,
    );
  }
}
