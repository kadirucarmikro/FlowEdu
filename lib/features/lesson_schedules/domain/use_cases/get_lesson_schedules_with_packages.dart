import '../entities/lesson_schedule_with_package.dart';
import '../repositories/lesson_schedules_repository.dart';

class GetLessonSchedulesWithPackages {
  final LessonSchedulesRepository repository;

  GetLessonSchedulesWithPackages(this.repository);

  Future<List<LessonScheduleWithPackage>> call() async {
    return await repository.getLessonSchedulesWithPackages();
  }
}
