import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventDetailQuestions extends StatefulWidget {
  const EventDetailQuestions({super.key, required this.event});

  final Event event;

  @override
  State<EventDetailQuestions> createState() => _EventDetailQuestionsState();
}

class _EventDetailQuestionsState extends State<EventDetailQuestions> {
  final Map<String, dynamic> _responses = {};
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Sorular',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.event.questions.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Soru listesi
          if (widget.event.questions.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz soru eklenmemiş',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.event.questions.length,
              itemBuilder: (context, index) {
                final question = widget.event.questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Soru başlığı
                        Row(
                          children: [
                            Text(
                              'Soru ${index + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            if (question.isRequired) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Zorunlu',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getQuestionTypeColor(
                                  question.questionType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getQuestionTypeText(question.questionType),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getQuestionTypeColor(
                                    question.questionType,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Soru metni
                        Text(
                          question.questionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cevap alanı
                        _buildAnswerField(question),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Gönder butonu
            if (!_isSubmitted) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitResponses,
                  icon: const Icon(Icons.send),
                  label: const Text('Cevapları Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Cevaplarınız başarıyla gönderildi!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerField(EventQuestion question) {
    switch (question.questionType) {
      case 'text':
        return TextFormField(
          decoration: const InputDecoration(
            hintText: 'Cevabınızı yazın...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            _responses[question.id] = value;
          },
        );
      case 'single_choice':
        return Column(
          children: question.options.map((option) {
            return RadioListTile<String>(
              title: Text(option.optionText),
              value: option.id,
              groupValue: _responses[question.id] as String?,
              onChanged: (value) {
                setState(() {
                  _responses[question.id] = value;
                });
              },
            );
          }).toList(),
        );
      case 'multiple_choice':
        return Column(
          children: question.options.map((option) {
            final selectedOptions =
                (_responses[question.id] as List<String>?) ?? [];
            return CheckboxListTile(
              title: Text(option.optionText),
              value: selectedOptions.contains(option.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedOptions.add(option.id);
                  } else {
                    selectedOptions.remove(option.id);
                  }
                  _responses[question.id] = selectedOptions;
                });
              },
            );
          }).toList(),
        );
      default:
        return const Text('Desteklenmeyen soru türü');
    }
  }

  void _submitResponses() {
    // Zorunlu soruları kontrol et
    for (final question in widget.event.questions) {
      if (question.isRequired && !_responses.containsKey(question.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Soru ${widget.event.questions.indexOf(question) + 1} zorunludur',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cevaplarınız başarıyla gönderildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'single_choice':
        return Colors.green;
      case 'multiple_choice':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        return type;
    }
  }
}
