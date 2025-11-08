import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payments/presentation/providers/payments_providers.dart';
import '../../data/providers/lesson_schedules_providers.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class ScheduleGenerationWidget extends ConsumerWidget {
  final String? selectedPackageId;
  final DateTime? startDate;
  final List<String> selectedDays;
  final String lessonDuration;
  final TimeOfDay startTime;
  final bool useSameTimeForAllDays;
  final Map<String, TimeOfDay> dayTimes;
  final List<String> selectedInstructorIds;
  final String? selectedRoomId;
  final List<String> selectedMemberIds;
  final List<Map<String, dynamic>> generatedSchedules;
  final List<Map<String, dynamic>> conflictWarnings;
  final Function(List<Map<String, dynamic>>) onSchedulesGenerated;
  final Function(List<Map<String, dynamic>>) onConflictWarningsChanged;

  const ScheduleGenerationWidget({
    super.key,
    required this.selectedPackageId,
    required this.startDate,
    required this.selectedDays,
    required this.lessonDuration,
    required this.startTime,
    required this.useSameTimeForAllDays,
    required this.dayTimes,
    required this.selectedInstructorIds,
    required this.selectedRoomId,
    required this.selectedMemberIds,
    required this.generatedSchedules,
    required this.conflictWarnings,
    required this.onSchedulesGenerated,
    required this.onConflictWarningsChanged,
  });

  static const List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _dayLabels = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  TimeOfDay _getSelectedTimeForDay(String day) {
    if (useSameTimeForAllDays) {
      return startTime;
    } else {
      return dayTimes[day] ?? startTime;
    }
  }

  DateTime _calculateLessonTime(DateTime lessonDate, TimeOfDay selectedTime) {
    return DateTime(
      lessonDate.year,
      lessonDate.month,
      lessonDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  DateTime _calculateEndTime(DateTime lessonTime) {
    return lessonTime.add(Duration(minutes: int.parse(lessonDuration)));
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Pazartesi'yi haftanın başlangıcı olarak kabul et
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSchedules(BuildContext context, WidgetRef ref) async {
    if (selectedPackageId == null ||
        startDate == null ||
        selectedDays.isEmpty ||
        selectedInstructorIds.isEmpty ||
        selectedRoomId == null) {
      _showErrorDialog(
        context,
        'Lütfen tüm alanları doldurun: paket, tarih, günler, eğitmen ve oda seçimi zorunludur.',
      );
      return;
    }

    List<Map<String, dynamic>> newSchedules = [];
    List<Map<String, dynamic>> newConflictWarnings = [];

    int lessonCount = 0;
    int totalLessons = 0;

    // Get lesson count from selected package
    final packagesAsync = ref.read(lessonPackagesProvider);
    packagesAsync.when(
      data: (packages) {
        final selectedPackage = packages.firstWhere(
          (p) => p.id == selectedPackageId,
        );
        totalLessons = selectedPackage.lessonCount;
      },
      loading: () {},
      error: (_, __) {},
    );

    // Generate schedules
    int dayIndex = 0;
    DateTime workingDate = startDate!;

    while (lessonCount < totalLessons) {
      // Seçilen günlerin sırasına göre döngü
      String day = selectedDays[dayIndex % selectedDays.length];

      // Mevcut haftanın başlangıcını bul (Pazartesi)
      DateTime weekStart = _getStartOfWeek(workingDate);

      // Seçilen günün hafta içindeki sırasını bul
      int dayOfWeekIndex = _daysOfWeek.indexOf(day);
      DateTime lessonDate = weekStart.add(Duration(days: dayOfWeekIndex));

      // Eğer hesaplanan tarih başlangıç tarihinden önceyse, bir sonraki haftaya geç
      if (lessonDate.isBefore(startDate!)) {
        lessonDate = lessonDate.add(Duration(days: 7));
      }

      final selectedTime = _getSelectedTimeForDay(day);
      final lessonTime = _calculateLessonTime(lessonDate, selectedTime);
      final endTime = _calculateEndTime(lessonTime);

      newSchedules.add({
        'lessonNumber': lessonCount + 1,
        'totalLessons': totalLessons,
        'dayOfWeek': day,
        'dayLabel': _dayLabels[dayOfWeekIndex],
        'date': lessonDate,
        'startTime': lessonTime,
        'endTime': endTime,
        'duration': int.parse(lessonDuration),
        'instructorIds': List<String>.from(selectedInstructorIds),
        'roomId': selectedRoomId,
        'attendeeIds': List<String>.from(selectedMemberIds),
      });

      lessonCount++;
      dayIndex++;

      // Bir sonraki ders için tarihi güncelle
      if (dayIndex % selectedDays.length == 0) {
        // Tüm günler tamamlandı, bir sonraki haftaya geç
        workingDate = workingDate.add(Duration(days: 7));
      }
    }

    // Çakışma kontrolü yap
    await _checkConflicts(context, ref, newSchedules);

    onSchedulesGenerated(newSchedules);
    onConflictWarningsChanged(newConflictWarnings);
  }

  Future<void> _checkConflicts(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> schedules,
  ) async {
    // Repository'yi al
    final repository = ref.read(lessonSchedulesRepositoryProvider);
    final conflicts = <String>[];

    for (int i = 0; i < schedules.length; i++) {
      var scheduleData = schedules[i];
      final startDateTime = scheduleData['startTime'] as DateTime;
      final endDateTime = scheduleData['endTime'] as DateTime;

      final validation = await repository.validateLessonSchedule(
        roomId: selectedRoomId!,
        startTime: startDateTime,
        endTime: endDateTime,
        instructorIds: selectedInstructorIds,
        memberIds: selectedMemberIds,
        excludeScheduleId: null, // Yeni ders oluşturma
      );

      if (!validation['isValid']) {
        if (validation['errorType'] == 'lesson_conflict') {
          conflicts.add(validation['message']);
        } else if (validation['errorType'] == 'member_conflict') {
          final dateStr =
              '${scheduleData['date'].day}/${scheduleData['date'].month}/${scheduleData['date'].year}';
          final timeStr =
              '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
          conflicts.add('$dateStr $timeStr: ${validation['message']}');
        }
      }
    }

    // Çakışma varsa kullanıcıya göster
    if (conflicts.isNotEmpty) {
      if (context.mounted) {
        try {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('⚠️ Uyarı'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Girilen bilgilerle eşleşen bir ders programı zaten bulunmaktadır.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lütfen farklı bir tarih, saat veya oda bilgisi seçiniz.',
                  ),
                  const SizedBox(height: 16),
                  ...conflicts.map(
                    (conflict) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        conflict,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        } catch (e) {
          // Error handling
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Generate Schedule Button
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _generateSchedules(context, ref),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ders Programını Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Generated Schedule List
        if (generatedSchedules.isNotEmpty) ...[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Oluşturulan Ders Programı (${generatedSchedules.length} ders)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: ResponsiveGridList<Map<String, dynamic>>(
                      items: generatedSchedules,
                      itemBuilder: (context, schedule, index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        '${schedule['lessonNumber']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${schedule['lessonNumber']}/${schedule['totalLessons']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        schedule['dayLabel'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${_formatDate(schedule['date'])}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${_formatTime(schedule['startTime'])} - ${_formatTime(schedule['endTime'])}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (schedule['instructorIds'] != null &&
                                    (schedule['instructorIds'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${(schedule['instructorIds'] as List).length} eğitmen',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      aspectRatio: 1.2,
                      maxColumns: 4,
                      padding: const EdgeInsets.all(8),
                      emptyWidget: const Center(
                        child: Text('Henüz ders programı oluşturulmadı'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
