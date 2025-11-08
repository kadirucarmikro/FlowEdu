import '../entities/room.dart';

abstract class RoomsRepository {
  Future<List<Room>> getAllRooms();
  Future<List<Room>> getActiveRooms();
  Future<Room> getRoomById(String id);
  Future<Room> createRoom(Room room);
  Future<Room> updateRoom(Room room);
  Future<void> deleteRoom(String id);
  Future<bool> checkRoomConflict(
    String roomId,
    DateTime date,
    String startTime,
    String endTime,
  );
}
