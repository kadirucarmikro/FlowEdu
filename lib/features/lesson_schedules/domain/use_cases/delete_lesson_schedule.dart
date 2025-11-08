import '../repositories/lesson_schedules_repository.dart';

class DeleteLessonSchedule {
  final LessonSchedulesRepository repository;

  DeleteLessonSchedule(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteLessonSchedule(id);
  }
}
