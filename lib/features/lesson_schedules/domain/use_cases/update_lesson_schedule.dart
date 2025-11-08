import '../entities/lesson_schedule.dart';
import '../repositories/lesson_schedules_repository.dart';

class UpdateLessonSchedule {
  final LessonSchedulesRepository repository;

  UpdateLessonSchedule(this.repository);

  Future<LessonSchedule> call(LessonSchedule schedule) async {
    return await repository.updateLessonSchedule(schedule);
  }
}
