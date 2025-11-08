import 'package:flutter/material.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';

class LessonScheduleCard extends StatelessWidget {
  final LessonScheduleWithPackage schedule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LessonScheduleCard({
    super.key,
    required this.schedule,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.packageName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Düzenle',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Sil',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(
                  context,
                  _getDayLabel(schedule.dayOfWeek),
                  _getDayColor(schedule.dayOfWeek),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  context,
                  '${schedule.startTime} - ${schedule.endTime}',
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Oluşturulma: ${_formatDate(schedule.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getDayLabel(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'Pazartesi';
      case 'tuesday':
        return 'Salı';
      case 'wednesday':
        return 'Çarşamba';
      case 'thursday':
        return 'Perşembe';
      case 'friday':
        return 'Cuma';
      case 'saturday':
        return 'Cumartesi';
      case 'sunday':
        return 'Pazar';
      default:
        return dayOfWeek;
    }
  }

  Color _getDayColor(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return Colors.red;
      case 'tuesday':
        return Colors.orange;
      case 'wednesday':
        return Colors.yellow[700]!;
      case 'thursday':
        return Colors.green;
      case 'friday':
        return Colors.blue;
      case 'saturday':
        return Colors.purple;
      case 'sunday':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
