import '../entities/role.dart';
import '../repositories/roles_repository_interface.dart';

class UpdateRole {
  final RolesRepositoryInterface repository;

  UpdateRole(this.repository);

  Future<Role> call({required String id, String? name, bool? isActive}) async {
    // Validasyon
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Rol adı boş olamaz');
    }

    if (name != null && name.trim().length < 2) {
      throw ArgumentError('Rol adı en az 2 karakter olmalıdır');
    }

    return await repository.updateRole(
      id: id,
      name: name?.trim(),
      isActive: isActive,
    );
  }
}
