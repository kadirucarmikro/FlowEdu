import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventDetailMedia extends StatelessWidget {
  const EventDetailMedia({super.key, required this.event});

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
              const Icon(Icons.attach_file, color: Colors.teal, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Medya Dosyaları',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.media.length}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medya listesi
          if (event.media.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.attach_file_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz medya dosyası eklenmemiş',
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: event.media.length,
              itemBuilder: (context, index) {
                final media = event.media[index];
                return Card(
                  child: InkWell(
                    onTap: () => _showMediaPreview(context, media),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medya önizleme
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade100,
                              ),
                              child: _buildMediaPreview(media),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dosya bilgileri
                          Text(
                            media.fileName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getFileTypeIcon(media.fileType),
                                size: 12,
                                color: _getFileTypeColor(media.fileType),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getFileTypeText(media.fileType),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getFileTypeColor(media.fileType),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatFileSize(media.fileSize ?? 0),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildMediaPreview(EventMedia media) {
    if (media.fileType == 'image') {
      return _buildImagePreview(media);
    } else {
      return _buildFilePreview(media);
    }
  }

  Widget _buildImagePreview(EventMedia media) {
    if (media.fileUrl.startsWith('data:image/')) {
      // Base64 image
      try {
        final base64String = media.fileUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFilePreview(media);
            },
          ),
        );
      } catch (e) {
        return _buildFilePreview(media);
      }
    } else if (media.fileUrl.startsWith('http')) {
      // Network image
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          media.fileUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFilePreview(media);
          },
        ),
      );
    } else {
      return _buildFilePreview(media);
    }
  }

  Widget _buildFilePreview(EventMedia media) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileTypeIcon(media.fileType),
            size: 32,
            color: _getFileTypeColor(media.fileType),
          ),
          const SizedBox(height: 8),
          Text(
            _getFileTypeText(media.fileType),
            style: TextStyle(
              fontSize: 12,
              color: _getFileTypeColor(media.fileType),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaPreview(BuildContext context, EventMedia media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        media.fileName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Medya içeriği
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: media.fileType == 'image'
                      ? _buildImagePreview(media)
                      : _buildFileInfo(media),
                ),
              ),

              // Alt bilgiler
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getFileTypeIcon(media.fileType),
                      size: 16,
                      color: _getFileTypeColor(media.fileType),
                    ),
                    const SizedBox(width: 8),
                    Text(_getFileTypeText(media.fileType)),
                    const Spacer(),
                    Text(_formatFileSize(media.fileSize ?? 0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo(EventMedia media) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileTypeIcon(media.fileType),
            size: 64,
            color: _getFileTypeColor(media.fileType),
          ),
          const SizedBox(height: 16),
          Text(
            _getFileTypeText(media.fileType),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu dosya türü önizlenemiyor',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      case 'document':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType) {
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.green;
      case 'document':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getFileTypeText(String fileType) {
    switch (fileType) {
      case 'image':
        return 'Resim';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Ses';
      case 'document':
        return 'Doküman';
      default:
        return fileType;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
