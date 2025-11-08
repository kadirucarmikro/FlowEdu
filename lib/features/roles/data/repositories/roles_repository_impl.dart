import '../../domain/entities/role.dart';
import '../../domain/repositories/roles_repository_interface.dart';
import '../data_sources/roles_remote_data_source.dart';

class RolesRepositoryImpl implements RolesRepositoryInterface {
  final RolesRemoteDataSource _remoteDataSource;

  RolesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Role>> getRoles() async {
    try {
      final roleModels = await _remoteDataSource.getRoles();
      return roleModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Roller getirilemedi: $e');
    }
  }

  @override
  Future<Role?> getRoleById(String id) async {
    try {
      final roleModel = await _remoteDataSource.getRoleById(id);
      return roleModel?.toEntity();
    } catch (e) {
      throw Exception('Rol getirilemedi: $e');
    }
  }

  @override
  Future<Role> createRole({required String name, bool isActive = true}) async {
    try {
      final roleModel = await _remoteDataSource.createRole(
        name: name,
        isActive: isActive,
      );
      return roleModel.toEntity();
    } catch (e) {
      throw Exception('Rol oluşturulamadı: $e');
    }
  }

  @override
  Future<Role> updateRole({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    try {
      final roleModel = await _remoteDataSource.updateRole(
        id: id,
        name: name,
        isActive: isActive,
      );
      return roleModel.toEntity();
    } catch (e) {
      throw Exception('Rol güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _remoteDataSource.deleteRole(id);
    } catch (e) {
      throw Exception('Rol silinemedi: $e');
    }
  }
}
