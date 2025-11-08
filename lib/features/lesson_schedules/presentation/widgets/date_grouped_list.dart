import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../../../core/utils/date_time_helpers.dart';

class DateGroupedList extends ConsumerWidget {
  final Map<String, List<LessonScheduleWithPackage>> groupedSchedules;
  final VoidCallback onRefresh;
  final Function(String scheduleId)? onScheduleTap;

  const DateGroupedList({
    super.key,
    required this.groupedSchedules,
    required this.onRefresh,
    this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groupedSchedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz ders programı oluşturulmamış',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Tarih gruplarını sırala
    final sortedGroups = _sortDateGroups(groupedSchedules);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedGroups.length,
        itemBuilder: (context, index) {
          final groupName = sortedGroups.keys.elementAt(index);
          final schedules = sortedGroups[groupName]!;

          return _buildDateGroupCard(context, groupName, schedules);
        },
      ),
    );
  }

  Widget _buildDateGroupCard(
    BuildContext context,
    String groupName,
    List<LessonScheduleWithPackage> schedules,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getGroupColor(groupName),
          child: Icon(_getGroupIcon(groupName), color: Colors.white),
        ),
        title: Text(
          groupName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${schedules.length} ders'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getGroupColor(groupName).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${schedules.length}',
            style: TextStyle(
              color: _getGroupColor(groupName),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: schedules
                  .map((schedule) => _buildScheduleItem(context, schedule))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    LessonScheduleWithPackage schedule,
  ) {
    final scheduleDate = _getScheduleDate(schedule);
    final isPast = scheduleDate.isBefore(DateTime.now());
    final isToday = _isToday(scheduleDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isPast
          ? Colors.grey.withValues(alpha: 0.1)
          : isToday
          ? Colors.blue.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getPackageColor(schedule.packageName),
          child: Text(
            schedule.packageName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          schedule.packageName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateTimeHelpers.getDayName(scheduleDate)} - ${schedule.startTime}',
            ),
            if (schedule.instructorName != null &&
                schedule.instructorName!.isNotEmpty)
              Text('Eğitmen: ${schedule.instructorName}'),
            if (schedule.roomName != null && schedule.roomName!.isNotEmpty)
              Text('Oda: ${schedule.roomName}'),
            Text('Katılımcı: ${schedule.attendeeIds.length}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPast)
              const Icon(Icons.check_circle, color: Colors.grey, size: 20)
            else if (isToday)
              const Icon(Icons.today, color: Colors.blue, size: 20)
            else
              const Icon(Icons.schedule, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => onScheduleTap?.call(schedule.id),
      ),
    );
  }

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case 'Bugün':
        return Colors.blue;
      case 'Yarın':
        return Colors.green;
      case 'Öbür Gün':
        return Colors.orange;
      case 'Bu Hafta':
        return Colors.purple;
      case 'Gelecek Hafta':
        return Colors.teal;
      case 'Gelecek Ay':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getGroupIcon(String groupName) {
    switch (groupName) {
      case 'Bugün':
        return Icons.today;
      case 'Yarın':
        return Icons.schedule;
      case 'Öbür Gün':
        return Icons.schedule;
      case 'Bu Hafta':
        return Icons.date_range;
      case 'Gelecek Hafta':
        return Icons.calendar_view_week;
      case 'Gelecek Ay':
        return Icons.calendar_month;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getPackageColor(String packageName) {
    final hash = packageName.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  DateTime _getScheduleDate(LessonScheduleWithPackage schedule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final targetWeekday = dayMap[schedule.dayOfWeek] ?? 1;
    final currentWeekday = now.weekday;

    int daysToAdd = targetWeekday - currentWeekday;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }

    return today.add(Duration(days: daysToAdd));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, List<LessonScheduleWithPackage>> _sortDateGroups(
    Map<String, List<LessonScheduleWithPackage>> groups,
  ) {
    final order = [
      'Bugün',
      'Yarın',
      'Öbür Gün',
      'Bu Hafta',
      'Gelecek Hafta',
      'Gelecek Ay',
    ];

    final sortedGroups = <String, List<LessonScheduleWithPackage>>{};

    // Önce sıralı grupları ekle
    for (final groupName in order) {
      if (groups.containsKey(groupName)) {
        sortedGroups[groupName] = groups[groupName]!;
      }
    }

    // Sonra diğer grupları ekle
    for (final entry in groups.entries) {
      if (!order.contains(entry.key)) {
        sortedGroups[entry.key] = entry.value;
      }
    }

    return sortedGroups;
  }
}
