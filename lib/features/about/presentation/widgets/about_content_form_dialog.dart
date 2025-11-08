import 'package:flutter/material.dart';
import '../../domain/entities/about_content.dart';

class AboutContentFormDialog extends StatefulWidget {
  final AboutContent? content;
  final Function(AboutContent) onSave;

  const AboutContentFormDialog({super.key, this.content, required this.onSave});

  @override
  State<AboutContentFormDialog> createState() => _AboutContentFormDialogState();
}

class _AboutContentFormDialogState extends State<AboutContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _contentTextController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  final _sortOrderController = TextEditingController();

  ContentType _selectedType = ContentType.text;
  bool _isActive = true;

  // Predefined slugs for the 6 main sections
  final List<String> _predefinedSlugs = [
    'hakkimizda',
    'egitmenlerimiz',
    'asistanlarimiz',
    'uyelik-kurallari',
    'ders-politikamiz',
    'yaptiklarimiz',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.content != null) {
      _titleController.text = widget.content!.title;
      _slugController.text = widget.content!.slug;
      _contentTextController.text = widget.content!.contentText ?? '';
      _mediaUrlController.text = widget.content!.mediaUrl ?? '';
      _sortOrderController.text = widget.content!.sortOrder.toString();
      _selectedType = widget.content!.type;
      _isActive = widget.content!.isActive;
    } else {
      _sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _contentTextController.dispose();
    _mediaUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.content == null ? 'Yeni İçerik' : 'İçerik Düzenle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _slugController.text.isNotEmpty
                    ? _slugController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Slug *',
                  border: OutlineInputBorder(),
                ),
                items: _predefinedSlugs.map((slug) {
                  return DropdownMenuItem(value: slug, child: Text(slug));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _slugController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Slug gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ContentType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'İçerik Türü *',
                  border: OutlineInputBorder(),
                ),
                items: ContentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == ContentType.text) ...[
                TextFormField(
                  controller: _contentTextController,
                  decoration: const InputDecoration(
                    labelText: 'İçerik Metni',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
              ],
              if (_selectedType == ContentType.image ||
                  _selectedType == ContentType.video) ...[
                TextFormField(
                  controller: _mediaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Medya URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/image.jpg',
                  ),
                  validator: (value) {
                    if (_selectedType != ContentType.text &&
                        (value == null || value.isEmpty)) {
                      return 'Medya URL gereklidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(
                  labelText: 'Sıralama',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sıralama gereklidir';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Geçerli bir sayı giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                  ),
                  const Text('Aktif'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveContent,
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveContent() {
    if (_formKey.currentState!.validate()) {
      final content = AboutContent(
        id: widget.content?.id ?? '',
        slug: _slugController.text,
        title: _titleController.text,
        type: _selectedType,
        contentText: _contentTextController.text.isNotEmpty
            ? _contentTextController.text
            : null,
        mediaUrl: _mediaUrlController.text.isNotEmpty
            ? _mediaUrlController.text
            : null,
        sortOrder: int.parse(_sortOrderController.text),
        isActive: _isActive,
        createdAt: widget.content?.createdAt ?? DateTime.now(),
      );

      widget.onSave(content);
    }
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
}
