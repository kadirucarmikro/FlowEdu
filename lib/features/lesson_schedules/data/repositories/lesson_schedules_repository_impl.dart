import '../../domain/entities/lesson_schedule.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/repositories/lesson_schedules_repository.dart';
import '../data_sources/lesson_schedules_remote_data_source.dart';
import '../models/lesson_schedule_model.dart';

class LessonSchedulesRepositoryImpl implements LessonSchedulesRepository {
  final LessonSchedulesRemoteDataSource _remoteDataSource;

  LessonSchedulesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LessonSchedule>> getLessonSchedules() async {
    final models = await _remoteDataSource.getLessonSchedules();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<LessonScheduleWithPackage>>
  getLessonSchedulesWithPackages() async {
    final models = await _remoteDataSource.getLessonSchedulesWithPackages();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<LessonSchedule>> getLessonSchedulesByPackage(
    String packageId,
  ) async {
    final models = await _remoteDataSource.getLessonSchedulesByPackage(
      packageId,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<LessonSchedule> getLessonScheduleById(String id) async {
    final model = await _remoteDataSource.getLessonScheduleById(id);
    return model.toEntity();
  }

  // Tek ders detayı için (paket bilgisi ile)
  Future<LessonScheduleWithPackage> getLessonScheduleWithPackageById(
    String id,
  ) async {
    final models = await _remoteDataSource.getLessonSchedulesWithPackages();
    final matchingModels = models.where((m) => m.id == id).toList();
    if (matchingModels.isEmpty) {
      throw Exception('Ders programı bulunamadı: $id');
    }
    return matchingModels.first.toEntity();
  }

  @override
  Future<LessonSchedule> createLessonSchedule(LessonSchedule schedule) async {
    final model = LessonScheduleModel.fromEntity(schedule);
    final createdModel = await _remoteDataSource.createLessonSchedule(model);
    return createdModel.toEntity();
  }

  @override
  Future<LessonSchedule> updateLessonSchedule(LessonSchedule schedule) async {
    final model = LessonScheduleModel.fromEntity(schedule);
    final updatedModel = await _remoteDataSource.updateLessonSchedule(model);
    return updatedModel.toEntity();
  }

  @override
  Future<List<LessonScheduleWithPackage>> getMemberAssignedSchedules(
    String memberId,
  ) async {
    // Bu metod sadece LessonSchedule döndürüyor, LessonScheduleWithPackage değil
    // Geçici olarak boş liste döndürüyoruz
    return [];
  }

  @override
  Future<void> deleteLessonSchedule(String id) async {
    await _remoteDataSource.deleteLessonSchedule(id);
  }

  // Yeni metodlar: Üye atama ve çakışma kontrolü
  Future<void> assignMembersToSchedule(
    String scheduleId,
    List<String> memberIds, {
    Map<String, double>? memberPrices,
  }) async {
    await _remoteDataSource.assignMembersToSchedule(
      scheduleId,
      memberIds,
      memberPrices: memberPrices,
    );
  }

  Future<List<String>> getScheduleAttendees(String scheduleId) async {
    return await _remoteDataSource.getScheduleAttendees(scheduleId);
  }

  Future<bool> checkMemberConflict(
    String memberId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    return await _remoteDataSource.checkMemberConflict(
      memberId,
      date,
      startTime,
      endTime,
    );
  }

  Future<bool> checkRoomCapacity(String roomId, int attendeeCount) async {
    return await _remoteDataSource.checkRoomCapacity(roomId, attendeeCount);
  }

  Future<List<int>> getUniqueLessonDurations() async {
    return await _remoteDataSource.getUniqueLessonDurations();
  }

  @override
  Future<LessonSchedule> updateLessonStatus(
    String scheduleId,
    LessonStatus status, {
    DateTime? rescheduledDate,
    String? rescheduleReason,
  }) async {
    final updatedModel = await _remoteDataSource.updateLessonStatus(
      scheduleId,
      status,
      rescheduledDate: rescheduledDate,
      rescheduleReason: rescheduleReason,
    );
    return updatedModel.toEntity();
  }

  @override
  Future<List<LessonSchedule>> updateAutoStatusForPastLessons() async {
    final updatedModels = await _remoteDataSource
        .updateAutoStatusForPastLessons();
    return updatedModels.map((model) => model.toEntity()).toList();
  }

  // Conflict validation methods
  @override
  Future<bool> checkLessonConflict({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    String? excludeScheduleId,
  }) async {
    return await _remoteDataSource.checkLessonConflict(
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      instructorIds: instructorIds,
      excludeScheduleId: excludeScheduleId,
    );
  }

  @override
  Future<List<String>> checkMemberConflicts({
    required List<String> memberIds,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeScheduleId,
  }) async {
    return await _remoteDataSource.checkMemberConflicts(
      memberIds: memberIds,
      startTime: startTime,
      endTime: endTime,
      excludeScheduleId: excludeScheduleId,
    );
  }

  @override
  Future<Map<String, dynamic>> validateLessonSchedule({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> instructorIds,
    required List<String> memberIds,
    String? excludeScheduleId,
  }) async {
    return await _remoteDataSource.validateLessonSchedule(
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      instructorIds: instructorIds,
      memberIds: memberIds,
      excludeScheduleId: excludeScheduleId,
    );
  }
}
