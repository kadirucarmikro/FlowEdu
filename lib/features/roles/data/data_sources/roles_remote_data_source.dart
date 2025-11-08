import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/role_model.dart';

abstract class RolesRemoteDataSource {
  Future<List<RoleModel>> getRoles();
  Future<RoleModel?> getRoleById(String id);
  Future<RoleModel> createRole({required String name, bool isActive = true});
  Future<RoleModel> updateRole({
    required String id,
    String? name,
    bool? isActive,
  });
  Future<void> deleteRole(String id);
}

class RolesRemoteDataSourceImpl implements RolesRemoteDataSource {
  final SupabaseClient _client;

  RolesRemoteDataSourceImpl(this._client);

  @override
  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await _client
          .from('roles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RoleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Roller getirilemedi: $e');
    }
  }

  @override
  Future<RoleModel?> getRoleById(String id) async {
    try {
      final response = await _client
          .from('roles')
          .select()
          .eq('id', id)
          .single();

      return RoleModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return null; // Kayıt bulunamadı
      }
      throw Exception('Rol getirilemedi: $e');
    }
  }

  @override
  Future<RoleModel> createRole({
    required String name,
    bool isActive = true,
  }) async {
    try {
      final response = await _client
          .from('roles')
          .insert({'name': name, 'is_active': isActive})
          .select()
          .single();

      return RoleModel.fromJson(response);
    } catch (e) {
      throw Exception('Rol oluşturulamadı: $e');
    }
  }

  @override
  Future<RoleModel> updateRole({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _client
          .from('roles')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return RoleModel.fromJson(response);
    } catch (e) {
      throw Exception('Rol güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _client.from('roles').delete().eq('id', id);
    } catch (e) {
      throw Exception('Rol silinemedi: $e');
    }
  }
}
