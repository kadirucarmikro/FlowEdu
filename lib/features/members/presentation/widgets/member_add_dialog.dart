import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../groups/presentation/providers/groups_providers.dart';
import '../../../roles/presentation/providers/roles_providers.dart';
import '../../domain/entities/member.dart';
import '../../data/providers/members_providers.dart' as data;
import '../members_page.dart';

class MemberAddDialog extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const MemberAddDialog({super.key, this.onSuccess});

  @override
  ConsumerState<MemberAddDialog> createState() => _MemberAddDialogState();
}

class _MemberAddDialogState extends ConsumerState<MemberAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedRoleId;
  String? _selectedGroupId;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isInstructor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
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
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Yeni Üye Ekle',
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

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Ad *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  Validators.required(v, fieldName: 'Ad'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Soyad *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  Validators.required(v, fieldName: 'Soyad'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-posta *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => Validators.email(v),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Şifre *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Şifre'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v != null && v.isNotEmpty
                            ? Validators.phone(v)
                            : null,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Birth Date
                      TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Doğum Tarihi (GGAAYYYY)',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: 15011990',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (v.length != 8) return 'Tarih formatı: GGAAYYYY';
                          final day = int.tryParse(v.substring(0, 2));
                          final month = int.tryParse(v.substring(2, 4));
                          final year = int.tryParse(v.substring(4, 8));
                          if (day == null || month == null || year == null) {
                            return 'Geçersiz tarih formatı';
                          }
                          if (day < 1 || day > 31 || month < 1 || month > 12) {
                            return 'Geçersiz tarih';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 8) {
                            final day = int.tryParse(value.substring(0, 2));
                            final month = int.tryParse(value.substring(2, 4));
                            final year = int.tryParse(value.substring(4, 8));
                            if (day != null && month != null && year != null) {
                              setState(() {
                                _birthDate = DateTime(year, month, day);
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Eğitmen Checkbox
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: _isInstructor
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Eğitmen Olarak İşaretle',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                title: const Text(
                                  'Bu üye eğitmen olarak işaretlensin',
                                ),
                                value: _isInstructor,
                                onChanged: (value) {
                                  setState(() {
                                    _isInstructor = value ?? false;
                                    if (!_isInstructor) {
                                      // Eğitmen alanlarını temizle
                                      _specializationController.clear();
                                      _bioController.clear();
                                      _experienceController.clear();
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Eğitmen Alanları (Koşullu)
                      if (_isInstructor) ...[
                        Card(
                          color: Colors.green.withValues(alpha: 0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Eğitmen Bilgileri',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _specializationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Uzmanlık Alanı *',
                                    border: OutlineInputBorder(),
                                    hintText:
                                        'Örn: Tango Dansı, Matematik, Fizik',
                                  ),
                                  validator: _isInstructor
                                      ? (v) => v == null || v.isEmpty
                                            ? 'Uzmanlık alanı gereklidir'
                                            : null
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _bioController,
                                  decoration: const InputDecoration(
                                    labelText: 'Biyografi',
                                    border: OutlineInputBorder(),
                                    hintText: 'Eğitmen hakkında kısa bilgi',
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _experienceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Deneyim',
                                    border: OutlineInputBorder(),
                                    hintText: 'Eğitmen deneyimi ve başarıları',
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Role and Group Selection
                      Row(
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final rolesAsync = ref.watch(rolesListProvider);
                                return rolesAsync.when(
                                  loading: () => DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Rol',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [],
                                    onChanged: null,
                                  ),
                                  error: (error, stack) =>
                                      DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Rol',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: const [],
                                        onChanged: null,
                                      ),
                                  data: (roles) {
                                    return DropdownButtonFormField<String>(
                                      initialValue: _selectedRoleId,
                                      decoration: const InputDecoration(
                                        labelText: 'Rol *',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: roles.map((role) {
                                        return DropdownMenuItem<String>(
                                          value: role.id,
                                          child: Text(role.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRoleId = value;
                                        });
                                      },
                                      validator: (v) =>
                                          v == null ? 'Rol seçiniz' : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final groupsAsync = ref.watch(
                                  groupsListProvider,
                                );
                                return groupsAsync.when(
                                  loading: () => DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Grup',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [],
                                    onChanged: null,
                                  ),
                                  error: (error, stack) =>
                                      DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Grup',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: const [],
                                        onChanged: null,
                                      ),
                                  data: (groups) {
                                    return DropdownButtonFormField<String>(
                                      initialValue: _selectedGroupId,
                                      decoration: const InputDecoration(
                                        labelText: 'Grup *',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: groups.map((group) {
                                        return DropdownMenuItem<String>(
                                          value: group.id,
                                          child: Text(group.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGroupId = value;
                                        });
                                      },
                                      validator: (v) =>
                                          v == null ? 'Grup seçiniz' : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Action Buttons
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
                      onPressed: _isLoading ? null : _addMember,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Ekle'),
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

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(data.membersRepositoryProvider);

      // Phone normalization
      final String? phoneText = _phoneController.text.trim().isNotEmpty
          ? Validators.normalizePhone(
              _phoneController.text.trim(),
              defaultCountryCode: '+90',
            )
          : null;

      // Member entity oluştur
      final member = Member(
        id: '', // Yeni member için boş
        userId: '', // Repository'de set edilecek
        roleId: _selectedRoleId!,
        groupId: _selectedGroupId!,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text, // Form'dan alınan şifre
        phone: phoneText,
        birthDate: _birthDate,
        isSuspended: false,
        isInstructor: _isInstructor,
        specialization:
            _isInstructor && _specializationController.text.isNotEmpty
            ? _specializationController.text.trim()
            : null,
        instructorBio: _isInstructor && _bioController.text.isNotEmpty
            ? _bioController.text.trim()
            : null,
        instructorExperience:
            _isInstructor && _experienceController.text.isNotEmpty
            ? _experienceController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await repo.createMember(member);

      // Refresh data
      ref.invalidate(allMembersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni üye başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ekleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
