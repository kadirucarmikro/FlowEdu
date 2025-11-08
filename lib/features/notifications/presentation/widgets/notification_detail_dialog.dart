import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_providers.dart';

class NotificationDetailDialog extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationDetailDialog({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(notification.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bildirim İçeriği
                    if (notification.body != null &&
                        notification.body!.isNotEmpty) ...[
                      _buildDetailSection('Bildirim İçeriği', [
                        Text(
                          notification.body!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ],

                    // Hedef Bilgileri
                    _buildDetailSection('Hedef Bilgileri', [
                      _buildDetailRow(
                        'Hedef Türü',
                        _getTargetTypeLabel(notification.targetType),
                      ),
                      if (notification.targetName != null)
                        _buildDetailRow('Hedef', notification.targetName!),
                    ]),

                    const SizedBox(height: 20),

                    // Durum Bilgileri
                    _buildDetailSection('Durum Bilgileri', [
                      _buildDetailRow(
                        'Okundu',
                        notification.isRead ? 'Evet' : 'Hayır',
                        valueColor: notification.isRead
                            ? Colors.green
                            : Colors.orange,
                      ),
                      if (notification.hasResponse)
                        _buildDetailRow(
                          'Yanıt Verildi',
                          'Evet',
                          valueColor: Colors.blue,
                        ),
                    ]),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (!notification.isRead) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markAsRead(context, ref),
                        icon: const Icon(Icons.mark_email_read, size: 16),
                        label: const Text('Okundu İşaretle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Kapat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTargetTypeLabel(String? targetType) {
    switch (targetType) {
      case 'role':
        return 'Rol Bazlı';
      case 'group':
        return 'Grup Bazlı';
      case 'member':
        return 'Üye Bazlı';
      case 'birthday':
        return 'Doğum Günü Bazlı';
      default:
        return 'Bilinmeyen';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _markAsRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(markNotificationAsReadProvider).call(notification.id);
      ref.invalidate(memberNotificationsListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim okundu olarak işaretlendi'),
            backgroundColor: Colors.green,
          ),
        );
        // Popup'ı kapat
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
