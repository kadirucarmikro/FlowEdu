import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventFormDialog extends StatefulWidget {
  const EventFormDialog({super.key, this.event, required this.onSave});

  final Event? event;
  final Function(Map<String, dynamic>) onSave;

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  EventType _selectedType = EventType.normal;
  bool _isMultipleChoice = false;
  DateTime? _startAt;
  DateTime? _endAt;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _imageUrlController.text = widget.event!.imageUrl ?? '';
      _selectedType = widget.event!.type;
      _isMultipleChoice = widget.event!.isMultipleChoice;
      _startAt = widget.event!.startAt;
      _endAt = widget.event!.endAt;

      // Initialize option controllers
      for (final option in widget.event!.options) {
        _optionControllers.add(TextEditingController(text: option.optionText));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.event == null ? 'Yeni Etkinlik' : 'Etkinlik Düzenle',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Başlık gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Resim URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EventType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Etkinlik Türü',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          String label;
                          switch (type) {
                            case EventType.normal:
                              label = 'Normal';
                              break;
                            case EventType.interactive:
                              label = 'Etkileşimli';
                              break;
                            case EventType.poll:
                              label = 'Anket';
                              break;
                            case EventType.workshop:
                              label = 'Atölye';
                              break;
                            case EventType.seminar:
                              label = 'Seminer';
                              break;
                            case EventType.conference:
                              label = 'Konferans';
                              break;
                          }
                          return DropdownMenuItem(
                            value: type,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedType != EventType.normal) ...[
                        SwitchListTile(
                          title: const Text('Çoklu Seçim'),
                          subtitle: const Text(
                            'Kullanıcılar birden fazla seçenek seçebilir',
                          ),
                          value: _isMultipleChoice,
                          onChanged: (value) {
                            setState(() {
                              _isMultipleChoice = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDateTimeFields(),
                        const SizedBox(height: 16),
                        _buildOptionsSection(),
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveEvent,
                      child: Text(
                        widget.event == null ? 'Oluştur' : 'Güncelle',
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

  Widget _buildDateTimeFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Başlangıç Tarihi'),
                subtitle: Text(
                  _startAt != null
                      ? '${_startAt!.day}/${_startAt!.month}/${_startAt!.year} ${_startAt!.hour}:${_startAt!.minute.toString().padLeft(2, '0')}'
                      : 'Seçilmedi',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDateTime,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _startAt = null;
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Bitiş Tarihi'),
                subtitle: Text(
                  _endAt != null
                      ? '${_endAt!.day}/${_endAt!.month}/${_endAt!.year} ${_endAt!.hour}:${_endAt!.minute.toString().padLeft(2, '0')}'
                      : 'Seçilmedi',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDateTime,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _endAt = null;
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Seçenekler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              tooltip: 'Seçenek Ekle',
            ),
          ],
        ),
        ...List.generate(_optionControllers.length, (index) {
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
                  ),
                ),
                IconButton(
                  onPressed: () => _removeOption(index),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _startAt != null
            ? TimeOfDay.fromDateTime(_startAt!)
            : TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _startAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endAt ?? (_startAt ?? DateTime.now()),
      firstDate: _startAt ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _endAt != null
            ? TimeOfDay.fromDateTime(_endAt!)
            : TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _endAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final optionTexts = _optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      widget.onSave({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        'type': _selectedType,
        'isMultipleChoice': _isMultipleChoice,
        'startAt': _startAt,
        'endAt': _endAt,
        'optionTexts': optionTexts,
      });
    }
  }
}
