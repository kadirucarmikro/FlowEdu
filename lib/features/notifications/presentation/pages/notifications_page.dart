import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_form_dialog.dart';
import '../widgets/notification_detail_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as custom;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/responsive_grid_list.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  Map<String, dynamic> _filters = {
    'time_range': 'Tümü', // Default: Tümü
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Bildirimler'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showNotificationForm(),
                  icon: const Icon(Icons.add),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const custom.NavigationDrawer(),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildMemberView(),
      ),
    );
  }

  Widget _buildAdminView() {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Column(
      children: [
        // Admin filtreleme alanı - en üstte
        AdminFilterWidget(
          filterOptions: CommonFilterOptions.getNotificationFilters(),
          onFilterChanged: (filters) {
            setState(() {
              _filters = filters;
            });
          },
          initialFilters: _filters,
        ),
        // Liste görünümü
        Expanded(
          child: notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(notificationsListProvider),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz bildirim bulunmuyor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Yeni bildirim oluşturmak için + butonuna tıklayın',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // Filtreleme uygula
              final filteredNotifications = _applyFilters(notifications);

              return RefreshableResponsiveGridList<NotificationModel>(
                items: filteredNotifications,
                onRefresh: () async =>
                    ref.invalidate(notificationsListProvider),
                itemBuilder: (context, notification, index) {
                  return NotificationCard(
                    notification: notification,
                    showActions: true,
                    onTap: () => _showNotificationDetails(notification),
                    onEdit: () => _editNotification(notification),
                    onDelete: () => _deleteNotification(notification.id),
                  );
                },
                aspectRatio: 1.2,
                maxColumns: 3,
                emptyWidget: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz bildirim bulunmuyor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Yeni bildirim oluşturmak için + butonuna tıklayın',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    final notificationsAsync = ref.watch(memberNotificationsListProvider);

    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => CenteredErrorWidget.generalError(
        message: 'Hata: $error',
        onRetry: () => ref.invalidate(memberNotificationsListProvider),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz bildirim bulunmuyor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Size gönderilen bildirimler burada görünecek',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshableResponsiveGridList<NotificationModel>(
          items: notifications,
          onRefresh: () async =>
              ref.invalidate(memberNotificationsListProvider),
          itemBuilder: (context, notification, index) {
            return NotificationCard(
              notification: notification,
              showActions: false, // Member user için düğmeleri gizle
              onTap: () => _showNotificationDetails(notification),
            );
          },
          aspectRatio: 1.2,
          maxColumns: 3,
          emptyWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz bildirim bulunmuyor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Size gönderilen bildirimler burada görünecek',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<NotificationModel> _applyFilters(List<NotificationModel> notifications) {
    if (_filters.isEmpty) return notifications;

    return notifications.where((notification) {
      // Zaman aralığı filtresi
      if (_filters.containsKey('time_range') &&
          _filters['time_range'] != null &&
          _filters['time_range'] != 'Tümü') {
        final now = DateTime.now();
        final timeRange = _filters['time_range'] as String;
        switch (timeRange) {
          case 'Son 24 saat':
            final yesterday = now.subtract(const Duration(days: 1));
            if (!notification.createdAt.isAfter(yesterday)) {
              return false;
            }
            break;
          case 'Son hafta':
            final weekAgo = now.subtract(const Duration(days: 7));
            if (!notification.createdAt.isAfter(weekAgo)) {
              return false;
            }
            break;
        }
      }

      // Arama filtresi
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!notification.title.toLowerCase().contains(searchTerm) &&
            !(notification.body?.toLowerCase().contains(searchTerm) ?? false)) {
          return false;
        }
      }

      // Bildirim türü filtresi
      if (_filters.containsKey('type') &&
          _filters['type'] != null &&
          _filters['type'] != 'Tümü') {
        // Bu filtre notification model'ine göre uyarlanmalı
        // Şimdilik atlıyoruz çünkü notification model'inde type field'ı yok
      }

      // Hedef grup filtresi
      if (_filters.containsKey('target_group') &&
          _filters['target_group'] != null &&
          _filters['target_group'] != 'Tümü') {
        if (notification.targetType != 'group' ||
            notification.targetName?.toLowerCase() !=
                _filters['target_group'].toString().toLowerCase()) {
          return false;
        }
      }

      // Tarih aralığı filtresi (dateRange)
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final dateRange = _filters['created_date'] as Map<String, dynamic>?;
        if (dateRange != null) {
          if (dateRange.containsKey('start') && dateRange['start'] != null) {
            final startDate = dateRange['start'] as DateTime;
            if (notification.createdAt.isBefore(startDate)) {
              return false;
            }
          }
          if (dateRange.containsKey('end') && dateRange['end'] != null) {
            final endDate = dateRange['end'] as DateTime;
            if (notification.createdAt.isAfter(endDate)) {
              return false;
            }
          }
        }
      }

      return true;
    }).toList();
  }

  void _showNotificationForm() {
    showDialog(
      context: context,
      builder: (context) => const NotificationFormDialog(),
    );
  }

  void _editNotification(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => NotificationFormDialog(notification: notification),
    );
  }

  Future<void> _deleteNotification(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteNotificationProvider).call(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildirim başarıyla silindi')),
          );
          ref.invalidate(notificationsListProvider);
          ref.invalidate(memberNotificationsListProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) =>
          NotificationDetailDialog(notification: notification),
    );
  }

}
