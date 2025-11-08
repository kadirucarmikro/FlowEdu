import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lesson_schedules_providers.dart';
import '../widgets/weekly_calendar_view.dart';
import '../widgets/lesson_schedule_list_view.dart';
import '../widgets/lesson_schedule_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';

enum ViewMode { calendar, list }

class LessonSchedulesPage extends ConsumerStatefulWidget {
  const LessonSchedulesPage({super.key});

  @override
  ConsumerState<LessonSchedulesPage> createState() =>
      _LessonSchedulesPageState();
}

class _LessonSchedulesPageState extends ConsumerState<LessonSchedulesPage> {
  ViewMode _viewMode = ViewMode.calendar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // URL'den viewMode parametresini oku (eğer varsa)
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    final uri = Uri.parse(location);
    final viewModeParam = uri.queryParameters['viewMode'];
    if (viewModeParam != null && mounted) {
      final newViewMode = viewModeParam == 'list' 
          ? ViewMode.list 
          : ViewMode.calendar;
      // Sadece değişiklik varsa setState çağır
      if (_viewMode != newViewMode) {
        setState(() {
          _viewMode = newViewMode;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Ders Programı'),
        actions: [
          // Görünüm değiştirme butonu
          Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<bool>(
                future: RoleService.isAdmin(),
                builder: (context, snapshot) {
                  final isAdmin = snapshot.data == true;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Takvim görünümü butonu
                      IconButton(
                        icon: Icon(
                          Icons.calendar_view_week,
                          color: _viewMode == ViewMode.calendar
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _viewMode = ViewMode.calendar;
                          });
                          // URL'yi güncelle
                          if (context.mounted) {
                            context.go('/lesson-schedules?viewMode=calendar');
                          }
                        },
                        tooltip: 'Takvim Görünümü',
                      ),
                      // Liste görünümü butonu
                      IconButton(
                        icon: Icon(
                          Icons.list,
                          color: _viewMode == ViewMode.list
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _viewMode = ViewMode.list;
                          });
                          // URL'yi güncelle
                          if (context.mounted) {
                            context.go('/lesson-schedules?viewMode=list');
                          }
                        },
                        tooltip: 'Liste Görünümü',
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        // Admin için: Yeni Ders Ekle butonu
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (context.mounted) {
                              context.go('/lesson-schedules/add');
                            }
                          },
                          tooltip: 'Yeni Ders Programı',
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const nav.NavigationDrawer(
        currentRoute: AppRoutes.lessonSchedules,
      ),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildMemberView(),
      ),
    );
  }

  Widget _buildAdminView() {
    if (_viewMode == ViewMode.calendar) {
      final schedulesAsync = ref.watch(lessonSchedulesWithPackagesProvider);

      return schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => CenteredErrorWidget.generalError(
          message: 'Hata: $error',
          onRetry: () => ref.invalidate(lessonSchedulesWithPackagesProvider),
        ),
        data: (schedules) {
          return WeeklyCalendarView(
            isAdmin: true,
            onScheduleTap: (scheduleId) => _navigateToDetail(scheduleId),
            onScheduleEdit: (schedule) =>
                _showEditLessonScheduleDialog(context, schedule),
          );
        },
      );
    } else {
      return LessonScheduleListView(
        isAdmin: true,
        onScheduleTap: (scheduleId) => _navigateToDetail(scheduleId),
        onScheduleEdit: (schedule) =>
            _showEditLessonScheduleDialog(context, schedule),
      );
    }
  }

  Widget _buildMemberView() {
    if (_viewMode == ViewMode.calendar) {
      // Member ID al
      final memberIdAsync = ref.watch(currentMemberIdProvider);

      return memberIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => CenteredErrorWidget.generalError(
          message: 'Hata: $error',
          onRetry: () => ref.invalidate(currentMemberIdProvider),
        ),
        data: (memberId) {
          if (memberId == null) {
            return CenteredErrorWidget.generalError(
              message: 'Üye bilgisi bulunamadı',
            );
          }

          // Member'a atanan programları getir
          final schedulesAsync = ref.watch(
            memberAssignedSchedulesProvider(memberId),
          );

          return schedulesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () =>
                  ref.invalidate(memberAssignedSchedulesProvider(memberId)),
            ),
            data: (schedules) {
              return WeeklyCalendarView(
                isAdmin: false,
                onScheduleTap: (scheduleId) => _navigateToDetail(scheduleId),
              );
            },
          );
        },
      );
    } else {
      return LessonScheduleListView(
        isAdmin: false,
        onScheduleTap: (scheduleId) => _navigateToDetail(scheduleId),
      );
    }
  }

  void _navigateToDetail(String scheduleId) {
    if (mounted) {
      // Mevcut viewMode'u query parameter olarak geçir
      final viewModeParam = _viewMode == ViewMode.list ? 'list' : 'calendar';
      context.go('/lesson-schedules/$scheduleId?viewMode=$viewModeParam');
    }
  }

  void _showEditLessonScheduleDialog(BuildContext context, schedule) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 800
              ? MediaQuery.of(context).size.width * 0.8
              : MediaQuery.of(context).size.width - 32,
          height: MediaQuery.of(context).size.height > 600
              ? MediaQuery.of(context).size.height * 0.9
              : MediaQuery.of(context).size.height - 32,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ders Programı Düzenle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: LessonScheduleFormDialog(
                  schedule: schedule,
                  onSave: (updatedSchedule) async {
                    try {
                      final updateLessonSchedule = ref.read(
                        updateLessonScheduleProvider,
                      );
                      await updateLessonSchedule(updatedSchedule);
                      if (mounted) {
                        ref.invalidate(lessonSchedulesWithPackagesProvider);
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ders programı başarıyla güncellendi',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
