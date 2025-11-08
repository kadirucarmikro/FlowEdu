import '../entities/lesson_schedule.dart';
import '../repositories/lesson_schedules_repository.dart';

class GetLessonSchedulesByPackage {
  final LessonSchedulesRepository repository;

  GetLessonSchedulesByPackage(this.repository);

  Future<List<LessonSchedule>> call(String packageId) async {
    return await repository.getLessonSchedulesByPackage(packageId);
  }
}
