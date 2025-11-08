import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class EventResponsesWidget extends ConsumerWidget {
  const EventResponsesWidget({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EventResponse>>(
      future: _getEventResponses(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final responses = snapshot.data ?? [];

        if (responses.isEmpty) {
          return const Center(
            child: Text(
              'Henüz yanıt bulunmuyor',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yanıtlar (${responses.length}):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...responses.map((response) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member name and surname
                      if (response.memberName != null ||
                          response.memberSurname != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${response.memberName ?? ''} ${response.memberSurname ?? ''}'
                                  .trim(),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (response.optionId != null) ...[
                        Text(
                          'Seçilen Seçenek:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getOptionText(response.optionId!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (response.responseText != null) ...[
                        if (response.optionId != null)
                          const SizedBox(height: 8),
                        Text(
                          'Metin Yanıtı:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          response.responseText!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Gönderilme: ${_formatDateTime(response.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<List<EventResponse>> _getEventResponses(WidgetRef ref) async {
    final repository = ref.read(eventsRepositoryProvider);
    return await repository.getEventResponses(event.id);
  }

  String _getOptionText(String optionId) {
    final option = event.options.firstWhere(
      (opt) => opt.id == optionId,
      orElse: () =>
          EventOption(id: '', eventId: '', optionText: 'Bilinmeyen seçenek'),
    );
    return option.optionText;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
