import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class EventResponseDialog extends ConsumerStatefulWidget {
  const EventResponseDialog({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<EventResponseDialog> createState() =>
      _EventResponseDialogState();
}

class _EventResponseDialogState extends ConsumerState<EventResponseDialog> {
  final _textController = TextEditingController();
  String? _selectedOptionId;
  bool _isSubmitting = false;

  // Question responses
  final Map<String, TextEditingController> _questionControllers = {};
  final Map<String, String?> _questionSelectedOptions = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each question
    for (final question in widget.event.questions) {
      _questionControllers[question.id] = TextEditingController();
      _questionSelectedOptions[question.id] = null;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final controller in _questionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      child: Container(
        width: isMobile ? screenWidth * 0.95 : screenWidth * 0.6,
        constraints: BoxConstraints(
          maxWidth: isMobile ? 400 : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with event details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    widget.event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Event type and status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(theme),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getEventTypeText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.event.startAt != null)
                        Text(
                          _formatDate(widget.event.startAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Event description
                  if (widget.event.description != null &&
                      widget.event.description!.isNotEmpty)
                    Text(
                      widget.event.description!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Event questions
                    if (widget.event.questions.isNotEmpty) ...[
                      _buildQuestionsSection(),
                      const SizedBox(height: 16),
                    ],

                    if (widget.event.type == EventType.poll &&
                        widget.event.options.isNotEmpty) ...[
                      _buildPollOptions(),
                      const SizedBox(height: 16),
                    ],
                    if (widget.event.type == EventType.interactive) ...[
                      _buildTextResponse(),
                      const SizedBox(height: 16),
                    ],
                    if (widget.event.type == EventType.normal) ...[
                      const Text(
                        'Bu etkinlik yanıt gerektirmiyor.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  if (widget.event.type != EventType.normal)
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitResponse,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Gönder'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seçenekler:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...widget.event.options.map((option) {
          return RadioListTile<String>(
            title: Text(option.optionText),
            value: option.id,
            groupValue: _selectedOptionId,
            onChanged: (value) {
              setState(() {
                _selectedOptionId = value;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etkinlik Soruları',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.event.questions.map(
          (question) => _buildQuestionWidget(question),
        ),
      ],
    );
  }

  Widget _buildQuestionWidget(EventQuestion question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Zorunlu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Question type specific UI
            if (question.questionType == 'text') ...[
              TextFormField(
                controller: _questionControllers[question.id],
                decoration: const InputDecoration(
                  hintText: 'Yanıtınızı buraya yazın...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ] else if (question.questionType == 'single_choice') ...[
              ...widget.event.options.map(
                (option) => RadioListTile<String>(
                  title: Text(option.optionText),
                  value: option.id,
                  groupValue: _questionSelectedOptions[question.id],
                  onChanged: (value) {
                    setState(() {
                      _questionSelectedOptions[question.id] = value;
                    });
                  },
                ),
              ),
            ] else if (question.questionType == 'multiple_choice') ...[
              ...widget.event.options.map(
                (option) => CheckboxListTile(
                  title: Text(option.optionText),
                  value:
                      _questionSelectedOptions[question.id]?.contains(
                        option.id,
                      ) ??
                      false,
                  onChanged: (value) {
                    setState(() {
                      final current =
                          _questionSelectedOptions[question.id] ?? '';
                      if (value == true) {
                        _questionSelectedOptions[question.id] = current.isEmpty
                            ? option.id
                            : '$current,${option.id}';
                      } else {
                        _questionSelectedOptions[question.id] = current
                            .split(',')
                            .where((id) => id != option.id)
                            .join(',');
                      }
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextResponse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Yanıtınız:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Yanıtınızı buraya yazın...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Future<void> _submitResponse() async {
    // Validate required questions
    for (final question in widget.event.questions) {
      if (question.isRequired) {
        if (question.questionType == 'text' &&
            (_questionControllers[question.id]?.text.trim().isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lütfen "${question.questionText}" sorusunu yanıtlayın',
              ),
            ),
          );
          return;
        }
        if ((question.questionType == 'single_choice' ||
                question.questionType == 'multiple_choice') &&
            (_questionSelectedOptions[question.id]?.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lütfen "${question.questionText}" sorusunu yanıtlayın',
              ),
            ),
          );
          return;
        }
      }
    }

    if (widget.event.type == EventType.poll && _selectedOptionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir seçenek seçin')));
      return;
    }

    if (widget.event.type == EventType.interactive &&
        _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir yanıt yazın')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final eventsRepository = ref.read(eventsRepositoryProvider);

      // Save question responses
      for (final question in widget.event.questions) {
        final controller = _questionControllers[question.id];
        final selectedOption = _questionSelectedOptions[question.id];

        if (question.questionType == 'text' &&
            controller != null &&
            controller.text.trim().isNotEmpty) {
          await eventsRepository.createQuestionResponse(
            questionId: question.id,
            memberId: '', // Will be set by current user
            responseText: controller.text.trim(),
          );
        } else if ((question.questionType == 'single_choice' ||
                question.questionType == 'multiple_choice') &&
            selectedOption != null &&
            selectedOption.isNotEmpty) {
          await eventsRepository.createQuestionResponse(
            questionId: question.id,
            memberId: '', // Will be set by current user
            responseText: selectedOption,
          );
        }
      }

      // Save main event response
      final createEventResponse = ref.read(createEventResponseProvider);
      await createEventResponse.call(
        eventId: widget.event.id,
        optionId: _selectedOptionId,
        responseText: _textController.text.trim().isEmpty
            ? null
            : _textController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yanıtınız gönderildi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Color _getEventTypeColor(ThemeData theme) {
    switch (widget.event.type) {
      case EventType.normal:
        return Colors.grey;
      case EventType.interactive:
        return Colors.blue;
      case EventType.poll:
        return Colors.purple;
      case EventType.workshop:
        return Colors.green;
      case EventType.seminar:
        return Colors.teal;
      case EventType.conference:
        return Colors.red;
    }
  }

  String _getEventTypeText() {
    switch (widget.event.type) {
      case EventType.normal:
        return 'Normal';
      case EventType.interactive:
        return 'Etkileşimli';
      case EventType.poll:
        return 'Anket';
      case EventType.workshop:
        return 'Atölye';
      case EventType.seminar:
        return 'Seminer';
      case EventType.conference:
        return 'Konferans';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün sonra';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat sonra';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika sonra';
    } else {
      return 'Şimdi';
    }
  }
}
