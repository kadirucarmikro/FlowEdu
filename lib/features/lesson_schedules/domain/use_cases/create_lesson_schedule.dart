import '../entities/lesson_schedule.dart';
import '../repositories/lesson_schedules_repository.dart';

class CreateLessonSchedule {
  final LessonSchedulesRepository repository;

  CreateLessonSchedule(this.repository);

  Future<LessonSchedule> call(LessonSchedule schedule) async {
    return await repository.createLessonSchedule(schedule);
  }
}
