import '../entities/group.dart';
import '../repositories/groups_repository_interface.dart';

class GetGroups {
  final GroupsRepositoryInterface repository;

  GetGroups(this.repository);

  Future<List<Group>> call() async {
    return await repository.getGroups();
  }
}
