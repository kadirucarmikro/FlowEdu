import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onRespond,
    this.onViewResponses,
    this.hasResponded = false,
  });

  final Event event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRespond;
  final VoidCallback? onViewResponses;
  final bool hasResponded;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showEventDetailsDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: BoxConstraints(maxHeight: isMobile ? 200 : 250),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: isMobile ? 14 : 16),
                        maxLines: isMobile ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Action buttons row
                    if (!isMobile)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (event.type != EventType.normal &&
                              onRespond != null)
                            IconButton(
                              icon: const Icon(Icons.reply, size: 18),
                              onPressed: onRespond,
                              tooltip: 'Yanıtla',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: onEdit,
                              tooltip: 'Düzenle',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: onDelete,
                              tooltip: 'Sil',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                  ],
                ),

                // Description (truncated)
                if (event.description != null) ...[
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isMobile ? 11 : 12,
                    ),
                    maxLines: isMobile ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: isMobile ? 6 : 8),

                // Event status (only show if responded)
                if (hasResponded) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: isMobile ? 12 : 14,
                        color: Colors.green,
                      ),
                      SizedBox(width: isMobile ? 2 : 4),
                      Text(
                        'Yanıtlandı',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 9 : 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                ],

                // Event dates - Always show section
                SizedBox(height: isMobile ? 2 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: isMobile ? 10 : 12,
                      color: Colors.green[600],
                    ),
                    SizedBox(width: isMobile ? 2 : 4),
                    Text(
                      event.startAt != null
                          ? 'Başlangıç: ${_formatCompactDateTime(event.startAt!)}'
                          : 'Başlangıç: Belirtilmemiş',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isMobile ? 8 : 9,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 1 : 2),
                Row(
                  children: [
                    Icon(
                      Icons.stop,
                      size: isMobile ? 10 : 12,
                      color: Colors.red[600],
                    ),
                    SizedBox(width: isMobile ? 2 : 4),
                    Text(
                      event.endAt != null
                          ? 'Bitiş: ${_formatCompactDateTime(event.endAt!)}'
                          : 'Bitiş: Belirtilmemiş',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isMobile ? 8 : 9,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 1 : 2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isMobile ? 10 : 12,
                      color: Colors.orange[600],
                    ),
                    SizedBox(width: isMobile ? 2 : 4),
                    Text(
                      event.registrationDeadline != null
                          ? 'Son Cevap: ${_formatCompactDateTime(event.registrationDeadline!)}'
                          : 'Son Cevap: Belirtilmemiş',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isMobile ? 8 : 9,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),

                // Options (limited)
                if (event.options.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    'Seçenekler:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 9 : 10,
                    ),
                  ),
                  SizedBox(height: isMobile ? 1 : 2),
                  Wrap(
                    spacing: isMobile ? 2 : 4,
                    runSpacing: isMobile ? 1 : 2,
                    children: event.options.take(isMobile ? 2 : 3).map((
                      option,
                    ) {
                      return Chip(
                        label: Text(
                          option.optionText,
                          style: TextStyle(fontSize: isMobile ? 8 : 10),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  if (event.options.length > (isMobile ? 2 : 3)) ...[
                    SizedBox(height: isMobile ? 1 : 2),
                    Text(
                      '+${event.options.length - (isMobile ? 2 : 3)} daha',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isMobile ? 8 : 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],

                // Image (smaller)
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? Image.network(
                          event.imageUrl!,
                          width: double.infinity,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),

                // Mobile action buttons
                if (isMobile) ...[
                  SizedBox(height: isMobile ? 6 : 8),
                  Row(
                    children: [
                      if (event.type != EventType.normal && onRespond != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onRespond,
                            icon: const Icon(Icons.reply, size: 14),
                            label: const Text(
                              'Yanıtla',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                            ),
                          ),
                        ),
                      if (event.type != EventType.normal &&
                          onRespond != null &&
                          onViewResponses != null)
                        const SizedBox(width: 4),
                      if (onViewResponses != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onViewResponses,
                            icon: const Icon(Icons.visibility, size: 14),
                            label: const Text(
                              'Yanıtlar',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  // Desktop view responses button
                  if (onViewResponses != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onViewResponses,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text(
                          'Yanıtları Görüntüle',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width > 768 ? 400 : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.description != null) ...[
                const Text(
                  'Açıklama:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(event.description!),
                const SizedBox(height: 16),
              ],

              _buildDetailRow('Tür', _getEventTypeLabel()),

              if (event.startAt != null)
                _buildDetailRow('Başlangıç', _formatDateTime(event.startAt!)),

              if (event.endAt != null)
                _buildDetailRow('Bitiş', _formatDateTime(event.endAt!)),

              if (event.options.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Seçenekler:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...event.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• ${option.optionText}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          if (onEdit != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEdit!();
              },
              child: const Text('Düzenle'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getEventTypeLabel() {
    switch (event.type) {
      case EventType.normal:
        return 'Normal';
      case EventType.interactive:
        return 'Etkileşimli';
      case EventType.poll:
        return 'Anket';
      case EventType.workshop:
        return 'Atölye';
      case EventType.seminar:
        return 'Seminer';
      case EventType.conference:
        return 'Konferans';
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[100]!, Colors.purple[100]!],
        ),
      ),
      child: const Icon(Icons.event, size: 40, color: Colors.white70),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCompactDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (eventDate == today) {
      return 'Bugün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Yarın ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Dün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
