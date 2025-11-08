import '../entities/screen.dart';

abstract class ScreensRepositoryInterface {
  /// Tüm ekranları getirir
  Future<List<Screen>> getScreens();

  /// ID'ye göre ekran getirir
  Future<Screen?> getScreenById(String id);

  /// Yeni ekran oluşturur
  Future<Screen> createScreen({
    required String name,
    required String route,
    String? description,
    String? parentModule,
    String iconName = 'info',
    List<String> requiredPermissions = const ['read'],
    bool isActive = true,
    int sortOrder = 0,
  });

  /// Ekran günceller
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
  });

  /// Ekran siler
  Future<void> deleteScreen(String id);
}
