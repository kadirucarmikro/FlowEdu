import '../entities/role.dart';
import '../repositories/roles_repository_interface.dart';

class GetRoles {
  final RolesRepositoryInterface repository;

  GetRoles(this.repository);

  Future<List<Role>> call() async {
    return await repository.getRoles();
  }
}
