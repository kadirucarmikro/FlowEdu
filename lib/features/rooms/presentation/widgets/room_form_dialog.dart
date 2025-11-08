import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/rooms_providers.dart';
import '../../domain/entities/room.dart';

class RoomFormDialog extends ConsumerStatefulWidget {
  final Room? room;
  final VoidCallback? onSuccess;

  const RoomFormDialog({super.key, this.room, this.onSuccess});

  @override
  ConsumerState<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends ConsumerState<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _featuresController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.room != null) {
      _nameController.text = widget.room!.name;
      _capacityController.text = widget.room!.capacity.toString();
      _featuresController.text = widget.room!.features ?? '';
      _isActive = widget.room!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.room == null ? Icons.add : Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.room == null ? 'Yeni Oda Ekle' : 'Oda Düzenle',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Oda Adı
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Oda Adı *',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: A-101, Dans Salonu-1',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Oda adı gereklidir';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kapasite
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Kapasite *',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: 15, 20, 25',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kapasite gereklidir';
                          }
                          final capacity = int.tryParse(value.trim());
                          if (capacity == null || capacity <= 0) {
                            return 'Geçerli bir kapasite giriniz';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Özellikler
                      TextFormField(
                        controller: _featuresController,
                        decoration: const InputDecoration(
                          labelText: 'Özellikler',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: Projeksiyon, Ayna, Ses sistemi',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Aktif/Pasif
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.toggle_on,
                                    color: _isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Durum',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: const Text('Aktif'),
                                subtitle: Text(
                                  _isActive
                                      ? 'Oda kullanılabilir'
                                      : 'Oda kullanılamaz',
                                ),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveRoom,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.room == null ? 'Ekle' : 'Güncelle'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(roomsRepositoryProvider);
      final capacity = int.parse(_capacityController.text.trim());

      final room = Room(
        id: widget.room?.id ?? '',
        name: _nameController.text.trim(),
        capacity: capacity,
        features: _featuresController.text.trim().isNotEmpty
            ? _featuresController.text.trim()
            : null,
        isActive: _isActive,
        createdAt: widget.room?.createdAt ?? DateTime.now(),
      );

      if (widget.room == null) {
        await repository.createRoom(room);
      } else {
        await repository.updateRoom(room);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.room == null
                  ? 'Oda başarıyla eklendi'
                  : 'Oda başarıyla güncellendi',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
