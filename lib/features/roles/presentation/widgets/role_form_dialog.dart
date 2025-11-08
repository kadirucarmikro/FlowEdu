import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/role.dart';
import '../providers/roles_providers.dart';

class RoleFormDialog extends ConsumerStatefulWidget {
  final Role? role;

  const RoleFormDialog({super.key, this.role});

  @override
  ConsumerState<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends ConsumerState<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _isActive = widget.role!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.role != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AlertDialog(
      title: Text(isEditing ? 'Rolü Düzenle' : 'Yeni Rol Ekle'),
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
                  labelText: 'Rol Adı',
                  hintText: 'Örn: Admin, Üye, Yönetici',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rol adı zorunludur';
                  }
                  if (value.trim().length < 2) {
                    return 'Rol adı en az 2 karakter olmalıdır';
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
      if (widget.role != null) {
        // Update role
        final updateRole = ref.read(updateRoleProvider);
        await updateRole(
          id: widget.role!.id,
          name: _nameController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(rolesListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol başarıyla güncellendi')),
          );
        }
      } else {
        // Create role
        final createRole = ref.read(createRoleProvider);
        await createRole(
          name: _nameController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ref.invalidate(rolesListProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol başarıyla oluşturuldu')),
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
