import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/lesson_schedules_providers.dart';
import '../widgets/lesson_schedule_form_dialog.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../members/data/providers/members_providers.dart' as members_providers;

class LessonScheduleDetailPage extends ConsumerWidget {
  final String scheduleId;

  const LessonScheduleDetailPage({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(lessonScheduleDetailProvider(scheduleId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Ders Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.mounted) {
                // URL'den viewMode parametresini al
                final router = GoRouter.of(context);
                final location = router.routerDelegate.currentConfiguration.uri.toString();
                final uri = Uri.parse(location);
                final viewModeParam = uri.queryParameters['viewMode'];
                final viewModeQuery = viewModeParam != null 
                    ? '?viewMode=$viewModeParam' 
                    : '';
                context.go('/lesson-schedules$viewModeQuery');
              }
            },
            tooltip: 'Geri',
          ),
          Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<bool>(
                future: RoleService.isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(context, ref, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Düzenle'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Sil',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => CenteredErrorWidget.generalError(
          message: 'Hata: $error',
          onRetry: () =>
              ref.invalidate(lessonScheduleDetailProvider(scheduleId)),
        ),
        data: (schedule) {
          // Member rolü kontrolü - sadece kendi derslerini görebilir
          final currentMemberAsync = ref.watch(
            members_providers.currentMemberProvider,
          );

          return currentMemberAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
            ),
            data: (currentMember) {
              // Member rolü kontrolü
              if (currentMember?.roleName == 'Member') {
                // Member'ın bu derse katılıp katılmadığını kontrol et
                final memberId = currentMember?.id;
                if (memberId == null ||
                    !schedule.attendeeIds.contains(memberId)) {
                  // Member bu derse katılmıyor, erişim engellendi
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.block, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Erişim Engellendi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu ders programına erişim yetkiniz bulunmamaktadır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (context.mounted) {
                              context.go('/lesson-schedules');
                            }
                          },
                          child: const Text('Ders Programına Dön'),
                        ),
                      ],
                    ),
                  );
                }
              }

              // Admin/Instructor veya kendi dersine erişen Member
              return _buildScheduleDetail(context, ref, schedule);
            },
          );
        },
      ),
    );
  }

  Widget _buildScheduleDetail(BuildContext context, WidgetRef ref, schedule) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final maxWidth = isMobile ? constraints.maxWidth : 1200.0;
        
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paket Bilgileri
                  _buildInfoCard(
                    title: 'Paket Bilgileri',
                    icon: Icons.school,
                    children: [
                      _buildInfoRow('Paket Adı', schedule.packageName),
                      _buildInfoRow('Ders Sayısı', '${schedule.packageLessonCount}'),
                      _buildInfoRow(
                        'Paket Durumu',
                        schedule.packageIsActive ? 'Aktif' : 'Pasif',
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Ders Bilgileri
                  _buildInfoCard(
                    title: 'Ders Bilgileri',
                    icon: Icons.schedule,
                    children: [
                      _buildInfoRow('Gün', _getDayNameTurkish(schedule.dayOfWeek)),
                      _buildInfoRow('Başlangıç Saati', schedule.startTime),
                      _buildInfoRow('Bitiş Saati', schedule.endTime),
                      _buildInfoRow(
                        'Oluşturulma Tarihi',
                        _formatDate(schedule.createdAt),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Eğitmen Bilgileri
                  if (schedule.instructorName != null &&
                      schedule.instructorName!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Eğitmen Bilgileri',
                      icon: Icons.person,
                      children: [
                        _buildInfoRow('Eğitmen Adı', schedule.instructorName),
                        if (schedule.instructorSpecialization != null &&
                            schedule.instructorSpecialization!.isNotEmpty)
                          _buildInfoRow(
                            'Uzmanlık Alanı',
                            schedule.instructorSpecialization,
                          ),
                        if (schedule.instructorExperience != null &&
                            schedule.instructorExperience!.isNotEmpty)
                          _buildInfoRow('Deneyim', schedule.instructorExperience),
                      ],
                    ),

                  if (schedule.instructorName != null &&
                      schedule.instructorName!.isNotEmpty)
                    SizedBox(height: isMobile ? 12 : 16),

                  // Oda Bilgileri
                  if (schedule.roomName != null && schedule.roomName!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Oda Bilgileri',
                      icon: Icons.meeting_room,
                      children: [
                        _buildInfoRow('Oda Adı', schedule.roomName),
                        if (schedule.roomCapacity != null)
                          _buildInfoRow('Kapasite', '${schedule.roomCapacity} kişi'),
                        if (schedule.roomFeatures != null &&
                            schedule.roomFeatures!.isNotEmpty)
                          _buildInfoRow('Özellikler', schedule.roomFeatures),
                      ],
                    ),

                  if (schedule.roomName != null && schedule.roomName!.isNotEmpty)
                    SizedBox(height: isMobile ? 12 : 16),

                  // Katılımcılar
                  _buildInfoCard(
                    title: 'Katılımcılar',
                    icon: Icons.people,
                    children: [
                      _buildInfoRow(
                        'Katılımcı Sayısı',
                        '${schedule.attendeeIds.length}',
                      ),
                      if (schedule.attendeeIds.isNotEmpty) ...[
                        SizedBox(height: isMobile ? 6 : 8),
                        Text(
                          'Katılımcı Listesi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        ...schedule.attendeeIds
                            .map((attendeeId) => _buildAttendeeItem(attendeeId))
                            .toList(),
                      ] else
                        Text(
                          'Henüz katılımcı atanmamış',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

          // Admin için aksiyon butonları
          Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<bool>(
                future: RoleService.isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _editSchedule(context, ref, schedule),
                                icon: const Icon(Icons.edit),
                                label: const Text('Düzenle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 14 : 12,
                                    horizontal: isMobile ? 16 : 24,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 10 : 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _deleteSchedule(context, ref, schedule),
                                icon: const Icon(Icons.delete),
                                label: const Text('Sil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 14 : 12,
                                    horizontal: isMobile ? 16 : 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.blue, size: isMobile ? 20 : 24),
                    SizedBox(width: isMobile ? 6 : 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '$label:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAttendeeItem(String attendeeId) {
    // Bu kısımda attendee bilgilerini göstermek için
    // members provider'ından bilgi alınabilir
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 4 : 6),
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: isMobile ? 14 : 16,
                color: Colors.grey,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Flexible(
                child: Text(
                  'Katılımcı ID: $attendeeId', // Gerçek uygulamada member adı gösterilecek
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDayNameTurkish(String dayOfWeek) {
    const dayMap = {
      'Monday': 'Pazartesi',
      'Tuesday': 'Salı',
      'Wednesday': 'Çarşamba',
      'Thursday': 'Perşembe',
      'Friday': 'Cuma',
      'Saturday': 'Cumartesi',
      'Sunday': 'Pazar',
    };
    return dayMap[dayOfWeek] ?? dayOfWeek;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        _editSchedule(context, ref, null);
        break;
      case 'delete':
        _deleteSchedule(context, ref, null);
        break;
    }
  }

  void _editSchedule(BuildContext context, WidgetRef ref, schedule) {
    showDialog(
      context: context,
      builder: (context) => LessonScheduleFormDialog(
        schedule: schedule,
        onSave: (updatedSchedule) {
          ref.invalidate(lessonScheduleDetailProvider(scheduleId));
          ref.invalidate(lessonSchedulesWithPackagesProvider);
        },
      ),
    );
  }

  void _deleteSchedule(BuildContext context, WidgetRef ref, schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: const Text('Bu dersi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete işlemi burada yapılacak
                // await ref.read(deleteLessonScheduleProvider).call(scheduleId);

                Navigator.of(context).pop();
                if (context.mounted) {
                  context.pop();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ders başarıyla silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silme hatası: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
