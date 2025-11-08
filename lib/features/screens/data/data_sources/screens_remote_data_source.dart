import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/screen_model.dart';

abstract class ScreensRemoteDataSource {
  Future<List<ScreenModel>> getScreens();
  Future<ScreenModel?> getScreenById(String id);
  Future<ScreenModel> createScreen({
    required String name,
    required String route,
    String? description,
    String? parentModule,
    String iconName = 'info',
    List<String> requiredPermissions = const ['read'],
    bool isActive = true,
    int sortOrder = 0,
  });
  Future<ScreenModel> updateScreen({
    required String id,
    String? name,
    String? route,
    String? description,
    String? parentModule,
    String? iconName,
    List<String>? requiredPermissions,
    bool? isActive,
    int? sortOrder,
  });
  Future<void> deleteScreen(String id);
}

class ScreensRemoteDataSourceImpl implements ScreensRemoteDataSource {
  final SupabaseClient _client;

  ScreensRemoteDataSourceImpl(this._client);

  @override
  Future<List<ScreenModel>> getScreens() async {
    try {
      final response = await _client
          .from('screens')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ScreenModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Ekranlar getirilemedi: $e');
    }
  }

  @override
  Future<ScreenModel?> getScreenById(String id) async {
    try {
      final response = await _client
          .from('screens')
          .select()
          .eq('id', id)
          .single();

      return ScreenModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return null; // Kayıt bulunamadı
      }
      throw Exception('Ekran getirilemedi: $e');
    }
  }

  @override
  Future<ScreenModel> createScreen({
    required String name,
    required String route,
    String? description,
    String? parentModule,
    String iconName = 'info',
    List<String> requiredPermissions = const ['read'],
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('screens')
          .insert({
            'name': name,
            'route': route,
            'description': description,
            'parent_module': parentModule,
            'icon_name': iconName,
            'required_permissions': requiredPermissions,
            'is_active': isActive,
            'sort_order': sortOrder,
          })
          .select()
          .single();

      return ScreenModel.fromJson(response);
    } catch (e) {
      throw Exception('Ekran oluşturulamadı: $e');
    }
  }

  @override
  Future<ScreenModel> updateScreen({
    required String id,
    String? name,
    String? route,
    String? description,
    String? parentModule,
    String? iconName,
    List<String>? requiredPermissions,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (route != null) updateData['route'] = route;
      if (description != null) updateData['description'] = description;
      if (parentModule != null) updateData['parent_module'] = parentModule;
      if (iconName != null) updateData['icon_name'] = iconName;
      if (requiredPermissions != null) {
        updateData['required_permissions'] = requiredPermissions;
      }
      if (isActive != null) updateData['is_active'] = isActive;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;

      final response = await _client
          .from('screens')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return ScreenModel.fromJson(response);
    } catch (e) {
      throw Exception('Ekran güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteScreen(String id) async {
    try {
      await _client.from('screens').delete().eq('id', id);
    } catch (e) {
      throw Exception('Ekran silinemedi: $e');
    }
  }
}
