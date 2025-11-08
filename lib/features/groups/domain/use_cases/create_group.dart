import '../entities/group.dart';
import '../repositories/groups_repository_interface.dart';

class CreateGroup {
  final GroupsRepositoryInterface repository;

  CreateGroup(this.repository);

  Future<Group> call({required String name, bool isActive = true}) async {
    // Validasyon
    if (name.trim().isEmpty) {
      throw ArgumentError('Grup adı boş olamaz');
    }

    if (name.trim().length < 2) {
      throw ArgumentError('Grup adı en az 2 karakter olmalıdır');
    }

    return await repository.createGroup(name: name.trim(), isActive: isActive);
  }
}
