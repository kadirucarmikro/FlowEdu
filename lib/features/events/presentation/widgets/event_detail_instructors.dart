import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventDetailInstructors extends StatelessWidget {
  const EventDetailInstructors({super.key, required this.event});

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
              const Icon(Icons.school, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Eğitmenler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.instructors.length}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Eğitmen listesi
          if (event.instructors.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz eğitmen eklenmemiş',
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
              itemCount: event.instructors.length,
              itemBuilder: (context, index) {
                final instructor = event.instructors[index];
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
                            instructor.role,
                          ).withOpacity(0.1),
                          child: Icon(
                            _getRoleIcon(instructor.role),
                            color: _getRoleColor(instructor.role),
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
                                'Eğitmen ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getRoleText(instructor.role),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getRoleColor(instructor.role),
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
      case 'instructor':
        return Colors.purple;
      case 'co-instructor':
        return Colors.indigo;
      case 'assistant':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'instructor':
        return Icons.school;
      case 'co-instructor':
        return Icons.people;
      case 'assistant':
        return Icons.assistant;
      default:
        return Icons.person_outline;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'instructor':
        return 'Eğitmen';
      case 'co-instructor':
        return 'Yardımcı Eğitmen';
      case 'assistant':
        return 'Asistan';
      default:
        return role;
    }
  }
}
