import 'package:flutter/material.dart';

class LessonRescheduleDialog extends StatefulWidget {
  final Function(DateTime newDateTime, String reason) onReschedule;

  const LessonRescheduleDialog({super.key, required this.onReschedule});

  @override
  State<LessonRescheduleDialog> createState() => _LessonRescheduleDialogState();
}

class _LessonRescheduleDialogState extends State<LessonRescheduleDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dersi Yeniden Planla'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tarih Seçimi
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Yeni tarih seçiniz',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Saat Seçimi
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      _selectedTime ?? const TimeOfDay(hour: 19, minute: 0),
                );
                if (time != null && mounted) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Yeni saat seçiniz',
                      style: TextStyle(
                        color: _selectedTime != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sebep
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Yeniden planlama sebebi',
                hintText: 'Örn: Hasta olduğum için',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _selectedDate != null && _selectedTime != null
              ? () {
                  final newDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                  widget.onReschedule(newDateTime, _reasonController.text);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Yeniden Planla'),
        ),
      ],
    );
  }
}
