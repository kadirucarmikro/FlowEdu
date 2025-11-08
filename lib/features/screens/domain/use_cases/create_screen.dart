import '../entities/screen.dart';
import '../repositories/screens_repository_interface.dart';

class CreateScreen {
  final ScreensRepositoryInterface repository;

  CreateScreen(this.repository);

  Future<Screen> call({
    required String name,
    required String route,
    String? description,
    String? parentModule,
    String iconName = 'info',
    List<String> requiredPermissions = const ['read'],
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    // Validasyon
    if (name.trim().isEmpty) {
      throw ArgumentError('Ekran adı boş olamaz');
    }

    if (name.trim().length < 2) {
      throw ArgumentError('Ekran adı en az 2 karakter olmalıdır');
    }

    if (route.trim().isEmpty) {
      throw ArgumentError('Route boş olamaz');
    }

    if (!route.startsWith('/')) {
      throw ArgumentError('Route / ile başlamalıdır');
    }

    return await repository.createScreen(
      name: name.trim(),
      route: route.trim(),
      description: description?.trim(),
      parentModule: parentModule?.trim(),
      iconName: iconName,
      requiredPermissions: requiredPermissions,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }
}
