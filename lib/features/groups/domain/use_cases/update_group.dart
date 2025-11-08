import '../entities/group.dart';
import '../repositories/groups_repository_interface.dart';

class UpdateGroup {
  final GroupsRepositoryInterface repository;

  UpdateGroup(this.repository);

  Future<Group> call({required String id, String? name, bool? isActive}) async {
    // Validasyon
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Grup adı boş olamaz');
    }

    if (name != null && name.trim().length < 2) {
      throw ArgumentError('Grup adı en az 2 karakter olmalıdır');
    }

    return await repository.updateGroup(
      id: id,
      name: name?.trim(),
      isActive: isActive,
    );
  }
}
