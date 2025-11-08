import '../entities/lesson_schedule.dart';
import '../repositories/lesson_schedules_repository.dart';

class GetLessonSchedules {
  final LessonSchedulesRepository repository;

  GetLessonSchedules(this.repository);

  Future<List<LessonSchedule>> call() async {
    return await repository.getLessonSchedules();
  }
}
