import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class EventQuestionResponsesWidget extends ConsumerWidget {
  const EventQuestionResponsesWidget({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EventQuestionResponse>>(
      future: _getAllQuestionResponses(ref),
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
              'Henüz soru yanıtı bulunmuyor',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }

        // Yanıtları soruya göre grupla
        final responsesByQuestion = <String, List<EventQuestionResponse>>{};
        for (final response in responses) {
          if (!responsesByQuestion.containsKey(response.questionId)) {
            responsesByQuestion[response.questionId] = [];
          }
          responsesByQuestion[response.questionId]!.add(response);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 800;
            final isTablet = constraints.maxWidth > 600;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.quiz,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Soru Yanıtları (${responses.length} yanıt)',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Responsive Grid Layout
                if (isWideScreen) ...[
                  // Desktop: 2 sütunlu grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: responsesByQuestion.length,
                    itemBuilder: (context, index) {
                      final entry = responsesByQuestion.entries.elementAt(
                        index,
                      );
                      EventQuestion question;
                      try {
                        question = event.questions.firstWhere(
                          (q) => q.id == entry.key,
                        );
                      } catch (e) {
                        // Soru bulunamadı, varsayılan soru oluştur
                        question = EventQuestion(
                          id: entry.key,
                          eventId: event.id,
                          questionText: 'Bilinmeyen Soru',
                          questionType: 'text',
                          isRequired: false,
                          sortOrder: 0,
                          createdAt: DateTime.now(),
                          options: [],
                        );
                      }
                      return _buildQuestionResponsesCard(
                        context,
                        question,
                        entry.value,
                        isWideScreen: true,
                      );
                    },
                  ),
                ] else if (isTablet) ...[
                  // Tablet: Tek sütun ama geniş kartlar
                  ...responsesByQuestion.entries.map((entry) {
                    EventQuestion question;
                    try {
                      question = event.questions.firstWhere(
                        (q) => q.id == entry.key,
                      );
                    } catch (e) {
                      // Soru bulunamadı, varsayılan soru oluştur
                      question = EventQuestion(
                        id: entry.key,
                        eventId: event.id,
                        questionText: 'Bilinmeyen Soru',
                        questionType: 'text',
                        isRequired: false,
                        sortOrder: 0,
                        createdAt: DateTime.now(),
                        options: [],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildQuestionResponsesCard(
                        context,
                        question,
                        entry.value,
                        isWideScreen: false,
                      ),
                    );
                  }),
                ] else ...[
                  // Mobile: Tek sütun, kompakt kartlar
                  ...responsesByQuestion.entries.map((entry) {
                    EventQuestion question;
                    try {
                      question = event.questions.firstWhere(
                        (q) => q.id == entry.key,
                      );
                    } catch (e) {
                      // Soru bulunamadı, varsayılan soru oluştur
                      question = EventQuestion(
                        id: entry.key,
                        eventId: event.id,
                        questionText: 'Bilinmeyen Soru',
                        questionType: 'text',
                        isRequired: false,
                        sortOrder: 0,
                        createdAt: DateTime.now(),
                        options: [],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuestionResponsesCard(
                        context,
                        question,
                        entry.value,
                        isWideScreen: false,
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQuestionResponsesCard(
    BuildContext context,
    EventQuestion question,
    List<EventQuestionResponse> responses, {
    bool isWideScreen = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: isWideScreen ? 0 : 16),
      elevation: isWideScreen ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWideScreen ? 8 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWideScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soru başlığı
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 6 : 8,
                    vertical: isWideScreen ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(
                      question.questionType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getQuestionTypeText(question.questionType),
                    style: TextStyle(
                      fontSize: isWideScreen ? 10 : 12,
                      color: _getQuestionTypeColor(question.questionType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question.isRequired) ...[
                  SizedBox(width: isWideScreen ? 6 : 8),
                  Chip(
                    label: Text(
                      'Zorunlu',
                      style: TextStyle(fontSize: isWideScreen ? 9 : 10),
                    ),
                    backgroundColor: Colors.redAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
            SizedBox(height: isWideScreen ? 6 : 8),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isWideScreen ? 14 : 16,
              ),
              maxLines: isWideScreen ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isWideScreen ? 8 : 12),

            // Yanıtlar
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: isWideScreen ? 16 : 18,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: isWideScreen ? 6 : 8),
                Text(
                  'Yanıtlar (${responses.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isWideScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isWideScreen ? 6 : 8),

            // Yanıt listesi
            if (isWideScreen) ...[
              // Desktop: Kompakt liste
              ...responses
                  .take(3)
                  .map(
                    (response) => _buildResponseItem(
                      context,
                      response,
                      question,
                      isWideScreen: true,
                    ),
                  ),
              if (responses.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '... ve ${responses.length - 3} yanıt daha',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ] else ...[
              // Mobile/Tablet: Tam liste
              ...responses.map(
                (response) => _buildResponseItem(
                  context,
                  response,
                  question,
                  isWideScreen: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseItem(
    BuildContext context,
    EventQuestionResponse response,
    EventQuestion question, {
    bool isWideScreen = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isWideScreen ? 4 : 8),
      padding: EdgeInsets.all(isWideScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: isWideScreen ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(isWideScreen ? 6 : 8),
        border: Border.all(
          color: isWideScreen ? Colors.blue[200]! : Colors.grey[300]!,
          width: isWideScreen ? 0.5 : 1,
        ),
      ),
      child: isWideScreen
          ? Row(
              children: [
                // Üye bilgisi (kompakt)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          response.memberName ?? 'Bilinmeyen Üye',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 11,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Yanıt içeriği (kompakt)
                Expanded(
                  flex: 3,
                  child: _buildResponseContent(
                    context,
                    response,
                    question,
                    isWideScreen: true,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üye bilgisi
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        response.memberName ?? 'Bilinmeyen Üye',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      _formatDateTime(response.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Yanıt içeriği
                _buildResponseContent(
                  context,
                  response,
                  question,
                  isWideScreen: false,
                ),
              ],
            ),
    );
  }

  Widget _buildResponseContent(
    BuildContext context,
    EventQuestionResponse response,
    EventQuestion question, {
    bool isWideScreen = false,
  }) {
    switch (question.questionType) {
      case 'text':
        return Text(
          response.responseText ?? 'Yanıt yok',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: isWideScreen ? 11 : 14),
          maxLines: isWideScreen ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        );

      case 'single_choice':
        if (response.optionId != null) {
          // Seçilen seçeneği bul
          final selectedOption = question.options.firstWhere(
            (opt) => opt.id == response.optionId,
            orElse: () => EventQuestionOption(
              id: response.optionId!,
              questionId: question.id,
              optionText: 'Bilinmeyen Seçenek',
              sortOrder: 0,
              createdAt: DateTime.now(),
            ),
          );
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 6 : 8,
              vertical: isWideScreen ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isWideScreen ? 3 : 4),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              selectedOption.optionText,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
                fontSize: isWideScreen ? 10 : 12,
              ),
              maxLines: isWideScreen ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Text(
            'Seçim yapılmamış',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: isWideScreen ? 10 : 12,
            ),
          );
        }

      case 'multiple_choice':
        if (response.responseText != null &&
            response.responseText!.isNotEmpty) {
          // Çoklu seçim için seçilen seçenekleri ayır (responseText'ten)
          final selectedOptionIds = response.responseText!.split(',');
          final selectedOptions = question.options
              .where((opt) => selectedOptionIds.contains(opt.id))
              .toList();

          if (isWideScreen) {
            // Desktop: Kompakt görünüm
            return Text(
              selectedOptions.map((opt) => opt.optionText).join(', '),
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            // Mobile/Tablet: Tam görünüm
            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedOptions
                  .map(
                    (option) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        option.optionText,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }
        } else {
          return Text(
            'Seçim yapılmamış',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: isWideScreen ? 10 : 12,
            ),
          );
        }

      default:
        return Text(
          'Desteklenmeyen soru tipi',
          style: TextStyle(
            color: Colors.red[600],
            fontStyle: FontStyle.italic,
            fontSize: isWideScreen ? 10 : 12,
          ),
        );
    }
  }

  Future<List<EventQuestionResponse>> _getAllQuestionResponses(
    WidgetRef ref,
  ) async {
    final repository = ref.read(eventsRepositoryProvider);
    return await repository.getAllQuestionResponsesForEvent(event.id);
  }

  String _getQuestionTypeText(String type) {
    switch (type) {
      case 'text':
        return 'Metin';
      case 'single_choice':
        return 'Tek Seçim';
      case 'multiple_choice':
        return 'Çoklu Seçim';
      default:
        return 'Bilinmeyen';
    }
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'single_choice':
        return Colors.green;
      case 'multiple_choice':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
