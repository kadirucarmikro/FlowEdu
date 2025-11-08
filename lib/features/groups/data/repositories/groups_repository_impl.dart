import '../../domain/entities/group.dart';
import '../../domain/repositories/groups_repository_interface.dart';
import '../data_sources/groups_remote_data_source.dart';

class GroupsRepositoryImpl implements GroupsRepositoryInterface {
  final GroupsRemoteDataSource _remoteDataSource;

  GroupsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Group>> getGroups() async {
    try {
      final groupModels = await _remoteDataSource.getGroups();
      return groupModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Gruplar getirilemedi: $e');
    }
  }

  @override
  Future<Group?> getGroupById(String id) async {
    try {
      final groupModel = await _remoteDataSource.getGroupById(id);
      return groupModel?.toEntity();
    } catch (e) {
      throw Exception('Grup getirilemedi: $e');
    }
  }

  @override
  Future<Group> createGroup({
    required String name,
    bool isActive = true,
  }) async {
    try {
      final groupModel = await _remoteDataSource.createGroup(
        name: name,
        isActive: isActive,
      );
      return groupModel.toEntity();
    } catch (e) {
      throw Exception('Grup oluşturulamadı: $e');
    }
  }

  @override
  Future<Group> updateGroup({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    try {
      final groupModel = await _remoteDataSource.updateGroup(
        id: id,
        name: name,
        isActive: isActive,
      );
      return groupModel.toEntity();
    } catch (e) {
      throw Exception('Grup güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      await _remoteDataSource.deleteGroup(id);
    } catch (e) {
      throw Exception('Grup silinemedi: $e');
    }
  }
}
