import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventDetailDateTime extends StatelessWidget {
  const EventDetailDateTime({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlangıç Tarihi ve Saati
          if (event.startAt != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Başlangıç',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimeInfo(event.startAt!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Bitiş Tarihi ve Saati
          if (event.endAt != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stop, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Bitiş',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimeInfo(event.endAt!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Kayıt Son Tarihi
          if (event.registrationDeadline != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_available, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Kayıt Son Tarihi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimeInfo(event.registrationDeadline!),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRegistrationStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getRegistrationStatusColor().withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getRegistrationStatusIcon(),
                            color: _getRegistrationStatusColor(),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRegistrationStatusText(),
                            style: TextStyle(
                              color: _getRegistrationStatusColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Süre Bilgisi
          if (event.startAt != null && event.endAt != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Etkinlik Süresi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDurationInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Maksimum Katılımcı Sayısı
          if (event.maxParticipants != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Maksimum Katılımcı Sayısı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            '${event.maxParticipants} kişi',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final dayName = days[dateTime.weekday - 1];
    final monthName = months[dateTime.month - 1];
    final formattedDate = '${dateTime.day} $monthName ${dateTime.year}';
    final formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$dayName - $formattedTime',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDurationInfo() {
    if (event.startAt == null || event.endAt == null) {
      return const Text('Süre bilgisi mevcut değil');
    }

    final duration = event.endAt!.difference(event.startAt!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    String durationText = '';
    if (days > 0) {
      durationText += '$days gün ';
    }
    if (hours > 0) {
      durationText += '$hours saat ';
    }
    if (minutes > 0) {
      durationText += '$minutes dakika';
    }

    if (durationText.isEmpty) {
      durationText = '1 dakikadan az';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            durationText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRegistrationStatusColor() {
    if (event.registrationDeadline == null) return Colors.grey;

    final now = DateTime.now();
    final deadline = event.registrationDeadline!;

    if (now.isAfter(deadline)) {
      return Colors.red; // Kayıt süresi dolmuş
    } else if (deadline.difference(now).inDays <= 1) {
      return Colors.orange; // Son gün
    } else {
      return Colors.green; // Kayıt açık
    }
  }

  IconData _getRegistrationStatusIcon() {
    if (event.registrationDeadline == null) return Icons.help;

    final now = DateTime.now();
    final deadline = event.registrationDeadline!;

    if (now.isAfter(deadline)) {
      return Icons.close; // Kayıt süresi dolmuş
    } else if (deadline.difference(now).inDays <= 1) {
      return Icons.warning; // Son gün
    } else {
      return Icons.check; // Kayıt açık
    }
  }

  String _getRegistrationStatusText() {
    if (event.registrationDeadline == null) return 'Kayıt süresi belirtilmemiş';

    final now = DateTime.now();
    final deadline = event.registrationDeadline!;

    if (now.isAfter(deadline)) {
      return 'Kayıt süresi dolmuş';
    } else if (deadline.difference(now).inDays <= 1) {
      return 'Kayıt son gün!';
    } else {
      return 'Kayıt açık';
    }
  }
}
