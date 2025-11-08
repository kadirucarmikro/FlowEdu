import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../members/data/providers/members_providers.dart'
    as members_providers;
import '../../domain/entities/lesson_schedule.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../providers/lesson_schedules_providers.dart';
import '../../data/providers/lesson_schedules_providers.dart' as data;
import '../widgets/package_selection_widget.dart';
import '../widgets/date_time_selection_widget.dart';
import '../widgets/instructor_selection_widget.dart';
import '../widgets/room_selection_widget.dart';
import '../widgets/member_selection_widget.dart';
import '../widgets/schedule_generation_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';

class LessonScheduleUpdatePage extends ConsumerStatefulWidget {
  final String scheduleId;

  const LessonScheduleUpdatePage({super.key, required this.scheduleId});

  @override
  ConsumerState<LessonScheduleUpdatePage> createState() =>
      _LessonScheduleUpdatePageState();
}

class _LessonScheduleUpdatePageState
    extends ConsumerState<LessonScheduleUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitialized = false;

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
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Mevcut ders programını yükle
      final schedule = await ref.read(
        lessonScheduleDetailProvider(widget.scheduleId).future,
      );

      await _populateFormWithScheduleData(schedule);
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ders programı yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _populateFormWithScheduleData(
    LessonScheduleWithPackage schedule,
  ) async {
    _selectedPackageId = schedule.packageId;
    _selectedRoomId = schedule.roomId;
    _selectedInstructorIds = schedule.instructorId != null
        ? [schedule.instructorId!]
        : [];
    _selectedMemberIds = schedule.attendeeIds;

    // Tarih ve saat bilgilerini ayarla
    _startDate = DateTime(
      schedule.actualDateYear ?? DateTime.now().year,
      schedule.actualDateMonth ?? DateTime.now().month,
      schedule.actualDateDay ?? DateTime.now().day,
    );

    // Başlangıç saatini parse et
    final startTimeParts = schedule.startTime.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );

    // Ders süresini hesapla
    final endTimeParts = schedule.endTime.split(':');
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes =
        int.parse(endTimeParts[0]) * 60 + int.parse(endTimeParts[1]);
    _lessonDuration = (endMinutes - startMinutes).toString();

    // Aynı paket ID'sine sahip tüm derslerin günlerini bul
    await _loadAllDaysForPackage(schedule.packageId);

    // Aynı saat kullanımını ayarla
    _useSameTimeForAllDays = true;
  }

  /// SQL query'deki WHERE şartlarına göre benzersiz hafta günlerini getir
  /// SELECT DISTINCT day_of_week FROM lesson_schedules WHERE package_id=? AND room_id=? AND total_lessons=? AND lesson_number IN (1,2,3,4,5,6,7,8) AND attendee_ids = ?
  ///
  /// Örnek kullanım:
  /// ```dart
  /// final uniqueDays = await _getUniqueDaysForLesson(
  ///   'b78a36a4-a0f1-4a3e-87ae-1ffef54ccbc4', // package_id
  ///   '5808c5b0-6cae-40e8-8dfb-b5f5e032f67e', // room_id
  ///   8, // total_lessons
  ///   ['dbeef779-fd3e-4d22-b31f-73fd53a15c6a', 'b3a27403-88e6-44bb-96e8-588fe11ec687'], // attendee_ids
  /// );
  /// ```
  Future<List<String>> _getUniqueDaysForLesson(
    String packageId,
    String? roomId,
    int? totalLessons,
    List<String> attendeeIds,
  ) async {
    try {
      final allSchedules = await ref.read(
        lessonSchedulesWithPackagesProvider.future,
      );

      // SQL query'deki WHERE şartlarına göre filtrele
      final filteredSchedules = allSchedules.where((s) {
        // package_id kontrolü
        if (s.packageId != packageId) return false;

        // room_id kontrolü
        if (roomId != null && s.roomId != roomId) return false;

        // total_lessons kontrolü (packageLessonCount kullan)
        if (totalLessons != null && s.packageLessonCount != totalLessons) {
          return false;
        }

        // lesson_number kontrolü (1'den totalLessons'a kadar dinamik)
        if (s.lessonNumber != null &&
            totalLessons != null &&
            (s.lessonNumber! < 1 || s.lessonNumber! > totalLessons)) {
          return false;
        }

        // attendee_ids kontrolü
        if (attendeeIds.isNotEmpty) {
          final attendeeIdsSet = attendeeIds.toSet();
          final scheduleAttendeeIds = s.attendeeIds.toSet();
          if (!attendeeIdsSet.containsAll(scheduleAttendeeIds) ||
              !scheduleAttendeeIds.containsAll(attendeeIdsSet)) {
            return false;
          }
        }

        return true;
      }).toList();

      // Benzersiz günleri topla
      final Set<String> uniqueDays = {};
      for (final schedule in filteredSchedules) {
        uniqueDays.add(schedule.dayOfWeek);
      }

      return uniqueDays.toList();
    } catch (e) {
      return [];
    }
  }

  /// Dışarıdan çağrılabilir method - SQL query equivalent
  /// Bir derse tıklandığında bu method kullanılabilir
  Future<List<String>> getUniqueDaysForLesson(
    String packageId,
    String? roomId,
    int? totalLessons,
    List<String> attendeeIds,
  ) async {
    return await _getUniqueDaysForLesson(
      packageId,
      roomId,
      totalLessons,
      attendeeIds,
    );
  }

  Future<void> _loadAllDaysForPackage(String packageId) async {
    try {
      // SQL query'deki WHERE şartlarına göre benzersiz günleri getir
      final uniqueDays = await _getUniqueDaysForLesson(
        packageId,
        _selectedRoomId,
        _generatedSchedules.isNotEmpty ? _generatedSchedules.length : null,
        _selectedMemberIds,
      );

      setState(() {
        _selectedDays = uniqueDays;
      });
    } catch (e) {
      // Hata durumunda sadece mevcut dersin gününü seç
      try {
        final currentSchedule = await ref.read(
          lessonScheduleDetailProvider(widget.scheduleId).future,
        );
        setState(() {
          _selectedDays = [currentSchedule.dayOfWeek];
        });
      } catch (e2) {
        // Hata durumunda boş liste
        setState(() {
          _selectedDays = [];
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate() &&
        _selectedPackageId != null &&
        _generatedSchedules.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Her ders için güncelleme yap
        for (int i = 0; i < _generatedSchedules.length; i++) {
          var scheduleData = _generatedSchedules[i];
          final schedule = LessonSchedule(
            id: widget.scheduleId, // Mevcut ID'yi kullan
            packageId: _selectedPackageId!,
            instructorId: _selectedInstructorIds.isNotEmpty
                ? _selectedInstructorIds.first
                : null,
            roomId: _selectedRoomId,
            dayOfWeek: scheduleData['dayOfWeek'],
            startTime: _formatTime(scheduleData['startTime']),
            endTime: _formatTime(scheduleData['endTime']),
            attendeeIds: _selectedMemberIds,
            createdAt: DateTime.now(), // Güncelleme tarihi
            lessonNumber: i + 1,
            totalLessons: _generatedSchedules.length,
            status: LessonStatus.scheduled,
            actualDateDay: scheduleData['date'].day,
            actualDateMonth: scheduleData['date'].month,
            actualDateYear: scheduleData['date'].year,
          );

          await ref
              .read(data.lessonSchedulesRepositoryProvider)
              .updateLessonSchedule(schedule);
        }

        // Tüm schedule'ları paket ID'sine göre bul
        final allSchedules = await ref
            .read(data.lessonSchedulesRepositoryProvider)
            .getLessonSchedulesByPackage(_selectedPackageId!);

        // Her schedule için üye ataması yap
        if (_selectedMemberIds.isNotEmpty) {
          final repository = ref.read(data.lessonSchedulesRepositoryProvider);
          for (final schedule in allSchedules) {
            await repository.assignMembersToSchedule(
              schedule.id,
              _selectedMemberIds,
              memberPrices: _memberPrices,
            );
          }
        }

        // Her schedule için eğitmen ataması yap
        if (_selectedInstructorIds.isNotEmpty) {
          final repository = ref.read(data.lessonSchedulesRepositoryProvider);
          for (final schedule in allSchedules) {
            await repository.assignMembersToSchedule(
              schedule.id,
              _selectedInstructorIds,
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ders programı başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );

          // Provider'ı yenile
          ref.invalidate(lessonSchedulesWithPackagesProvider);

          // Geri dön
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Güncelleme sırasında hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteSchedule() async {
    try {
      // Önce aynı paket ID'sine sahip tüm dersleri kontrol et
      final allSchedules = await ref.read(
        lessonSchedulesWithPackagesProvider.future,
      );
      final packageSchedules = allSchedules
          .where((s) => s.packageId == _selectedPackageId)
          .toList();

      // Ders durumlarını kontrol et
      final hasCompletedLessons = packageSchedules.any(
        (schedule) => schedule.status == LessonStatus.completed,
      );

      final hasStartedLessons = packageSchedules.any(
        (schedule) =>
            schedule.status == LessonStatus.completed ||
            schedule.status == LessonStatus.missed ||
            schedule.status == LessonStatus.rescheduled,
      );

      if (hasCompletedLessons) {
        // Ders yapılmış, silme işlemi yapılamaz
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Ders Programı Silinemez'),
                ],
              ),
              content: const Text(
                'Bu ders programında dersler başlamıştır. Ders programı silinemez.\n\n'
                'Ders programını silmek için tüm derslerin "Planlandı" durumunda olması gerekir.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (hasStartedLessons) {
        // Ders başlamış ama tamamlanmamış
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Ders Programı Silinemez'),
                ],
              ),
              content: const Text(
                'Bu ders programında dersler başlamıştır. Ders programı silinemez.\n\n'
                'Ders programını silmek için tüm derslerin "Planlandı" durumunda olması gerekir.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Onay dialog'u göster
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Ders Programını Sil'),
              ],
            ),
            content: const Text(
              'Bu ders programını silmek istediğinizden emin misiniz?\n\n'
              'Bu işlem geri alınamaz ve tüm ders kayıtları silinecektir.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sil'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await _performDelete();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme işlemi sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performDelete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aynı paket ID'sine sahip tüm dersleri sil
      final allSchedules = await ref.read(
        lessonSchedulesWithPackagesProvider.future,
      );
      final packageSchedules = allSchedules
          .where((s) => s.packageId == _selectedPackageId)
          .toList();

      for (final schedule in packageSchedules) {
        await ref
            .read(data.lessonSchedulesRepositoryProvider)
            .deleteLessonSchedule(schedule.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders programı başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );

        // Provider'ı yenile
        ref.invalidate(lessonSchedulesWithPackagesProvider);

        // Geri dön
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme işlemi sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Rol kontrolü - Member rolü ders düzenleyemez
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

        // Member rolü kontrolü - sadece admin ve instructor ders düzenleyebilir
        if (member.roleName == 'Member') {
          return Scaffold(
            appBar: AppBar(
              leading: const AppBarLogo(),
              title: const Text('Erişim Engellendi'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
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
                    'Ders programı düzenlemek için admin veya instructor rolü gereklidir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (_isLoading && !_isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: const AppBarLogo(),
            title: const Text('Ders Programını Düzenle'),
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/lesson-schedules');
                  }
                },
                tooltip: 'Geri',
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: _isLoading ? null : _saveSchedule,
                  child: const Text('Kaydet'),
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
                  padding: const EdgeInsets.all(16),
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
                          'Ders Programını Düzenle',
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
                                      if (date != null) {
                                        final dayOfWeek = _getDayOfWeek(date);
                                        if (!_selectedDays.contains(
                                          dayOfWeek,
                                        )) {
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

                                // Ders Programı Oluşturma
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

                                SizedBox(height: isMobile ? 24 : 32),

                                // Butonlar
                                Row(
                                  children: [
                                    // Sil Butonu
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : _deleteSchedule,
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Sil'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 24,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: isMobile ? 12 : 16),

                                    // İptal Butonu
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                if (Navigator.of(
                                                  context,
                                                ).canPop()) {
                                                  Navigator.of(context).pop();
                                                } else {
                                                  context.go(
                                                    '/lesson-schedules',
                                                  );
                                                }
                                              },
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('İptal'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 24,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: isMobile ? 12 : 16),

                                    // Kaydet Butonu
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : _saveSchedule,
                                        icon: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(Icons.save),
                                        label: Text(
                                          _isLoading
                                              ? 'Güncelleniyor...'
                                              : 'Güncelle',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 24,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: isMobile ? 16 : 24),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Hata'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
