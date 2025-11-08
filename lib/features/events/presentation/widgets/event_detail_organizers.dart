import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventDetailOrganizers extends StatelessWidget {
  const EventDetailOrganizers({super.key, required this.event});

  final Event event;

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
              const Icon(Icons.people, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Organizatörler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.organizers.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Organizatör listesi
          if (event.organizers.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz organizatör eklenmemiş',
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
              itemCount: event.organizers.length,
              itemBuilder: (context, index) {
                final organizer = event.organizers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _getRoleColor(
                            organizer.role,
                          ).withOpacity(0.1),
                          child: Icon(
                            _getRoleIcon(organizer.role),
                            color: _getRoleColor(organizer.role),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Bilgiler
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organizatör ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getRoleText(organizer.role),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getRoleColor(organizer.role),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'organizer':
        return Colors.blue;
      case 'co-organizer':
        return Colors.green;
      case 'assistant':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'organizer':
        return Icons.person;
      case 'co-organizer':
        return Icons.people;
      case 'assistant':
        return Icons.assistant;
      default:
        return Icons.person_outline;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'organizer':
        return 'Organizatör';
      case 'co-organizer':
        return 'Yardımcı Organizatör';
      case 'assistant':
        return 'Asistan';
      default:
        return role;
    }
  }
}
