import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import 'package_selection_widget.dart';
import 'date_time_selection_widget.dart';
import 'instructor_selection_widget.dart';
import 'room_selection_widget.dart';
import 'member_selection_widget.dart';
import 'schedule_generation_widget.dart';

class LessonScheduleFormDialog extends ConsumerStatefulWidget {
  final LessonScheduleWithPackage? schedule;
  final Function(LessonSchedule) onSave;

  const LessonScheduleFormDialog({
    super.key,
    this.schedule,
    required this.onSave,
  });

  @override
  ConsumerState<LessonScheduleFormDialog> createState() =>
      _LessonScheduleFormDialogState();
}

class _LessonScheduleFormDialogState
    extends ConsumerState<LessonScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form state variables
  String? _selectedPackageId;
  DateTime? _startDate;
  List<String> _selectedDays = [];
  String _lessonDuration = '60';
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  bool _useSameTimeForAllDays = true;
  Map<String, TimeOfDay> _dayTimes = {};
  List<String> _selectedInstructorIds = [];
  String? _selectedRoomId;
  List<String> _selectedMemberIds = [];
  String? _selectedGroupId;
  List<Map<String, dynamic>> _generatedSchedules = [];
  List<Map<String, dynamic>> _conflictWarnings = [];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      // Düzenleme modunda mevcut değerleri doldur
      _selectedPackageId = widget.schedule!.packageId;
      _selectedDays = [widget.schedule!.dayOfWeek];
      _startTime = _parseTime(widget.schedule!.startTime);
      _selectedInstructorIds = widget.schedule!.instructorId != null
          ? [widget.schedule!.instructorId!]
          : [];
      _selectedRoomId = widget.schedule!.roomId;
      _selectedMemberIds = widget.schedule!.attendeeIds;

      // Ders süresini hesapla
      final startTime = _parseTime(widget.schedule!.startTime);
      final endTime = _parseTime(widget.schedule!.endTime);
      final duration =
          endTime.hour * 60 +
          endTime.minute -
          (startTime.hour * 60 + startTime.minute);
      _lessonDuration = duration.toString();
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _getDayOfWeek(DateTime date) {
    const daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return daysOfWeek[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      widget.schedule != null
                          ? 'Ders Programını Düzenle'
                          : 'Yeni Ders Programı Oluştur',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 1. Package Selection
                      PackageSelectionWidget(
                        selectedPackageId: _selectedPackageId,
                        onPackageSelected: (packageId) {
                          setState(() {
                            _selectedPackageId = packageId;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // 2. Date and Time Selection
                      DateTimeSelectionWidget(
                        startDate: _startDate,
                        selectedDays: _selectedDays,
                        lessonDuration: _lessonDuration,
                        startTime: _startTime,
                        useSameTimeForAllDays: _useSameTimeForAllDays,
                        dayTimes: _dayTimes,
                        onStartDateChanged: (date) {
                          setState(() {
                            _startDate = date;
                            // Automatically select the day that corresponds to the start date
                            if (date != null) {
                              final dayOfWeek = _getDayOfWeek(date);
                              if (!_selectedDays.contains(dayOfWeek)) {
                                _selectedDays = [dayOfWeek];
                              }
                            }
                          });
                        },
                        onSelectedDaysChanged: (days) {
                          setState(() {
                            _selectedDays = days;
                          });
                        },
                        onLessonDurationChanged: (duration) {
                          setState(() {
                            _lessonDuration = duration;
                          });
                        },
                        onStartTimeChanged: (time) {
                          setState(() {
                            _startTime = time;
                          });
                        },
                        onUseSameTimeChanged: (useSame) {
                          setState(() {
                            _useSameTimeForAllDays = useSame;
                          });
                        },
                        onDayTimesChanged: (dayTimes) {
                          setState(() {
                            _dayTimes = dayTimes;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // 3. Instructor Selection
                      InstructorSelectionWidget(
                        selectedInstructorIds: _selectedInstructorIds,
                        onInstructorIdsChanged: (instructorIds) {
                          setState(() {
                            _selectedInstructorIds = instructorIds;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // 4. Room Selection
                      RoomSelectionWidget(
                        selectedRoomId: _selectedRoomId,
                        onRoomSelected: (roomId) {
                          setState(() {
                            _selectedRoomId = roomId;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // 5. Member Selection
                      MemberSelectionWidget(
                        selectedMemberIds: _selectedMemberIds,
                        selectedGroupId: _selectedGroupId,
                        selectedRoomId: _selectedRoomId,
                        onMemberIdsChanged: (memberIds) {
                          setState(() {
                            _selectedMemberIds = memberIds;
                          });
                        },
                        onGroupSelected: (groupId) {
                          setState(() {
                            _selectedGroupId = groupId;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // 6. Schedule Generation
                      ScheduleGenerationWidget(
                        selectedPackageId: _selectedPackageId,
                        startDate: _startDate,
                        selectedDays: _selectedDays,
                        lessonDuration: _lessonDuration,
                        startTime: _startTime,
                        useSameTimeForAllDays: _useSameTimeForAllDays,
                        dayTimes: _dayTimes,
                        selectedInstructorIds: _selectedInstructorIds,
                        selectedRoomId: _selectedRoomId,
                        selectedMemberIds: _selectedMemberIds,
                        generatedSchedules: _generatedSchedules,
                        conflictWarnings: _conflictWarnings,
                        onSchedulesGenerated: (schedules) {
                          setState(() {
                            _generatedSchedules = schedules;
                          });
                        },
                        onConflictWarningsChanged: (warnings) {
                          setState(() {
                            _conflictWarnings = warnings;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _generatedSchedules.isNotEmpty
                          ? _saveSchedule
                          : null,
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate() &&
        _selectedPackageId != null &&
        _generatedSchedules.isNotEmpty) {
      // Çakışma kontrolü artık ScheduleGenerationWidget'da yapılıyor
      // Burada direkt dersleri oluştur
      _createSchedules();
    }
  }

  void _createSchedules() {
    // Safety check
    if (!mounted) return;

    try {
      // Her ders için ayrı schedule oluştur
      for (int i = 0; i < _generatedSchedules.length; i++) {
        if (!mounted) return; // Check before each iteration

        var scheduleData = _generatedSchedules[i];
        final schedule = LessonSchedule(
          id: '', // Yeni ders için boş ID - backend'de otomatik oluşturulacak
          packageId: _selectedPackageId!,
          instructorId: _selectedInstructorIds.isNotEmpty
              ? _selectedInstructorIds.first
              : null,
          roomId: _selectedRoomId,
          dayOfWeek: scheduleData['dayOfWeek'],
          startTime: _formatTime(scheduleData['startTime']),
          endTime: _formatTime(scheduleData['endTime']),
          attendeeIds: _selectedMemberIds,
          createdAt: DateTime.now(),
          lessonNumber: i + 1, // 1, 2, 3, 4...
          totalLessons: _generatedSchedules.length, // Toplam ders sayısı
          status: LessonStatus.scheduled,
          actualDateDay: scheduleData['date'].day, // Gerçek ders günü
          actualDateMonth: scheduleData['date'].month, // Gerçek ders ayı
          actualDateYear: scheduleData['date'].year, // Gerçek ders yılı
        );

        // Safety check before calling onSave
        if (mounted) {
          widget.onSave(schedule);
        } else {
          return;
        }
      }

      // Safety check before navigation
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
