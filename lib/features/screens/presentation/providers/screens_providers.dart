import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_sources/screens_remote_data_source.dart';
import '../../data/repositories/screens_repository_impl.dart';
import '../../domain/use_cases/get_screens.dart';
import '../../domain/use_cases/create_screen.dart';
import '../../domain/use_cases/update_screen.dart';
import '../../domain/use_cases/delete_screen.dart';

// Data Source Provider
final screensRemoteDataSourceProvider = Provider<ScreensRemoteDataSource>((
  ref,
) {
  return ScreensRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository Provider
final screensRepositoryProvider = Provider<ScreensRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(screensRemoteDataSourceProvider);
  return ScreensRepositoryImpl(remoteDataSource);
});

// Use Cases Providers
final getScreensProvider = Provider<GetScreens>((ref) {
  final repository = ref.watch(screensRepositoryProvider);
  return GetScreens(repository);
});

final createScreenProvider = Provider<CreateScreen>((ref) {
  final repository = ref.watch(screensRepositoryProvider);
  return CreateScreen(repository);
});

final updateScreenProvider = Provider<UpdateScreen>((ref) {
  final repository = ref.watch(screensRepositoryProvider);
  return UpdateScreen(repository);
});

final deleteScreenProvider = Provider<DeleteScreen>((ref) {
  final repository = ref.watch(screensRepositoryProvider);
  return DeleteScreen(repository);
});

// Screens List Provider
final screensListProvider = FutureProvider((ref) async {
  final getScreens = ref.watch(getScreensProvider);
  return await getScreens();
});
