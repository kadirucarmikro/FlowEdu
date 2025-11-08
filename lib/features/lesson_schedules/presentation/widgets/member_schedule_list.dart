import 'package:flutter/material.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';

class MemberScheduleList extends StatelessWidget {
  final List<LessonScheduleWithPackage> schedules;

  const MemberScheduleList({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Günlere göre grupla
    final Map<String, List<LessonScheduleWithPackage>> groupedSchedules = {};

    for (final schedule in schedules) {
      final day = schedule.dayOfWeek;
      if (!groupedSchedules.containsKey(day)) {
        groupedSchedules[day] = [];
      }
      groupedSchedules[day]!.add(schedule);
    }

    // Her günün derslerini saat sırasına göre sırala
    for (final day in groupedSchedules.keys) {
      groupedSchedules[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    // Haftanın günleri sırası
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
            child: Text(
              'Ders Programım',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Günlere göre dersler
          Expanded(
            child: ListView.builder(
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final daySchedules = groupedSchedules[day] ?? [];

                if (daySchedules.isEmpty) return const SizedBox.shrink();

                return _buildDaySection(
                  context,
                  day,
                  daySchedules,
                  isMobile: isMobile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    String day,
    List<LessonScheduleWithPackage> daySchedules, {
    required bool isMobile,
  }) {
    final dayLabel = _getDayLabel(day);
    final dayColor = _getDayColor(day);

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gün başlığı
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 10 : 12,
              horizontal: isMobile ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: dayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: dayColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: dayColor,
                  size: isMobile ? 16 : 18,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dayColor,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${daySchedules.length} ders',
                  style: TextStyle(
                    color: dayColor.withOpacity(0.8),
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // O güne ait dersler
          ...daySchedules.map(
            (schedule) => Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 8 : 10),
              child: _buildMemberScheduleCard(
                context,
                schedule,
                isMobile: isMobile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberScheduleCard(
    BuildContext context,
    LessonScheduleWithPackage schedule, {
    required bool isMobile,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // Saat bilgisi
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    schedule.startTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                  Text(
                    'başlangıç',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: isMobile ? 9 : 10,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Ders bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.packageName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isMobile ? 4 : 6),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isMobile ? 4 : 6),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Durum göstergesi
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(String dayOfWeek) {
    switch (dayOfWeek) {
      case 'Monday':
        return 'Pazartesi';
      case 'Tuesday':
        return 'Salı';
      case 'Wednesday':
        return 'Çarşamba';
      case 'Thursday':
        return 'Perşembe';
      case 'Friday':
        return 'Cuma';
      case 'Saturday':
        return 'Cumartesi';
      case 'Sunday':
        return 'Pazar';
      default:
        return dayOfWeek;
    }
  }

  Color _getDayColor(String dayOfWeek) {
    switch (dayOfWeek) {
      case 'Monday':
        return Colors.red;
      case 'Tuesday':
        return Colors.orange;
      case 'Wednesday':
        return Colors.yellow[700]!;
      case 'Thursday':
        return Colors.green;
      case 'Friday':
        return Colors.blue;
      case 'Saturday':
        return Colors.purple;
      case 'Sunday':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
