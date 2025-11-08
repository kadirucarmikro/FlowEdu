import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel?> getGroupById(String id);
  Future<GroupModel> createGroup({required String name, bool isActive = true});
  Future<GroupModel> updateGroup({
    required String id,
    String? name,
    bool? isActive,
  });
  Future<void> deleteGroup(String id);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final SupabaseClient _client;

  GroupsRemoteDataSourceImpl(this._client);

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _client
          .from('groups')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GroupModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gruplar getirilemedi: $e');
    }
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    try {
      final response = await _client
          .from('groups')
          .select()
          .eq('id', id)
          .single();

      return GroupModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return null; // Kayıt bulunamadı
      }
      throw Exception('Grup getirilemedi: $e');
    }
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    bool isActive = true,
  }) async {
    try {
      final response = await _client
          .from('groups')
          .insert({'name': name, 'is_active': isActive})
          .select()
          .single();

      return GroupModel.fromJson(response);
    } catch (e) {
      throw Exception('Grup oluşturulamadı: $e');
    }
  }

  @override
  Future<GroupModel> updateGroup({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _client
          .from('groups')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return GroupModel.fromJson(response);
    } catch (e) {
      throw Exception('Grup güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      await _client.from('groups').delete().eq('id', id);
    } catch (e) {
      throw Exception('Grup silinemedi: $e');
    }
  }
}
