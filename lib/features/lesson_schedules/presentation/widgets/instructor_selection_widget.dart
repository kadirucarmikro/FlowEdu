import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../members/data/providers/members_providers.dart';

class InstructorSelectionWidget extends ConsumerWidget {
  final List<String> selectedInstructorIds;
  final Function(List<String>) onInstructorIdsChanged;

  const InstructorSelectionWidget({
    super.key,
    required this.selectedInstructorIds,
    required this.onInstructorIdsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5. Eğitmen Seçimi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu ders programı için eğitmen seçiniz (Birden fazla seçebilirsiniz)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final instructorsAsync = ref.watch(instructorMembersProvider);

                  return instructorsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Hata: $error'),
                    data: (instructors) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: instructors.map((instructor) {
                          bool isSelected = selectedInstructorIds.contains(
                            instructor.id,
                          );

                          return FilterChip(
                            label: Text(instructor.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              List<String> newSelectedIds = List.from(
                                selectedInstructorIds,
                              );
                              if (selected) {
                                newSelectedIds.add(instructor.id);
                              } else {
                                newSelectedIds.remove(instructor.id);
                              }
                              onInstructorIdsChanged(newSelectedIds);
                            },
                            selectedColor: Colors.green.withOpacity(0.2),
                            checkmarkColor: Colors.green,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
