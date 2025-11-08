import '../entities/role.dart';

abstract class RolesRepositoryInterface {
  /// Tüm rolleri getirir
  Future<List<Role>> getRoles();

  /// ID'ye göre rol getirir
  Future<Role?> getRoleById(String id);

  /// Yeni rol oluşturur
  Future<Role> createRole({required String name, bool isActive = true});

  /// Rol günceller
  Future<Role> updateRole({required String id, String? name, bool? isActive});

  /// Rol siler
  Future<void> deleteRole(String id);
}
