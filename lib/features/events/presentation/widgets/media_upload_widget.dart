import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MediaUploadWidget extends StatefulWidget {
  const MediaUploadWidget({
    super.key,
    this.onMediaSelected,
    this.maxFiles = 10,
    this.allowedTypes = const ['image', 'video', 'audio', 'document'],
  });

  final Function(List<MediaFile>)? onMediaSelected;
  final int maxFiles;
  final List<String> allowedTypes;

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final List<MediaFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medya Dosyaları',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: _selectFiles,
              icon: const Icon(Icons.add),
              label: const Text('Dosya Seç'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // File type info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Desteklenen formatlar: ${widget.allowedTypes.join(', ')}. '
                  'Maksimum ${widget.maxFiles} dosya seçebilirsiniz.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected files
        if (_selectedFiles.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: Theme.of(context).dividerColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz dosya seçilmedi',
                    style: TextStyle(
                      color: Theme.of(context).dividerColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return _buildFileItem(file, index);
            },
          ),
      ],
    );
  }

  Widget _buildFileItem(MediaFile file, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getFileIcon(file.type),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${_formatFileSize(file.size)} • ${file.type.toUpperCase()}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.type == 'image')
              IconButton(
                icon: const Icon(Icons.preview),
                onPressed: () => _previewImage(file),
                tooltip: 'Önizle',
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeFile(index),
              tooltip: 'Sil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'image':
        iconData = Icons.image;
        color = Colors.green;
        break;
      case 'video':
        iconData = Icons.video_library;
        color = Colors.red;
        break;
      case 'audio':
        iconData = Icons.audiotrack;
        color = Colors.orange;
        break;
      case 'document':
        iconData = Icons.description;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.attach_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(),
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = <MediaFile>[];

        for (final file in result.files) {
          // Web platformunda path yerine bytes kullan
          String? filePath;
          try {
            filePath = file.path;
          } catch (e) {
            // Web platformunda path kullanılamaz, bytes kullan
            filePath = 'web_file_${DateTime.now().millisecondsSinceEpoch}';
          }

          if (filePath != null) {
            final mediaFile = MediaFile(
              name: file.name,
              path: filePath,
              size: file.size,
              type: _getFileType(file.extension ?? ''),
              bytes: file.bytes, // Web için bytes ekle
            );

            if (widget.allowedTypes.contains(mediaFile.type)) {
              newFiles.add(mediaFile);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dosya türü desteklenmiyor: ${mediaFile.type}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {}
        }

        if (newFiles.length + _selectedFiles.length > widget.maxFiles) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Maksimum ${widget.maxFiles} dosya seçebilirsiniz.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        setState(() {
          _selectedFiles.addAll(newFiles);
        });

        widget.onMediaSelected?.call(_selectedFiles);
      } else {}
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya seçme hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Detay',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hata Detayı'),
                  content: Text('$e\n\n$stackTrace'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  List<String> _getAllowedExtensions() {
    final extensions = <String>[];

    if (widget.allowedTypes.contains('image')) {
      extensions.addAll(['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']);
    }
    if (widget.allowedTypes.contains('video')) {
      extensions.addAll(['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm']);
    }
    if (widget.allowedTypes.contains('audio')) {
      extensions.addAll(['mp3', 'wav', 'aac', 'ogg', 'm4a']);
    }
    if (widget.allowedTypes.contains('document')) {
      extensions.addAll(['pdf', 'doc', 'docx', 'txt', 'rtf']);
    }

    return extensions;
  }

  String _getFileType(String extension) {
    final ext = extension.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(ext)) {
      return 'video';
    } else if (['mp3', 'wav', 'aac', 'ogg', 'm4a'].contains(ext)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(ext)) {
      return 'document';
    }

    return 'unknown';
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onMediaSelected?.call(_selectedFiles);
  }

  Widget _buildImagePreview(MediaFile file) {
    // Web platformunda bytes kullan, diğer platformlarda path kullan
    if (file.bytes != null) {
      // Web platformu - bytes kullan
      return Image.memory(
        file.bytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget('Resim yüklenemedi: $error');
        },
      );
    } else {
      // Diğer platformlar - path kullan
      return Image.file(
        File(file.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget('Resim yüklenemedi: $error');
        },
      );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _previewImage(MediaFile file) {
    try {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          file.name,
                          style: Theme.of(context).textTheme.titleLarge,
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
                Expanded(child: _buildImagePreview(file)),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim önizleme hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class MediaFile {
  final String name;
  final String path;
  final int size;
  final String type;
  final Uint8List? bytes; // Web platformu için bytes

  MediaFile({
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    this.bytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'type': type,
      'bytes': bytes?.toList(), // Web için bytes'ı list olarak kaydet
    };
  }

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      bytes: json['bytes'] != null
          ? Uint8List.fromList((json['bytes'] as List).cast<int>())
          : null,
    );
  }
}
