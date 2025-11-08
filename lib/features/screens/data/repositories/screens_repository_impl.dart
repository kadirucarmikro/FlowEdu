import '../../domain/entities/screen.dart';
import '../../domain/repositories/screens_repository_interface.dart';
import '../data_sources/screens_remote_data_source.dart';

class ScreensRepositoryImpl implements ScreensRepositoryInterface {
  final ScreensRemoteDataSource _remoteDataSource;

  ScreensRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Screen>> getScreens() async {
    try {
      final screenModels = await _remoteDataSource.getScreens();
      return screenModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Ekranlar getirilemedi: $e');
    }
  }

  @override
  Future<Screen?> getScreenById(String id) async {
    try {
      final screenModel = await _remoteDataSource.getScreenById(id);
      return screenModel?.toEntity();
    } catch (e) {
      throw Exception('Ekran getirilemedi: $e');
    }
  }

  @override
  Future<Screen> createScreen({
    required String name,
    required String route,
    String? description,
    String? parentModule,
    String iconName = 'info',
    List<String> requiredPermissions = const ['read'],
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    try {
      final screenModel = await _remoteDataSource.createScreen(
        name: name,
        route: route,
        description: description,
        parentModule: parentModule,
        iconName: iconName,
        requiredPermissions: requiredPermissions,
        isActive: isActive,
        sortOrder: sortOrder,
      );
      return screenModel.toEntity();
    } catch (e) {
      throw Exception('Ekran oluşturulamadı: $e');
    }
  }

  @override
  Future<Screen> updateScreen({
    required String id,
    String? name,
    String? route,
    String? description,
    String? parentModule,
    String? iconName,
    List<String>? requiredPermissions,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      final screenModel = await _remoteDataSource.updateScreen(
        id: id,
        name: name,
        route: route,
        description: description,
        parentModule: parentModule,
        iconName: iconName,
        requiredPermissions: requiredPermissions,
        isActive: isActive,
        sortOrder: sortOrder,
      );
      return screenModel.toEntity();
    } catch (e) {
      throw Exception('Ekran güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteScreen(String id) async {
    try {
      await _remoteDataSource.deleteScreen(id);
    } catch (e) {
      throw Exception('Ekran silinemedi: $e');
    }
  }
}
