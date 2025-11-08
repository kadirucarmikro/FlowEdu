import '../entities/lesson_schedule_with_package.dart';
import '../repositories/lesson_schedules_repository.dart';

class GetMemberAssignedSchedules {
  final LessonSchedulesRepository _repository;

  GetMemberAssignedSchedules(this._repository);

  Future<List<LessonScheduleWithPackage>> call(String memberId) async {
    return await _repository.getMemberAssignedSchedules(memberId);
  }
}
