import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../domain/entities/lesson_schedule.dart';
import 'lesson_detail_info_card.dart';
import '../../../members/data/providers/members_providers.dart'
    as members_providers;
import '../providers/lesson_schedules_providers.dart';
import '../../data/providers/lesson_schedules_providers.dart' as data;

class LessonDetailStatusTab extends ConsumerStatefulWidget {
  final LessonScheduleWithPackage schedule;

  const LessonDetailStatusTab({super.key, required this.schedule});

  @override
  ConsumerState<LessonDetailStatusTab> createState() =>
      _LessonDetailStatusTabState();
}

class _LessonDetailStatusTabState extends ConsumerState<LessonDetailStatusTab> {
  bool _showRescheduleForm = false;
  DateTime? _selectedRescheduleDate;
  TimeOfDay? _selectedRescheduleTime;
  final TextEditingController _rescheduleReasonController =
      TextEditingController();

  @override
  void dispose() {
    _rescheduleReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Current member bilgisini al
    final currentMemberAsync = ref.watch(
      members_providers.currentMemberProvider,
    );

    return currentMemberAsync.when(
      data: (currentMember) {
        final isMember = currentMember?.roleName == 'Member';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ders Durumu
              LessonDetailInfoCard(
                icon: Icons.assignment,
                title: 'Ders Durumu',
                children: [
                  _buildStatusRow(
                    'Mevcut Durum:',
                    _getStatusText(widget.schedule.status),
                    _getStatusColor(widget.schedule.status),
                  ),
                  if (widget.schedule.actualDateDay != null &&
                      widget.schedule.actualDateMonth != null &&
                      widget.schedule.actualDateYear != null)
                    _buildInfoRow(
                      'Gerçekleşme Tarihi:',
                      '${widget.schedule.actualDateDay}/${widget.schedule.actualDateMonth}/${widget.schedule.actualDateYear}',
                    ),
                  if (widget.schedule.rescheduledDate != null)
                    _buildInfoRow(
                      'Yeniden Planlanan Tarih:',
                      _formatDate(widget.schedule.rescheduledDate!),
                    ),
                  if (widget.schedule.rescheduleReason != null)
                    _buildInfoRow(
                      'Yeniden Planlama Sebebi:',
                      widget.schedule.rescheduleReason!,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Admin rolü için bilgi mesajı - scheduled haricinde durumlar için
              if (!isMember &&
                  widget.schedule.status != LessonStatus.scheduled) ...[
                LessonDetailInfoCard(
                  icon: Icons.info_outline,
                  title: 'Bilgi',
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bu dersin durumu ${_getStatusText(widget.schedule.status)} olarak değiştirilmiştir.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Ders Durumu - Sadece Admin/Instructor için ve sadece scheduled durumunda
              if (!isMember &&
                  widget.schedule.status == LessonStatus.scheduled) ...[
                LessonDetailInfoCard(
                  icon: Icons.edit,
                  title: 'Ders Durumu',
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _markAsCompleted(),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('İşlendi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => _showRescheduleForm = true),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('İşlenmedi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // İşlenmedi olarak işaretlenen dersler için yeniden planlama tarihi düzenleme
                if (widget.schedule.status == LessonStatus.missed &&
                    widget.schedule.rescheduledDate != null) ...[
                  const SizedBox(height: 16),
                  LessonDetailInfoCard(
                    icon: Icons.edit_calendar,
                    title: 'Yeniden Planlama Tarihi Düzenle',
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Yeniden Planlanan Tarih: ${_formatDate(widget.schedule.rescheduledDate!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _editRescheduleDate(),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Düzenle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],

              // Yeniden planlama formu - sadece admin'ler için ve form gösterildiğinde
              if (!isMember && _showRescheduleForm) ...[
                LessonDetailInfoCard(
                  icon: Icons.edit_calendar,
                  title: 'Dersi Yeniden Planla',
                  children: [
                    const SizedBox(height: 16),

                    // Tarih Seçimi
                    InkWell(
                      onTap: () async {
                        if (!mounted) return;

                        try {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _selectedRescheduleDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null && mounted) {
                            setState(() {
                              _selectedRescheduleDate = date;
                            });
                          }
                        } catch (e) {
                          // Hata durumunda sessizce devam et
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRescheduleDate != null
                                  ? '${_selectedRescheduleDate!.day}/${_selectedRescheduleDate!.month}/${_selectedRescheduleDate!.year}'
                                  : 'Tarih Seçin',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Saat Seçimi
                    InkWell(
                      onTap: () async {
                        if (!mounted) return;

                        try {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                                _selectedRescheduleTime ?? TimeOfDay.now(),
                          );
                          if (time != null && mounted) {
                            setState(() {
                              _selectedRescheduleTime = time;
                            });
                          }
                        } catch (e) {
                          // Hata durumunda sessizce devam et
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRescheduleTime != null
                                  ? '${_selectedRescheduleTime!.hour.toString().padLeft(2, '0')}:${_selectedRescheduleTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Saat Seçin',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sebep
                    TextField(
                      controller: _rescheduleReasonController,
                      decoration: const InputDecoration(
                        labelText: 'Yeniden Planlama Sebebi',
                        border: OutlineInputBorder(),
                        hintText: 'Ders neden işlenmedi?',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Butonlar
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _selectedRescheduleDate != null &&
                                    _selectedRescheduleTime != null
                                ? () => _handleReschedule()
                                : null,
                            icon: const Icon(Icons.schedule, size: 16),
                            label: const Text('Yeniden Planla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => _showRescheduleForm = false),
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('İptal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Member rolü için bilgilendirme kartı - sadece member'lar için
              if (isMember) ...[
                LessonDetailInfoCard(
                  icon: Icons.info_outline,
                  title: 'Bilgi',
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ders durumu değiştirme yetkiniz bulunmamaktadır. Sadece ders bilgilerini görüntüleyebilirsiniz.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return 'Planlandı';
      case LessonStatus.completed:
        return 'İşlendi';
      case LessonStatus.missed:
        return 'İşlenmedi';
      case LessonStatus.rescheduled:
        return 'Yeniden Planlandı';
    }
  }

  Color _getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return Colors.blue;
      case LessonStatus.completed:
        return Colors.green;
      case LessonStatus.missed:
        return Colors.red;
      case LessonStatus.rescheduled:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _markAsCompleted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi İşlendi Olarak İşaretle'),
        content: const Text(
          'Bu dersi işlendi olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleMarkAsCompleted();
            },
            child: const Text('İşaretle'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkAsCompleted() async {
    final repository = ref.read(data.lessonSchedulesRepositoryProvider);

    // Loading state göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders durumu güncelleniyor...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    await repository.updateLessonStatus(
      widget.schedule.id,
      LessonStatus.completed,
    );

    // Provider'ı yenile
    ref.invalidate(lessonSchedulesWithPackagesProvider);

    // Ana popup'ı kapat
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders işlendi olarak işaretlendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleReschedule() async {
    final repository = ref.read(data.lessonSchedulesRepositoryProvider);

    // Loading state göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders yeniden planlanıyor...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Tarih ve saati birleştir
    final newDateTime = DateTime(
      _selectedRescheduleDate!.year,
      _selectedRescheduleDate!.month,
      _selectedRescheduleDate!.day,
      _selectedRescheduleTime!.hour,
      _selectedRescheduleTime!.minute,
    );

    await repository.updateLessonStatus(
      widget.schedule.id,
      LessonStatus.missed,
      rescheduledDate: newDateTime,
      rescheduleReason: _rescheduleReasonController.text,
    );

    // Provider'ı yenile
    ref.invalidate(lessonSchedulesWithPackagesProvider);

    // Formu kapat
    setState(() {
      _showRescheduleForm = false;
      _selectedRescheduleDate = null;
      _selectedRescheduleTime = null;
      _rescheduleReasonController.clear();
    });

    // Ana popup'ı kapat
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders işlenmedi olarak işaretlendi ve yeniden planlandı'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _editRescheduleDate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeniden Planlama Tarihi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yeni tarih seçin:'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                if (!mounted) return;

                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      widget.schedule.rescheduledDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null && mounted) {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      widget.schedule.rescheduledDate ?? DateTime.now(),
                    ),
                  );
                  if (selectedTime != null && mounted) {
                    final newDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    try {
                      final repository = ref.read(
                        data.lessonSchedulesRepositoryProvider,
                      );
                      await repository.updateLessonStatus(
                        widget.schedule.id,
                        LessonStatus.rescheduled,
                        rescheduledDate: newDateTime,
                        rescheduleReason: widget.schedule.rescheduleReason,
                      );

                      // Provider'ı yenile
                      ref.invalidate(lessonSchedulesWithPackagesProvider);

                      if (mounted) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Yeniden planlama tarihi güncellendi',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Tarih Seç'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}
