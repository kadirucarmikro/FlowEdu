import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../providers/lesson_schedules_providers.dart';
import '../utils/schedule_grouping.dart';
import '../widgets/lesson_schedule_filters_widget.dart';
import '../widgets/date_grouped_list.dart';
import '../widgets/package_grouped_list.dart';
import '../../../../core/utils/date_time_helpers.dart';

enum GroupingType { date, package, instructor, room, none }

class LessonScheduleListView extends ConsumerStatefulWidget {
  final bool isAdmin;
  final Function(String scheduleId)? onScheduleTap;
  final Function(dynamic schedule)? onScheduleEdit;

  const LessonScheduleListView({
    super.key,
    required this.isAdmin,
    this.onScheduleTap,
    this.onScheduleEdit,
  });

  @override
  ConsumerState<LessonScheduleListView> createState() =>
      _LessonScheduleListViewState();
}

class _LessonScheduleListViewState
    extends ConsumerState<LessonScheduleListView> {
  LessonScheduleFilters _filters = LessonScheduleFilters();
  GroupingType _groupingType = GroupingType.date;

  List<LessonScheduleWithPackage> _filterSchedules(
    List<LessonScheduleWithPackage> schedules,
  ) {
    return schedules.where((schedule) {
      // Paket filtresi
      if (_filters.packageId != null &&
          schedule.packageId != _filters.packageId) {
        return false;
      }

      // Başlangıç tarihi filtresi
      if (_filters.startDate != null) {
        final scheduleDate = _getScheduleDate(schedule);
        final filterDate = DateTime(
          _filters.startDate!.year,
          _filters.startDate!.month,
          _filters.startDate!.day,
        );
        final scheduleDay = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
        );
        if (scheduleDay.isBefore(filterDate)) {
          return false;
        }
      }

      // Haftalık ders günleri filtresi
      if (_filters.selectedDays.isNotEmpty &&
          !_filters.selectedDays.contains(schedule.dayOfWeek)) {
        return false;
      }

      // Ders süresi filtresi
      if (_filters.lessonDuration != null) {
        final duration = _calculateDuration(
          schedule.startTime,
          schedule.endTime,
        );
        if (duration != _filters.lessonDuration) {
          return false;
        }
      }

      // Eğitmen filtresi
      if (_filters.instructorId != null &&
          schedule.instructorId != _filters.instructorId) {
        return false;
      }

      // Oda filtresi
      if (_filters.roomId != null && schedule.roomId != _filters.roomId) {
        return false;
      }

      // Üye filtresi
      if (_filters.memberId != null &&
          !schedule.attendeeIds.contains(_filters.memberId)) {
        return false;
      }

      // Grup filtresi
      if (_filters.groupId != null) {
        // Bu filtreyi uygulamak için member bilgilerine ihtiyacımız var
        // Şimdilik basit bir kontrol yapıyoruz
        // Daha detaylı kontrol için member bilgilerini schedule'dan almak gerekir
      }

      return true;
    }).toList();
  }

  int _calculateDuration(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      if (startParts.length >= 2 && endParts.length >= 2) {
        final startMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        return endMinutes - startMinutes;
      }
    } catch (e) {
      // Hata durumunda 0 döndür
    }
    return 0;
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

  Map<String, List<LessonScheduleWithPackage>> _groupSchedules(
    List<LessonScheduleWithPackage> schedules,
  ) {
    switch (_groupingType) {
      case GroupingType.date:
        return ScheduleGrouping.groupByDate(schedules);
      case GroupingType.package:
        return ScheduleGrouping.groupByPackage(schedules);
      case GroupingType.instructor:
        return _groupByInstructorWithName(schedules);
      case GroupingType.room:
        return _groupByRoomWithName(schedules);
      case GroupingType.none:
        return {'Tüm Dersler': schedules};
    }
  }

  Map<String, List<LessonScheduleWithPackage>> _groupByInstructorWithName(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final instructorName = schedule.instructorName ?? 'Eğitmen Atanmamış';
      if (!grouped.containsKey(instructorName)) {
        grouped[instructorName] = [];
      }
      grouped[instructorName]!.add(schedule);
    }

    return grouped;
  }

  Map<String, List<LessonScheduleWithPackage>> _groupByRoomWithName(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final roomName = schedule.roomName ?? 'Oda Atanmamış';
      if (!grouped.containsKey(roomName)) {
        grouped[roomName] = [];
      }
      grouped[roomName]!.add(schedule);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    // Member için sadece kendi derslerini göster, Admin için tüm dersleri göster
    final schedulesAsync = widget.isAdmin
        ? ref.watch(lessonSchedulesWithPackagesProvider)
        : ref.watch(currentMemberSchedulesProvider);

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.isAdmin) {
                  ref.invalidate(lessonSchedulesWithPackagesProvider);
                } else {
                  ref.invalidate(currentMemberSchedulesProvider);
                }
              },
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
      data: (allSchedules) {
        final filteredSchedules = _filterSchedules(allSchedules);
        final groupedSchedules = _groupSchedules(filteredSchedules);

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Column(
                children: [
                  // Gruplama seçeneği
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.view_list, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Gruplama:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildGroupingChip(
                                  'Tarih',
                                  GroupingType.date,
                                  Icons.calendar_today,
                                ),
                                const SizedBox(width: 8),
                                _buildGroupingChip(
                                  'Paket',
                                  GroupingType.package,
                                  Icons.school,
                                ),
                                const SizedBox(width: 8),
                                _buildGroupingChip(
                                  'Eğitmen',
                                  GroupingType.instructor,
                                  Icons.person,
                                ),
                                const SizedBox(width: 8),
                                _buildGroupingChip(
                                  'Oda',
                                  GroupingType.room,
                                  Icons.meeting_room,
                                ),
                                const SizedBox(width: 8),
                                _buildGroupingChip(
                                  'Liste',
                                  GroupingType.none,
                                  Icons.list,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filtreler - Sadece Admin için göster
                  if (widget.isAdmin)
                    LessonScheduleFiltersWidget(
                      filters: _filters,
                      onFiltersChanged: (filters) {
                        setState(() {
                          _filters = filters;
                        });
                      },
                    ),

                  // Sonuç sayısı
                  if (filteredSchedules.length != allSchedules.length)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.blue.withOpacity(0.1),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${filteredSchedules.length} ders bulundu (Toplam: ${allSchedules.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Liste görünümü - Ortalanmış
                  Expanded(
                    child: filteredSchedules.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.isAdmin
                                      ? (_filters.hasActiveFilters
                                            ? 'Filtrelere uygun ders bulunamadı'
                                            : 'Henüz ders programı oluşturulmamış')
                                      : 'Henüz size atanmış bir ders programı bulunmuyor',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (widget.isAdmin &&
                                    _filters.hasActiveFilters) ...[
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _filters.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Filtreleri Temizle'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth > 1200
                                    ? 1200
                                    : constraints.maxWidth,
                              ),
                              child: _groupingType == GroupingType.date
                                  ? DateGroupedList(
                                      groupedSchedules: groupedSchedules,
                                      onRefresh: () async {
                                        if (widget.isAdmin) {
                                          ref.invalidate(
                                            lessonSchedulesWithPackagesProvider,
                                          );
                                        } else {
                                          ref.invalidate(
                                            currentMemberSchedulesProvider,
                                          );
                                        }
                                      },
                                      onScheduleTap: widget.onScheduleTap,
                                    )
                                  : _groupingType == GroupingType.package
                                  ? PackageGroupedList(
                                      groupedSchedules: groupedSchedules,
                                      onRefresh: () async {
                                        if (widget.isAdmin) {
                                          ref.invalidate(
                                            lessonSchedulesWithPackagesProvider,
                                          );
                                        } else {
                                          ref.invalidate(
                                            currentMemberSchedulesProvider,
                                          );
                                        }
                                      },
                                      onScheduleTap: widget.onScheduleTap,
                                    )
                                  : _buildCustomGroupedList(groupedSchedules),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupingChip(String label, GroupingType type, IconData icon) {
    final isSelected = _groupingType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _groupingType = type;
          });
        }
      },
    );
  }

  Widget _buildCustomGroupedList(
    Map<String, List<LessonScheduleWithPackage>> groupedSchedules,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.isAdmin) {
          ref.invalidate(lessonSchedulesWithPackagesProvider);
        } else {
          ref.invalidate(currentMemberSchedulesProvider);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedSchedules.length,
        itemBuilder: (context, index) {
          final groupName = groupedSchedules.keys.elementAt(index);
          final schedules = groupedSchedules[groupName]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getGroupColor(groupName),
                child: Icon(_getGroupIcon(_groupingType), color: Colors.white),
              ),
              title: Text(
                groupName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${schedules.length} ders'),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: schedules
                        .map((schedule) => _buildScheduleItem(schedule))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleItem(LessonScheduleWithPackage schedule) {
    final scheduleDate = _getScheduleDate(schedule);
    final isPast = scheduleDate.isBefore(DateTime.now());
    final isToday = _isToday(scheduleDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isPast
          ? Colors.grey.withOpacity(0.1)
          : isToday
          ? Colors.blue.withOpacity(0.1)
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
            if (widget.isAdmin)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => widget.onScheduleEdit?.call(schedule),
                tooltip: 'Düzenle',
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => widget.onScheduleTap?.call(schedule.id),
      ),
    );
  }

  Color _getGroupColor(String groupName) {
    final hash = groupName.hashCode;
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

  IconData _getGroupIcon(GroupingType type) {
    switch (type) {
      case GroupingType.instructor:
        return Icons.person;
      case GroupingType.room:
        return Icons.meeting_room;
      default:
        return Icons.list;
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
