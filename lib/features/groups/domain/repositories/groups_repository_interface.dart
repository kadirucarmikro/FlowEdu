import '../entities/group.dart';

abstract class GroupsRepositoryInterface {
  /// Tüm grupları getirir
  Future<List<Group>> getGroups();

  /// ID'ye göre grup getirir
  Future<Group?> getGroupById(String id);

  /// Yeni grup oluşturur
  Future<Group> createGroup({required String name, bool isActive = true});

  /// Grup günceller
  Future<Group> updateGroup({required String id, String? name, bool? isActive});

  /// Grup siler
  Future<void> deleteGroup(String id);
}
