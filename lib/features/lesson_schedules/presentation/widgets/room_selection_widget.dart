import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rooms/data/providers/rooms_providers.dart';

class RoomSelectionWidget extends ConsumerWidget {
  final String? selectedRoomId;
  final Function(String?) onRoomSelected;

  const RoomSelectionWidget({
    super.key,
    required this.selectedRoomId,
    required this.onRoomSelected,
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
                '6. Oda Seçimi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final roomsAsync = ref.watch(roomsProvider);

                  return roomsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text(
                      'Odalar yüklenemedi: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    data: (rooms) {
                      if (rooms.isEmpty) {
                        return const Text(
                          'Henüz oda eklenmemiş. Önce oda ekleyin.',
                          style: TextStyle(color: Colors.orange),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Oda Seçiniz *',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedRoomId,
                        items: rooms
                            .map(
                              (room) => DropdownMenuItem(
                                value: room.id,
                                child: Text(
                                  '${room.name} (Kapasite: ${room.capacity})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onRoomSelected,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Oda seçimi zorunludur';
                          }
                          return null;
                        },
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
