import '../entities/screen.dart';
import '../repositories/screens_repository_interface.dart';

class UpdateScreen {
  final ScreensRepositoryInterface repository;

  UpdateScreen(this.repository);

  Future<Screen> call({
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
    // Validasyon
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Ekran adı boş olamaz');
    }

    if (name != null && name.trim().length < 2) {
      throw ArgumentError('Ekran adı en az 2 karakter olmalıdır');
    }

    if (route != null && route.trim().isEmpty) {
      throw ArgumentError('Route boş olamaz');
    }

    if (route != null && !route.startsWith('/')) {
      throw ArgumentError('Route / ile başlamalıdır');
    }

    return await repository.updateScreen(
      id: id,
      name: name?.trim(),
      route: route?.trim(),
      description: description?.trim(),
      parentModule: parentModule?.trim(),
      iconName: iconName,
      requiredPermissions: requiredPermissions,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }
}
