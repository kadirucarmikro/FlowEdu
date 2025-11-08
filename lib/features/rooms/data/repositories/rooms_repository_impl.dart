import '../../domain/entities/room.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../data_sources/rooms_remote_data_source.dart';

class RoomsRepositoryImpl implements RoomsRepository {
  final RoomsRemoteDataSource _remoteDataSource;

  RoomsRepositoryImpl({required RoomsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Room>> getAllRooms() {
    return _remoteDataSource.getAllRooms();
  }

  @override
  Future<List<Room>> getActiveRooms() {
    return _remoteDataSource.getActiveRooms();
  }

  @override
  Future<Room> getRoomById(String id) {
    return _remoteDataSource.getRoomById(id);
  }

  @override
  Future<Room> createRoom(Room room) {
    return _remoteDataSource.createRoom(room);
  }

  @override
  Future<Room> updateRoom(Room room) {
    return _remoteDataSource.updateRoom(room);
  }

  @override
  Future<void> deleteRoom(String id) {
    return _remoteDataSource.deleteRoom(id);
  }

  @override
  Future<bool> checkRoomConflict(
    String roomId,
    DateTime date,
    String startTime,
    String endTime,
  ) {
    return _remoteDataSource.checkRoomConflict(
      roomId,
      date,
      startTime,
      endTime,
    );
  }
}
