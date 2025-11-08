import '../repositories/groups_repository_interface.dart';

class DeleteGroup {
  final GroupsRepositoryInterface repository;

  DeleteGroup(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Grup ID boş olamaz');
    }

    await repository.deleteGroup(id);
  }
}
