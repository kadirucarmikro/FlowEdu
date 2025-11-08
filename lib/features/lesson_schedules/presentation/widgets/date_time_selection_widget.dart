import 'package:flutter/material.dart';

class DateTimeSelectionWidget extends StatelessWidget {
  final DateTime? startDate;
  final List<String> selectedDays;
  final String lessonDuration;
  final TimeOfDay startTime;
  final bool useSameTimeForAllDays;
  final Map<String, TimeOfDay> dayTimes;
  final Function(DateTime?) onStartDateChanged;
  final Function(List<String>) onSelectedDaysChanged;
  final Function(String) onLessonDurationChanged;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(bool) onUseSameTimeChanged;
  final Function(Map<String, TimeOfDay>) onDayTimesChanged;

  const DateTimeSelectionWidget({
    super.key,
    required this.startDate,
    required this.selectedDays,
    required this.lessonDuration,
    required this.startTime,
    required this.useSameTimeForAllDays,
    required this.dayTimes,
    required this.onStartDateChanged,
    required this.onSelectedDaysChanged,
    required this.onLessonDurationChanged,
    required this.onStartTimeChanged,
    required this.onUseSameTimeChanged,
    required this.onDayTimesChanged,
  });

  static const List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _dayLabels = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  String _getDayName(String day) {
    final index = _daysOfWeek.indexOf(day);
    return index >= 0 ? _dayLabels[index] : day;
  }

  String? _getStartDateDayOfWeek() {
    if (startDate == null) return null;
    const daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return daysOfWeek[startDate!.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start Date Selection
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2. Paket Başlangıç Tarihi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        onStartDateChanged(date);
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
                            startDate != null
                                ? _formatDate(startDate!)
                                : 'Başlangıç tarihi seçiniz',
                            style: TextStyle(
                              color: startDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Days Selection
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3. Haftalık Ders Günleri Seçimi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hangi günlerde ders yapılacak? (Birden fazla seçebilirsiniz)',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _daysOfWeek.asMap().entries.map((entry) {
                      int index = entry.key;
                      String day = entry.value;
                      bool isSelected = selectedDays.contains(day);
                      bool isStartDateDay = day == _getStartDateDayOfWeek();

                      return GestureDetector(
                        onTap: () {
                          List<String> newSelectedDays = List.from(
                            selectedDays,
                          );
                          if (isSelected) {
                            newSelectedDays.remove(day);
                          } else {
                            newSelectedDays.add(day);
                          }
                          onSelectedDaysChanged(newSelectedDays);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isStartDateDay
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.15))
                                : (isStartDateDay
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1)),
                            border: Border.all(
                              color: isSelected
                                  ? (isStartDateDay
                                        ? Colors.orange
                                        : Colors.blue)
                                  : (isStartDateDay
                                        ? Colors.orange.withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.3)),
                              width: isSelected ? 2 : (isStartDateDay ? 2 : 1),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : (isStartDateDay
                                          ? Icons.star
                                          : Icons.radio_button_unchecked),
                                color: isSelected
                                    ? (isStartDateDay
                                          ? Colors.orange
                                          : Colors.blue)
                                    : (isStartDateDay
                                          ? Colors.orange[600]
                                          : Colors.grey[600]),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dayLabels[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? (isStartDateDay
                                            ? Colors.orange[800]
                                            : Colors.blue[800])
                                      : (isStartDateDay
                                            ? Colors.orange[700]
                                            : Colors.grey[700]),
                                  fontWeight: isSelected || isStartDateDay
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Lesson Duration
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '4. Ders Süresi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: lessonDuration,
                    decoration: const InputDecoration(
                      labelText: 'Ders Süresi (Dakika)',
                      border: OutlineInputBorder(),
                      hintText: '60',
                      suffixText: 'dakika',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onLessonDurationChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ders süresi gereklidir';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Geçerli bir süre giriniz';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Start Time Selection
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '4.5. Başlangıç Saati',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Time selection mode
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Tüm günler aynı saat'),
                          value: true,
                          groupValue: useSameTimeForAllDays,
                          onChanged: (value) {
                            onUseSameTimeChanged(value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Her gün farklı saat'),
                          value: false,
                          groupValue: useSameTimeForAllDays,
                          onChanged: (value) {
                            onUseSameTimeChanged(value!);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Time selection UI
                  if (useSameTimeForAllDays) ...[
                    // Same time for all days
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedDays.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.05),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: Colors.green[700],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Seçilen Günler İçin Ortak Saat',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  children: selectedDays.map((day) {
                                    final dayIndex = _daysOfWeek.indexOf(day);
                                    final isStartDateDay =
                                        day == _getStartDateDayOfWeek();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isStartDateDay
                                            ? Colors.orange.withOpacity(0.15)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isStartDateDay
                                              ? Colors.orange.withOpacity(0.4)
                                              : Colors.green.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isStartDateDay
                                                ? Icons.star
                                                : Icons.check_circle,
                                            color: isStartDateDay
                                                ? Colors.orange[600]
                                                : Colors.green[600],
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _dayLabels[dayIndex],
                                            style: TextStyle(
                                              color: isStartDateDay
                                                  ? Colors.orange[700]
                                                  : Colors.green[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              onStartTimeChanged(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green.withOpacity(0.05),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Başlangıç Saati: ${startTime.format(context)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.green[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Different time for each day
                    if (selectedDays.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.blue[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Seçilen Günler İçin Saat Ayarları',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Her gün için farklı saat belirleyebilirsiniz',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedDays.map((day) {
                        final dayTime = dayTimes[day] ?? startTime;
                        final isStartDateDay = day == _getStartDateDayOfWeek();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: dayTime,
                              );
                              if (picked != null) {
                                Map<String, TimeOfDay> newDayTimes = Map.from(
                                  dayTimes,
                                );
                                newDayTimes[day] = picked;
                                onDayTimesChanged(newDayTimes);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isStartDateDay
                                      ? Colors.orange.withOpacity(0.4)
                                      : Colors.blue.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: isStartDateDay
                                    ? Colors.orange.withOpacity(0.08)
                                    : Colors.blue.withOpacity(0.05),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isStartDateDay
                                        ? Icons.star
                                        : Icons.check_circle,
                                    color: isStartDateDay
                                        ? Colors.orange[600]
                                        : Colors.blue[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_getDayName(day)}: ${dayTime.format(context)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isStartDateDay
                                          ? Colors.orange[800]
                                          : Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: isStartDateDay
                                        ? Colors.orange[600]
                                        : Colors.blue[600],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      const Text(
                        'Önce günleri seçin',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
