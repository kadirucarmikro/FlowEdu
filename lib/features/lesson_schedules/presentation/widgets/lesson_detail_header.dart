import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonDetailHeader extends StatelessWidget {
  final VoidCallback onClose;
  final String? scheduleId;

  const LessonDetailHeader({super.key, required this.onClose, this.scheduleId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ders Detayı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          if (scheduleId != null) ...[
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(); // Popup'ı kapat
                context.go('/lesson-schedules/$scheduleId/edit');
              },
              icon: const Icon(Icons.edit, color: Colors.orange),
              tooltip: 'Düzenle',
            ),
            const SizedBox(width: 8),
          ],
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
