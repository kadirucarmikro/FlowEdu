import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/lesson_schedules_providers.dart' as data;
import '../../domain/use_cases/get_lesson_schedules.dart';
import '../../domain/use_cases/get_lesson_schedules_with_packages.dart';
import '../../domain/use_cases/get_lesson_schedules_by_package.dart';
import '../../domain/use_cases/get_member_assigned_schedules.dart';
import '../../domain/use_cases/create_lesson_schedule.dart';
import '../../domain/use_cases/update_lesson_schedule.dart';
import '../../domain/use_cases/delete_lesson_schedule.dart';
import '../../domain/entities/lesson_schedule.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/services/auto_status_update_service.dart';
import '../../../../core/services/role_service.dart';

// Use Cases
final getLessonSchedulesProvider = Provider<GetLessonSchedules>((ref) {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return GetLessonSchedules(repository);
});

final getLessonSchedulesWithPackagesProvider =
    Provider<GetLessonSchedulesWithPackages>((ref) {
      final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
      return GetLessonSchedulesWithPackages(repository);
    });

final getLessonSchedulesByPackageProvider =
    Provider<GetLessonSchedulesByPackage>((ref) {
      final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
      return GetLessonSchedulesByPackage(repository);
    });

final createLessonScheduleProvider = Provider<CreateLessonSchedule>((ref) {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return CreateLessonSchedule(repository);
});

final updateLessonScheduleProvider = Provider<UpdateLessonSchedule>((ref) {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return UpdateLessonSchedule(repository);
});

final deleteLessonScheduleProvider = Provider<DeleteLessonSchedule>((ref) {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return DeleteLessonSchedule(repository);
});

// Assign members to schedule provider
final assignMembersToScheduleProvider =
    Provider<void Function(String, List<String>)>((ref) {
      final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
      return (String scheduleId, List<String> memberIds) async {
        await repository.assignMembersToSchedule(scheduleId, memberIds);
      };
    });

final getMemberAssignedSchedulesProvider = Provider<GetMemberAssignedSchedules>(
  (ref) {
    final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
    return GetMemberAssignedSchedules(repository);
  },
);

// Data Providers
final lessonSchedulesProvider = FutureProvider<List<LessonSchedule>>((
  ref,
) async {
  final getLessonSchedules = ref.watch(getLessonSchedulesProvider);
  return await getLessonSchedules();
});

final lessonSchedulesWithPackagesProvider =
    FutureProvider<List<LessonScheduleWithPackage>>((ref) async {
      final getLessonSchedulesWithPackages = ref.watch(
        getLessonSchedulesWithPackagesProvider,
      );
      return await getLessonSchedulesWithPackages();
    });

final lessonSchedulesByPackageProvider =
    FutureProvider.family<List<LessonSchedule>, String>((ref, packageId) async {
      final getLessonSchedulesByPackage = ref.watch(
        getLessonSchedulesByPackageProvider,
      );
      return await getLessonSchedulesByPackage(packageId);
    });

// Member'a atanan programları getir
final memberAssignedSchedulesProvider =
    FutureProvider.family<List<LessonScheduleWithPackage>, String>((
      ref,
      memberId,
    ) async {
      final getMemberAssignedSchedules = ref.watch(
        getMemberAssignedSchedulesProvider,
      );
      return await getMemberAssignedSchedules(memberId);
    });

// Current member ID provider
final currentMemberIdProvider = FutureProvider<String?>((ref) async {
  try {
    // RoleService üzerinden current user'ın member_id'sini al
    // Bu method'un RoleService'te implement edilmesi gerekiyor
    return await RoleService.getCurrentMemberId();
  } catch (e) {
    return null;
  }
});

// Tek ders detayı için provider
final lessonScheduleDetailProvider =
    FutureProvider.family<LessonScheduleWithPackage, String>((
      ref,
      scheduleId,
    ) async {
      final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
      return await repository.getLessonScheduleWithPackageById(scheduleId);
    });

// Member'ın kayıtlı olduğu dersler (current member için)
final currentMemberSchedulesProvider =
    FutureProvider<List<LessonScheduleWithPackage>>((ref) async {
      final memberId = await ref.watch(currentMemberIdProvider.future);
      if (memberId == null) return [];

      final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
      return await repository.getMemberAssignedSchedules(memberId);
    });

// Auto Status Update Service
final autoStatusUpdateServiceProvider = Provider<AutoStatusUpdateService>((
  ref,
) {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return AutoStatusUpdateService(repository);
});

// Auto status update methods
final autoStatusUpdateMethodsProvider = Provider<AutoStatusUpdateMethods>((
  ref,
) {
  final service = ref.watch(autoStatusUpdateServiceProvider);
  return AutoStatusUpdateMethods(service);
});

// Unique lesson durations provider
final uniqueLessonDurationsProvider = FutureProvider<List<int>>((ref) async {
  final repository = ref.watch(data.lessonSchedulesRepositoryProvider);
  return await repository.getUniqueLessonDurations();
});

class AutoStatusUpdateMethods {
  final AutoStatusUpdateService _service;

  AutoStatusUpdateMethods(this._service);

  void startAutoUpdate() {
    _service.startAutoUpdate();
  }

  void stopAutoUpdate() {
    _service.stopAutoUpdate();
  }

  Future<List<String>> runManualUpdate() async {
    return await _service.runManualUpdate();
  }

  bool get isActive => _service.isActive;
}
