import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../utils/schedule_grouping.dart';
import '../../../../core/utils/date_time_helpers.dart';

class PackageGroupedList extends ConsumerWidget {
  final Map<String, List<LessonScheduleWithPackage>> groupedSchedules;
  final VoidCallback onRefresh;
  final Function(String scheduleId)? onScheduleTap;

  const PackageGroupedList({
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
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz ders programı oluşturulmamış',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedSchedules.length,
        itemBuilder: (context, index) {
          final packageId = groupedSchedules.keys.elementAt(index);
          final schedules = groupedSchedules[packageId]!;
          final summary = ScheduleGrouping.getPackageSummary(
            packageId,
            schedules,
          );

          return _buildPackageCard(context, summary, schedules);
        },
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    Map<String, dynamic> summary,
    List<LessonScheduleWithPackage> schedules,
  ) {
    final packageName = summary['packageName'] as String;
    final totalLessons = summary['totalLessons'] as int;
    final completedLessons = summary['completedLessons'] as int;
    final upcomingLessons = summary['upcomingLessons'] as int;
    final instructors = (summary['instructors'] as List<dynamic>)
        .cast<String>();
    final totalAttendees = summary['totalAttendees'] as int;
    final rooms = (summary['rooms'] as List<dynamic>).cast<String>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getPackageColor(packageName),
          child: Text(
            packageName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          packageName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam $totalLessons ders'),
            if (instructors.isNotEmpty)
              Text('Eğitmenler: ${instructors.join(', ')}'),
            if (rooms.isNotEmpty) Text('Odalar: ${rooms.join(', ')}'),
            Text('Toplam katılımcı: $totalAttendees'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$upcomingLessons aktif',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (completedLessons > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedLessons tamamlandı',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ders Detayları:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...schedules.map(
                  (schedule) => _buildScheduleItem(context, schedule),
                ),
              ],
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
            DateTimeHelpers.getDayName(scheduleDate).substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          '${DateTimeHelpers.getDayName(scheduleDate)} - ${schedule.startTime}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schedule.instructorName != null &&
                schedule.instructorName!.isNotEmpty)
              Text('Eğitmen: ${schedule.instructorName}'),
            if (schedule.roomName != null && schedule.roomName!.isNotEmpty)
              Text('Oda: ${schedule.roomName}'),
            Text('Katılımcı: ${schedule.attendeeIds.length}'),
          ],
        ),
        trailing: isPast
            ? const Icon(Icons.check_circle, color: Colors.grey)
            : isToday
            ? const Icon(Icons.today, color: Colors.blue)
            : const Icon(Icons.schedule, color: Colors.green),
        onTap: () => onScheduleTap?.call(schedule.id),
      ),
    );
  }

  Color _getPackageColor(String packageName) {
    // Package adından hash ile renk üret
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
    // Bu metod, dayOfWeek bilgisini kullanarak dersin gerçek tarihini hesaplar
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
}
