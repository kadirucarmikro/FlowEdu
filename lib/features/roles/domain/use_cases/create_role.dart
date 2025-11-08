import '../entities/role.dart';
import '../repositories/roles_repository_interface.dart';

class CreateRole {
  final RolesRepositoryInterface repository;

  CreateRole(this.repository);

  Future<Role> call({required String name, bool isActive = true}) async {
    // Validasyon
    if (name.trim().isEmpty) {
      throw ArgumentError('Rol adı boş olamaz');
    }

    if (name.trim().length < 2) {
      throw ArgumentError('Rol adı en az 2 karakter olmalıdır');
    }

    return await repository.createRole(name: name.trim(), isActive: isActive);
  }
}
