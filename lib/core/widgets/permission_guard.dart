import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/role_service.dart';
import 'centered_error_widget.dart';

class PermissionGuard extends ConsumerWidget {
  final String? screenName;
  final String? screenId;
  final String action; // 'read', 'create', 'update', 'delete'
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    this.screenName,
    this.screenId,
    required this.action,
    required this.child,
    this.fallback,
  }) : assert(
         screenName != null || screenId != null,
         'Either screenName or screenId must be provided',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredLoadingWidget();
        }

        if (snapshot.hasError) {
          return CenteredErrorWidget.generalError(
            message: 'Yetki hatası: ${snapshot.error}',
          );
        }

        final hasPermission = snapshot.data ?? false;

        if (hasPermission) {
          return child;
        } else {
          final targetScreen = screenId ?? screenName!;
          return fallback ??
              _buildPermissionDeniedWidget(context, targetScreen, action);
        }
      },
    );
  }

  Future<bool> _checkPermission() async {
    // Yeni rol sistemi kurallarına göre basit kontrol
    switch (action) {
      case 'read':
        return true; // Tüm kullanıcılar okuyabilir
      case 'create':
      case 'update':
      case 'delete':
        return await RoleService.isAdmin(); // Sadece admin yapabilir
      default:
        return false;
    }
  }

  Widget _buildPermissionDeniedWidget(
    BuildContext context,
    String screenName,
    String action,
  ) {
    return CenteredErrorWidget.accessDenied(
      message:
          'Bu işlem için yetkiniz bulunmamaktadır. Lütfen yöneticinizle iletişime geçin.',
      onRetry: () => Navigator.of(context).pop(),
      retryButtonText: 'Geri Dön',
    );
  }
}

// CRUD işlemleri için özel widget'lar
class CreatePermissionGuard extends StatelessWidget {
  final String screenName;
  final Widget child;
  final Widget? fallback;

  const CreatePermissionGuard({
    super.key,
    required this.screenName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      screenName: screenName,
      action: 'create',
      fallback: fallback,
      child: child,
    );
  }
}

class UpdatePermissionGuard extends StatelessWidget {
  final String screenName;
  final Widget child;
  final Widget? fallback;

  const UpdatePermissionGuard({
    super.key,
    required this.screenName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      screenName: screenName,
      action: 'update',
      fallback: fallback,
      child: child,
    );
  }
}

class DeletePermissionGuard extends StatelessWidget {
  final String screenName;
  final Widget child;
  final Widget? fallback;

  const DeletePermissionGuard({
    super.key,
    required this.screenName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      screenName: screenName,
      action: 'delete',
      fallback: fallback,
      child: child,
    );
  }
}

// Yetki kontrolü için utility fonksiyonlar
class PermissionUtils {
  static void showPermissionDeniedSnackBar(
    BuildContext context,
    String screenName,
    String action,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Bu işlem için yetkiniz bulunmamaktadır. Lütfen yöneticinizle iletişime geçin.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Widget buildPermissionDeniedButton({
    required String screenName,
    required String action,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return FutureBuilder<bool>(
      future: _checkPermissionForAction(action),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final hasPermission = snapshot.data ?? false;

        if (hasPermission) {
          return child;
        } else {
          return IconButton(
            onPressed: () {
              showPermissionDeniedSnackBar(context, screenName, action);
            },
            icon: const Icon(Icons.lock),
            tooltip: 'Bu işlem için yetkiniz yok',
          );
        }
      },
    );
  }

  static Future<bool> _checkPermissionForAction(String action) async {
    switch (action) {
      case 'read':
        return true; // Tüm kullanıcılar okuyabilir
      case 'create':
      case 'update':
      case 'delete':
        return await RoleService.isAdmin(); // Sadece admin yapabilir
      default:
        return false;
    }
  }
}
