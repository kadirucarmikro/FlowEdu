import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/entities/lesson_schedule.dart';
import '../providers/lesson_schedules_providers.dart';
import 'lesson_detail_popup.dart';
import '../../../members/data/providers/members_providers.dart'
    as members_providers;

class WeeklyCalendarView extends ConsumerStatefulWidget {
  final bool isAdmin;
  final Function(String scheduleId)? onScheduleTap;
  final Function(dynamic schedule)? onScheduleEdit;

  const WeeklyCalendarView({
    super.key,
    required this.isAdmin,
    this.onScheduleTap,
    this.onScheduleEdit,
  });

  @override
  ConsumerState<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends ConsumerState<WeeklyCalendarView> {
  late DateTime _currentWeek;

  // Paket renk paleti - her paket için farklı renk
  final List<Color> _packageColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
    Colors.pink.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
  ];

  @override
  void initState() {
    super.initState();
    // Haftanın başlangıcını (Pazartesi) al
    _currentWeek = _getStartOfWeek(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hafta Navigasyonu
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeek = _currentWeek.subtract(
                      const Duration(days: 7),
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _getWeekRangeText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Cache'i temizle ve verileri yenile
                  ref.invalidate(lessonSchedulesWithPackagesProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Takvim yenilendi'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Takvimi Yenile',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeek = _currentWeek.add(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Haftalık Takvim
        Expanded(child: _buildWeeklyCalendar()),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    final schedulesAsync = ref.watch(lessonSchedulesWithPackagesProvider);

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
      data: (schedules) => _buildCalendarGrid(schedules),
    );
  }

  Widget _buildCalendarGrid(List<LessonScheduleWithPackage> schedules) {
    final weekDays = _getWeekDays();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gün başlıkları
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color: _isToday(day)
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayName(day.weekday),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _isToday(day)
                                  ? Colors.blue.shade700
                                  : Colors.black,
                            ),
                          ),
                          Text(
                            '${day.day}/${day.month}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: _isToday(day)
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          // Saat dilimleri
          Expanded(
            child: Row(
              children: weekDays
                  .map(
                    (day) => Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _buildDayColumn(day, schedules),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    DateTime day,
    List<LessonScheduleWithPackage> schedules,
  ) {
    final currentMemberAsync = ref.watch(
      members_providers.currentMemberProvider,
    );

    final daySchedules = currentMemberAsync.when(
      data: (member) {
        return schedules.where((schedule) {
          bool dateMatches = false;
          if (schedule.actualDateDay != null &&
              schedule.actualDateMonth != null &&
              schedule.actualDateYear != null) {
            dateMatches =
                schedule.actualDateDay == day.day &&
                schedule.actualDateMonth == day.month &&
                schedule.actualDateYear == day.year;
          } else {
            return false;
          }

          if (!dateMatches) return false;

          if (member?.roleName == 'Member') {
            final isAttendee = schedule.attendeeIds.contains(member?.id);
            return isAttendee;
          }

          return true;
        }).toList();
      },
      loading: () => <LessonScheduleWithPackage>[],
      error: (error, stack) => <LessonScheduleWithPackage>[],
    );

    // Saat dilimlerini oluştur (08:00 - 22:00)
    final timeSlots = <Widget>[];
    for (int hour = 8; hour <= 22; hour++) {
      final timeSlot = _buildTimeSlot(hour, daySchedules);
      timeSlots.add(timeSlot);
    }

    return SingleChildScrollView(child: Column(children: timeSlots));
  }

  Widget _buildTimeSlot(
    int hour,
    List<LessonScheduleWithPackage> daySchedules,
  ) {
    final timeString = '${hour.toString().padLeft(2, '0')}:00';

    final matchingSchedules = daySchedules.where((schedule) {
      return schedule.startTime.startsWith(timeString);
    }).toList();

    // Member filtrelemesi artık _buildDayColumn'da yapılıyor
    final filteredSchedules = matchingSchedules;

    // Eğer eşleşen ders yoksa, boş saat dilimi göster
    if (filteredSchedules.isEmpty) {
      return Container(
        height: 70,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            timeString,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    // Eşleşen dersleri göster
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView.builder(
        itemCount: filteredSchedules.length,
        itemBuilder: (context, index) {
          final schedule = filteredSchedules[index];
          return InkWell(
            onTap: () => _showLessonDetailPopup(context, schedule),
            onLongPress: widget.isAdmin
                ? () => widget.onScheduleEdit?.call(schedule)
                : null,
            child: Container(
              margin: const EdgeInsets.all(1),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getLessonColor(schedule),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getLessonBorderColor(schedule)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getLessonDisplayText(schedule),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Ders durumu ikonu
                      _getStatusIcon(schedule),
                    ],
                  ),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: const TextStyle(fontSize: 7, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getAllInstructorInitials(schedule),
                    style: const TextStyle(fontSize: 7, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (index) => _currentWeek.add(Duration(days: index)));
  }

  String _getWeekRangeText() {
    final weekDays = _getWeekDays();
    final start = weekDays.first;
    final end = weekDays.last;
    return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Pazartesi'yi haftanın başlangıcı olarak kabul et
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getLessonDisplayText(LessonScheduleWithPackage schedule) {
    // Yeni format: X/Y - Z Derslik Paket
    return '${schedule.lessonNumber ?? 1}/${schedule.packageLessonCount} - ${schedule.packageLessonCount} Derslik Paket';
  }

  String _getAllInstructorInitials(LessonScheduleWithPackage schedule) {
    final Set<String> uniqueInitials =
        {}; // Benzersiz baş harfleri tutmak için Set kullanıyoruz

    // Katılımcı eğitmenler
    for (final instructor in schedule.attendeeInstructors) {
      final firstName = instructor['first_name'] as String? ?? '';
      final lastName = instructor['last_name'] as String? ?? '';
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        uniqueInitials.add(_getInstructorInitials('$firstName $lastName'));
      }
    }

    return uniqueInitials.join(', '); // Benzersiz baş harflerini birleştir
  }

  String _getInstructorInitials(String instructorName) {
    // Eğitmen adını parçalara ayır
    final nameParts = instructorName.trim().split(' ');
    if (nameParts.length >= 2) {
      // İlk ismin ilk harfi + Soyadın ilk harfi
      final firstName = nameParts[0];
      final lastName = nameParts[nameParts.length - 1];
      return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
    } else if (nameParts.length == 1) {
      // Sadece bir isim varsa, ilk iki harfi al
      final name = nameParts[0];
      if (name.length >= 2) {
        return name.substring(0, 2).toUpperCase();
      } else {
        return name.toUpperCase();
      }
    }
    return instructorName;
  }

  Color _getLessonColor(LessonScheduleWithPackage schedule) {
    final startTime = schedule.startTime;
    final hash = startTime.hashCode;
    final colorIndex = hash.abs() % _packageColors.length;
    return _packageColors[colorIndex];
  }

  Color _getLessonBorderColor(LessonScheduleWithPackage schedule) {
    // Paket renginin daha koyu tonu
    final packageColor = _getLessonColor(schedule);
    return packageColor.withOpacity(0.7);
  }

  void _showLessonDetailPopup(
    BuildContext context,
    LessonScheduleWithPackage schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => LessonDetailPopup(schedule: schedule),
    );
  }

  // Ders durumu ikonunu döndür
  Widget _getStatusIcon(LessonScheduleWithPackage schedule) {
    switch (schedule.status) {
      case LessonStatus.completed:
        return const Icon(Icons.check_circle, size: 12, color: Colors.green);
      case LessonStatus.missed:
        return const Icon(Icons.cancel, size: 12, color: Colors.red);
      case LessonStatus.rescheduled:
        return const Icon(Icons.schedule, size: 12, color: Colors.orange);
      case LessonStatus.scheduled:
        return const Icon(
          Icons.radio_button_unchecked,
          size: 12,
          color: Colors.grey,
        );
    }
  }
}
