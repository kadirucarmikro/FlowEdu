import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/group.dart';
import '../providers/groups_providers.dart';

class GroupFormDialog extends ConsumerStatefulWidget {
  final Group? group;

  const GroupFormDialog({super.key, this.group});

  @override
  ConsumerState<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends ConsumerState<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _isActive = widget.group!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.group != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AlertDialog(
      title: Text(isEditing ? 'Grubu Düzenle' : 'Yeni Grup Ekle'),
      content: SizedBox(
        width: isMobile ? double.infinity : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Grup Adı',
                  hintText: 'Örn: Yönetim, Üyeler, Eğitmenler',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Grup adı zorunludur';
                  }
                  if (value.trim().length < 2) {
                    return 'Grup adı en az 2 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              SizedBox(height: isMobile ? 12 : 16),
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
              ? SizedBox(
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
      if (widget.group != null) {
        // Update group
        final updateGroup = ref.read(updateGroupProvider);
        await updateGroup(
          id: widget.group!.id,
          name: _nameController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(groupsListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grup başarıyla güncellendi')),
          );
        }
      } else {
        // Create group
        final createGroup = ref.read(createGroupProvider);
        await createGroup(
          name: _nameController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(groupsListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grup başarıyla oluşturuldu')),
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
