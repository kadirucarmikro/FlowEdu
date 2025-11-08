import 'package:flutter/material.dart';
import '../../domain/entities/about_content.dart';

class AboutContentCard extends StatelessWidget {
  final AboutContent content;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AboutContentCard({
    super.key,
    required this.content,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Düzenle',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Sil',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(
                  context,
                  _getTypeLabel(content.type),
                  _getTypeColor(content.type),
                ),
                const SizedBox(width: 8),
                _buildChip(context, content.slug, Colors.grey),
                const SizedBox(width: 8),
                _buildChip(
                  context,
                  content.isActive ? 'Aktif' : 'Pasif',
                  content.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            if (content.contentText != null) ...[
              const SizedBox(height: 12),
              Text(
                content.contentText!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (content.mediaUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: content.type == ContentType.image
                      ? Image.network(
                          content.mediaUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 48),
                            );
                          },
                        )
                      : content.type == ContentType.video
                      ? const Center(
                          child: Icon(Icons.play_circle_outline, size: 48),
                        )
                      : const Center(child: Icon(Icons.attach_file, size: 48)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Oluşturulma: ${_formatDate(content.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.text:
        return 'Metin';
      case ContentType.image:
        return 'Resim';
      case ContentType.video:
        return 'Video';
    }
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.text:
        return Colors.blue;
      case ContentType.image:
        return Colors.green;
      case ContentType.video:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
