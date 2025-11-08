import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/room.dart';

class RoomsRemoteDataSource {
  final SupabaseClient _supabase;

  RoomsRemoteDataSource({required SupabaseClient supabase})
    : _supabase = supabase;

  Future<List<Room>> getAllRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .order('name', ascending: true);

      return response.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Odalar getirilemedi: $e');
    }
  }

  Future<List<Room>> getActiveRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return response.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Aktif odalar getirilemedi: $e');
    }
  }

  Future<Room> getRoomById(String id) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('id', id)
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Oda getirilemedi: $e');
    }
  }

  Future<Room> createRoom(Room room) async {
    try {
      final response = await _supabase
          .from('rooms')
          .insert(room.toJson())
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Oda oluşturulamadı: $e');
    }
  }

  Future<Room> updateRoom(Room room) async {
    try {
      final response = await _supabase
          .from('rooms')
          .update(room.toJson())
          .eq('id', room.id)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Oda güncellenemedi: $e');
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await _supabase.from('rooms').delete().eq('id', id);
    } catch (e) {
      throw Exception('Oda silinemedi: $e');
    }
  }

  Future<bool> checkRoomConflict(
    String roomId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    try {
      final response = await _supabase
          .from('lesson_schedules')
          .select('id')
          .eq('room_id', roomId)
          .eq('day_of_week', _getDayOfWeek(date.weekday))
          .gte('start_time', startTime)
          .lte('end_time', endTime);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
