import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/screen.dart';
import '../providers/screens_providers.dart';

class ScreenFormDialog extends ConsumerStatefulWidget {
  final Screen? screen;

  const ScreenFormDialog({super.key, this.screen});

  @override
  ConsumerState<ScreenFormDialog> createState() => _ScreenFormDialogState();
}

class _ScreenFormDialogState extends ConsumerState<ScreenFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _routeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.screen != null) {
      _nameController.text = widget.screen!.name;
      _routeController.text = widget.screen!.route;
      _descriptionController.text = widget.screen!.description ?? '';
      _isActive = widget.screen!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _routeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.screen != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AlertDialog(
      title: Text(isEditing ? 'Ekranı Düzenle' : 'Yeni Ekran Ekle'),
      content: SizedBox(
        width: isMobile ? double.infinity : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Temel Bilgiler
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ekran Adı *',
                        hintText: 'Örn: Üyelik, Roller, Gruplar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ekran adı zorunludur';
                        }
                        if (value.trim().length < 2) {
                          return 'En az 2 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _routeController,
                      decoration: const InputDecoration(
                        labelText: 'Route *',
                        hintText: '/members, /roles',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Route zorunludur';
                        }
                        if (!value.startsWith('/')) {
                          return 'Route / ile başlamalıdır';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Ekran hakkında kısa açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Durum
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Güncelle' : 'Oluştur'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.screen != null) {
        // Update screen
        final updateScreen = ref.read(updateScreenProvider);
        await updateScreen(
          id: widget.screen!.id,
          name: _nameController.text.trim(),
          route: _routeController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(screensListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ekran başarıyla güncellendi')),
          );
        }
      } else {
        // Create screen
        final createScreen = ref.read(createScreenProvider);
        await createScreen(
          name: _nameController.text.trim(),
          route: _routeController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(screensListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ekran başarıyla oluşturuldu')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
