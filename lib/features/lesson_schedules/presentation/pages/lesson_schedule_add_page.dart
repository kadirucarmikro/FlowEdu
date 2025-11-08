import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../members/data/providers/members_providers.dart'
    as members_providers;
import '../../domain/entities/lesson_schedule.dart';
import '../providers/lesson_schedules_providers.dart';
import '../../data/providers/lesson_schedules_providers.dart' as data;
import '../widgets/package_selection_widget.dart';
import '../widgets/date_time_selection_widget.dart';
import '../widgets/instructor_selection_widget.dart';
import '../widgets/room_selection_widget.dart';
import '../widgets/member_selection_widget.dart';
import '../widgets/schedule_generation_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';

class LessonScheduleAddPage extends ConsumerStatefulWidget {
  const LessonScheduleAddPage({super.key});

  @override
  ConsumerState<LessonScheduleAddPage> createState() =>
      _LessonScheduleAddPageState();
}

class _LessonScheduleAddPageState extends ConsumerState<LessonScheduleAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form state variables
  String? _selectedPackageId;
  DateTime? _startDate;
  List<String> _selectedDays = [];
  Map<String, TimeOfDay> _dayTimes = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  String _lessonDuration = '60';
  bool _useSameTimeForAllDays = true;
  List<String> _selectedInstructorIds = [];
  String? _selectedRoomId;
  List<String> _selectedMemberIds = [];
  String? _selectedGroupId;
  Map<String, double> _memberPrices = {}; // memberId -> price
  List<Map<String, dynamic>> _generatedSchedules = [];
  List<Map<String, dynamic>> _conflictWarnings = [];

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
    // Rol kontrolü - Member rolü ders ekleyemez
    final currentMemberAsync = ref.watch(
      members_providers.currentMemberProvider,
    );

    return currentMemberAsync.when(
      data: (member) {
        if (member == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Member rolü kontrolü - sadece admin ve instructor ders ekleyebilir
        if (member.roleName == 'Member') {
          return Scaffold(
            appBar: AppBar(
              leading: const AppBarLogo(),
              title: const Text('Erişim Engellendi'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.mounted) {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/lesson-schedules');
                      }
                    }
                  },
                  tooltip: 'Geri',
                ),
              ],
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Bu işlem için yetkiniz bulunmamaktadır.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ders programı oluşturmak için admin veya instructor rolü gereklidir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildMainContent();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: const AppBarLogo(),
          title: const Text('Hata'),
        ),
        body: Center(child: Text('Hata: $error')),
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Yeni Ders Programı Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.mounted) {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/lesson-schedules');
                }
              }
            },
            tooltip: 'Geri',
          ),
          if (_generatedSchedules.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _saveSchedules,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600 ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.blue,
                    size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 600 ? 6 : 8,
                  ),
                  Expanded(
                    child: Text(
                      'Yeni Ders Programı Oluştur',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? 16
                            : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final double formWidth = isMobile
                      ? constraints.maxWidth
                      : 800;

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formWidth),
                        child: Column(
                          children: [
                            // Paket Seçimi
                            PackageSelectionWidget(
                              selectedPackageId: _selectedPackageId,
                              onPackageSelected: (packageId) {
                                setState(() {
                                  _selectedPackageId = packageId;
                                });
                              },
                            ),

                            SizedBox(height: isMobile ? 16 : 24),

                            // Tarih ve Saat Seçimi
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

                            SizedBox(height: isMobile ? 16 : 24),

                            // Eğitmen Seçimi
                            InstructorSelectionWidget(
                              selectedInstructorIds: _selectedInstructorIds,
                              onInstructorIdsChanged: (instructorIds) {
                                setState(() {
                                  _selectedInstructorIds = instructorIds;
                                });
                              },
                            ),

                            SizedBox(height: isMobile ? 16 : 24),

                            // Oda Seçimi
                            RoomSelectionWidget(
                              selectedRoomId: _selectedRoomId,
                              onRoomSelected: (roomId) {
                                setState(() {
                                  _selectedRoomId = roomId;
                                });
                              },
                            ),

                            SizedBox(height: isMobile ? 16 : 24),

                            // Üye Seçimi
                            MemberSelectionWidget(
                              selectedMemberIds: _selectedMemberIds,
                              selectedGroupId: _selectedGroupId,
                              selectedRoomId: _selectedRoomId,
                              selectedPackageId: _selectedPackageId,
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
                              onMemberPricesChanged: (memberPrices) {
                                setState(() {
                                  _memberPrices = memberPrices;
                                });
                              },
                            ),

                            SizedBox(height: isMobile ? 16 : 24),

                            // Program Oluşturma
                            if (_selectedPackageId != null &&
                                _startDate != null &&
                                _selectedDays.isNotEmpty &&
                                _selectedInstructorIds.isNotEmpty &&
                                _selectedRoomId != null)
                              ScheduleGenerationWidget(
                                selectedPackageId: _selectedPackageId!,
                                startDate: _startDate!,
                                selectedDays: _selectedDays,
                                lessonDuration: _lessonDuration,
                                startTime: _startTime,
                                useSameTimeForAllDays: _useSameTimeForAllDays,
                                dayTimes: _dayTimes,
                                selectedInstructorIds: _selectedInstructorIds,
                                selectedRoomId: _selectedRoomId!,
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
                  );
                },
              ),
            ),

            // Bottom buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final double formWidth = isMobile ? constraints.maxWidth : 800;

                return Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formWidth),
                      child: isMobile
                          ? // Mobile: Stacked buttons
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _generatedSchedules.isNotEmpty &&
                                            !_isLoading
                                        ? _saveSchedules
                                        : null,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Kaydet'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      if (context.mounted) {
                                        if (GoRouter.of(context).canPop()) {
                                          context.pop();
                                        } else {
                                          context.go('/lesson-schedules');
                                        }
                                      }
                                    },
                                    child: const Text('İptal'),
                                  ),
                                ),
                              ],
                            )
                          : // Desktop/Tablet: Side by side buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (context.mounted) {
                                      if (GoRouter.of(context).canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/lesson-schedules');
                                      }
                                    }
                                  },
                                  child: const Text('İptal'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      _generatedSchedules.isNotEmpty &&
                                          !_isLoading
                                      ? _saveSchedules
                                      : null,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Kaydet'),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSchedules() async {
    if (_formKey.currentState!.validate() &&
        _selectedPackageId != null &&
        _generatedSchedules.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final createLessonSchedule = ref.read(createLessonScheduleProvider);

        // Her ders için ayrı schedule oluştur (orijinal form mantığı)
        for (int i = 0; i < _generatedSchedules.length; i++) {
          var scheduleData = _generatedSchedules[i];
          final schedule = LessonSchedule(
            id: '',
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

          final createdSchedule = await createLessonSchedule(schedule);

          // Üyeleri lesson_attendees tablosuna kaydet (fiyatlarla birlikte)
          if (_selectedMemberIds.isNotEmpty) {
            final repository = ref.read(data.lessonSchedulesRepositoryProvider);
            await repository.assignMembersToSchedule(
              createdSchedule.id,
              _selectedMemberIds,
              memberPrices: _memberPrices,
            );
          }

          // Eğitmenleri lesson_attendees tablosuna kaydet
          if (_selectedInstructorIds.isNotEmpty) {
            final repository = ref.read(data.lessonSchedulesRepositoryProvider);
            await repository.assignMembersToSchedule(
              createdSchedule.id,
              _selectedInstructorIds,
            );
          }
        }

        // Provider'ları yenile
        ref.invalidate(lessonSchedulesWithPackagesProvider);

        if (context.mounted) {
          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ders programı başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
            ),
          );

          // Lesson schedules sayfasına yönlendir
          context.go('/lesson-schedules');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog('Hata: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showErrorDialog(
        'Lütfen tüm gerekli alanları doldurun ve ders programını oluşturun.',
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
