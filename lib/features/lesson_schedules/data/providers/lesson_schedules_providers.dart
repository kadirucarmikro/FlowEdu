import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/lesson_schedules_remote_data_source.dart';
import '../repositories/lesson_schedules_repository_impl.dart';
import '../../../../app/di/providers.dart';

// Data Sources
final lessonSchedulesRemoteDataSourceProvider =
    Provider<LessonSchedulesRemoteDataSource>((ref) {
      return LessonSchedulesRemoteDataSource(
        supabase: ref.watch(supabaseProvider).client,
      );
    });

// Repositories
final lessonSchedulesRepositoryProvider =
    Provider<LessonSchedulesRepositoryImpl>((ref) {
      final remoteDataSource = ref.watch(
        lessonSchedulesRemoteDataSourceProvider,
      );
      return LessonSchedulesRepositoryImpl(remoteDataSource);
    });
