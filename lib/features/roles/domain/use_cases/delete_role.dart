import '../repositories/roles_repository_interface.dart';

class DeleteRole {
  final RolesRepositoryInterface repository;

  DeleteRole(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Rol ID boş olamaz');
    }

    await repository.deleteRole(id);
  }
}
