import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.showActions = true,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: notification.isRead ? 1 : 3, // Okundu ise daha az gölge
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: notification.isRead ? Colors.grey[50] : Colors.white,
            border: notification.isRead
                ? Border.all(color: Colors.grey[300]!, width: 1)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and actions
                Row(
                  children: [
                    // Okundu/Okunmadı ikonu
                    Icon(
                      notification.isRead
                          ? Icons.mark_email_read
                          : Icons.mark_email_unread,
                      size: 16,
                      color: notification.isRead ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: notification.isRead
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showActions) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: onEdit,
                        tooltip: 'Düzenle',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Sil',
                      ),
                    ],
                  ],
                ),

                // Body (truncated)
                if (notification.body != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    notification.body!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: notification.isRead
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Target info
                if (notification.targetName != null) ...[
                  Row(
                    children: [
                      Icon(
                        _getTargetIcon(notification.targetType),
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTargetLabel(notification.targetType),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          notification.targetName!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // Date and status
                Row(
                  children: [
                    Text(
                      _formatDate(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: notification.isRead
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Okundu durumu göstergesi
                    if (notification.isRead)
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTargetIcon(String? targetType) {
    switch (targetType) {
      case 'group':
        return Icons.group;
      case 'role':
        return Icons.person;
      case 'member':
        return Icons.person_outline;
      case 'birthday':
        return Icons.cake;
      default:
        return Icons.info;
    }
  }

  String _getTargetLabel(String? targetType) {
    switch (targetType) {
      case 'group':
        return 'Grup:';
      case 'role':
        return 'Rol:';
      case 'member':
        return 'Üye:';
      case 'birthday':
        return 'Doğum günü:';
      default:
        return 'Hedef:';
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
}
