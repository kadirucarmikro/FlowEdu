import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../data_sources/rooms_remote_data_source.dart';
import '../repositories/rooms_repository_impl.dart';
import '../../domain/entities/room.dart';

// Data Source Provider
final roomsRemoteDataSourceProvider = Provider<RoomsRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return RoomsRemoteDataSource(supabase: supabase.client);
});

// Repository Provider
final roomsRepositoryProvider = Provider<RoomsRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(roomsRemoteDataSourceProvider);
  return RoomsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// All Rooms Provider
final allRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final repository = ref.watch(roomsRepositoryProvider);
  return await repository.getAllRooms();
});

// Active Rooms Provider
final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final repository = ref.watch(roomsRepositoryProvider);
  return await repository.getActiveRooms();
});

// Room by ID Provider
final roomByIdProvider = FutureProvider.family<Room, String>((ref, id) async {
  final repository = ref.watch(roomsRepositoryProvider);
  return await repository.getRoomById(id);
});
