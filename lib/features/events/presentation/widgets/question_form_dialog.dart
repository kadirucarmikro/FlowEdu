import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../providers/events_providers.dart';

class QuestionFormDialog extends ConsumerStatefulWidget {
  const QuestionFormDialog({super.key, this.question, required this.onSave});

  final EventQuestion? question;
  final Function(EventQuestion) onSave;

  @override
  ConsumerState<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends ConsumerState<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();

  String _questionType = 'text';
  bool _isRequired = false;
  int _sortOrder = 0;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionTextController.text = widget.question!.questionText;
      _questionType = widget.question!.questionType;
      _isRequired = widget.question!.isRequired;
      _sortOrder = widget.question!.sortOrder;

      // Load question options if they exist
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadQuestionOptions();
      });
    }
  }

  Future<void> _loadQuestionOptions() async {
    if (widget.question != null &&
        (widget.question!.questionType == 'single_choice' ||
            widget.question!.questionType == 'multiple_choice')) {
      setState(() {
        _optionControllers.clear();

        // Önce widget.question'dan mevcut seçenekleri yükle
        if (widget.question!.options.isNotEmpty) {
          for (final option in widget.question!.options) {
            _optionControllers.add(
              TextEditingController(text: option.optionText),
            );
          }
        } else {
          // Eğer widget'ta seçenek yoksa ve soru database'de varsa, database'den yükle
          try {
            _loadOptionsFromDatabase();
          } catch (e) {
            // Hata durumunda sessizce devam et
          }
        }
      });
    }
  }

  Future<void> _loadOptionsFromDatabase() async {
    if (widget.question != null && widget.question!.id.isNotEmpty) {
      try {
        final eventsRepository = ref.read(eventsRepositoryProvider);
        final options = await eventsRepository.getQuestionOptions(
          widget.question!.id,
        );

        setState(() {
          _optionControllers.clear();
          for (final option in options) {
            _optionControllers.add(
              TextEditingController(text: option.optionText),
            );
          }
        });
      } catch (e) {
        // Hata durumunda sessizce devam et
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.quiz, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.question == null
                            ? 'Yeni Soru Ekle'
                            : 'Soruyu Düzenle',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Soru metni
                      TextFormField(
                        controller: _questionTextController,
                        decoration: const InputDecoration(
                          labelText: 'Soru Metni *',
                          hintText: 'Sorunuzu yazın...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.quiz),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Soru metni gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Soru türü
                      DropdownButtonFormField<String>(
                        initialValue: _questionType,
                        decoration: const InputDecoration(
                          labelText: 'Soru Türü *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'text',
                            child: Text('Metin Yanıtı'),
                          ),
                          DropdownMenuItem(
                            value: 'single_choice',
                            child: Text('Tek Seçim'),
                          ),
                          DropdownMenuItem(
                            value: 'multiple_choice',
                            child: Text('Çoklu Seçim'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _questionType = value!;
                            if (_questionType == 'text') {
                              _optionControllers.clear();
                            } else if (_optionControllers.isEmpty) {
                              _addOption();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Zorunlu soru
                      SwitchListTile(
                        title: const Text('Zorunlu Soru'),
                        subtitle: const Text(
                          'Bu soru zorunlu olarak yanıtlanmalı',
                        ),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sıralama
                      TextFormField(
                        initialValue: _sortOrder.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Sıralama',
                          hintText: '0',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sort),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _sortOrder = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Seçenekler (sadece seçimli sorular için)
                      if (_questionType != 'text') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seçenekler',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ElevatedButton.icon(
                              onPressed: _addOption,
                              icon: const Icon(Icons.add),
                              label: const Text('Seçenek Ekle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_optionControllers.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Henüz seçenek eklenmemiş',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _optionControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _optionControllers[index],
                                        decoration: InputDecoration(
                                          labelText: 'Seçenek ${index + 1}',
                                          border: const OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Seçenek metni gerekli';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _removeOption(index),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveQuestion,
                      child: Text(
                        widget.question == null ? 'Ekle' : 'Güncelle',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_questionType != 'text' && _optionControllers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seçimli sorular için en az bir seçenek eklemelisiniz',
            ),
          ),
        );
        return;
      }

      final options = _optionControllers
          .map(
            (controller) => EventQuestionOption(
              id: '', // Will be generated by database
              questionId: '', // Will be set when saving
              optionText: controller.text,
              sortOrder: _optionControllers.indexOf(controller),
              createdAt: DateTime.now(),
            ),
          )
          .toList();

      final question = EventQuestion(
        id: widget.question?.id ?? '', // Will be generated by database
        eventId: '', // Will be set when saving
        questionText: _questionTextController.text,
        questionType: _questionType,
        isRequired: _isRequired,
        sortOrder: _sortOrder,
        createdAt: widget.question?.createdAt ?? DateTime.now(),
        options: options,
      );

      widget.onSave(question);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
