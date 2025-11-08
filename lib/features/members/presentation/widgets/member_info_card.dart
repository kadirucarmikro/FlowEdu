import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/member_entity.dart';
import '../../data/members_repository_impl.dart';

final membersRepositoryProvider = Provider<MembersRepositoryImpl>((ref) {
  return MembersRepositoryImpl(Supabase.instance.client);
});

// Authentication state değişikliğini dinleyen provider
final authStateProvider = StreamProvider((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentMemberProvider = FutureProvider<MemberEntity?>((ref) async {
  // Authentication state değişikliğini dinle
  ref.watch(authStateProvider);

  final repo = ref.read(membersRepositoryProvider);
  return await repo.getCurrentMember();
});

class MemberInfoCard extends ConsumerStatefulWidget {
  final MemberEntity member;

  const MemberInfoCard({super.key, required this.member});

  @override
  ConsumerState<MemberInfoCard> createState() => _MemberInfoCardState();
}

class _MemberInfoCardState extends ConsumerState<MemberInfoCard> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _birthDate;
  bool _editMode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstName.text = widget.member.firstName;
    _lastName.text = widget.member.lastName;
    _phone.text = widget.member.phone ?? '';
    _birthDate = widget.member.birthDate;

    if (_birthDate != null) {
      _birthDateController.text =
          '${_birthDate!.day.toString().padLeft(2, '0')}${_birthDate!.month.toString().padLeft(2, '0')}${_birthDate!.year}';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kişisel Bilgilerim',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_editMode)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _editMode = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_editMode) ...[
              // Edit Mode - Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstName,
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
                            controller: _lastName,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefon',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v != null && v.isNotEmpty
                                ? Validators.phone(v)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _birthDateController,
                            decoration: const InputDecoration(
                              labelText: 'Doğum Tarihi (GGAAYYYY)',
                              hintText: 'Örn: 15011990',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              if (value.length == 8) {
                                final day = int.tryParse(value.substring(0, 2));
                                final month = int.tryParse(
                                  value.substring(2, 4),
                                );
                                final year = int.tryParse(
                                  value.substring(4, 8),
                                );
                                if (day != null &&
                                    month != null &&
                                    year != null) {
                                  _birthDate = DateTime(year, month, day);
                                }
                              }
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              if (v.length != 8) {
                                return 'Tarih formatı: GGAAYYYY';
                              }
                              final day = int.tryParse(v.substring(0, 2));
                              final month = int.tryParse(v.substring(2, 4));
                              final year = int.tryParse(v.substring(4, 8));
                              if (day == null ||
                                  month == null ||
                                  year == null) {
                                return 'Geçersiz tarih formatı';
                              }
                              if (day < 1 ||
                                  day > 31 ||
                                  month < 1 ||
                                  month > 12) {
                                return 'Geçersiz tarih';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveChanges,
                            child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _cancelEdit,
                            child: const Text('İptal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // View Mode - Bilgileri Göster
              _buildInfoGrid(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        // İlk satır - Temel bilgiler
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.person,
                label: 'Ad',
                value: widget.member.firstName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.person_outline,
                label: 'Soyad',
                value: widget.member.lastName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // İkinci satır - İletişim bilgileri
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.phone,
                label: 'Telefon',
                value: widget.member.phone ?? '-',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.cake,
                label: 'Doğum Tarihi',
                value: widget.member.birthDate != null
                    ? '${widget.member.birthDate!.day}/${widget.member.birthDate!.month}/${widget.member.birthDate!.year}'
                    : '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Üçüncü satır - Rol ve grup bilgileri
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.admin_panel_settings,
                label: 'Rol',
                value: widget.member.roleName,
                valueColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.group,
                label: 'Grup',
                value: widget.member.groupName,
                valueColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _cancelEdit() {
    setState(() {
      _editMode = false;
      _firstName.text = widget.member.firstName;
      _lastName.text = widget.member.lastName;
      _phone.text = widget.member.phone ?? '';
      _birthDate = widget.member.birthDate;
      if (_birthDate != null) {
        _birthDateController.text =
            '${_birthDate!.day.toString().padLeft(2, '0')}${_birthDate!.month.toString().padLeft(2, '0')}${_birthDate!.year}';
      } else {
        _birthDateController.clear();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen zorunlu alanları doldurun ve telefonu kontrol edin',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(membersRepositoryProvider);
      final String phoneText = Validators.normalizePhone(
        _phone.text.trim(),
        defaultCountryCode: '+90',
      );

      await repo.updateCurrentMember(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: phoneText,
        birthDate: _birthDate,
      );

      ref.invalidate(currentMemberProvider);

      if (mounted) {
        setState(() => _editMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgiler güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncellenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
