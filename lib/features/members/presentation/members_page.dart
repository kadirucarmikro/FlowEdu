import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/navigation_drawer.dart' as custom;
import '../../members/data/members_repository_impl.dart';
import '../../../app/router/app_router.dart';
import '../../../core/widgets/role_based_form.dart';
import '../../../core/widgets/admin_filter_widget.dart';
import '../../../core/widgets/responsive_grid_list.dart';
import '../domain/member_entity.dart';
import '../../groups/presentation/providers/groups_providers.dart';
import '../../roles/presentation/providers/roles_providers.dart';
import 'widgets/member_edit_dialog.dart';
import 'widgets/member_add_dialog.dart';
import 'widgets/member_detail_dialog.dart';

final membersRepositoryProvider = Provider<MembersRepositoryImpl>((ref) {
  return MembersRepositoryImpl(Supabase.instance.client);
});

// Authentication state değişikliğini dinleyen provider
final authStateProvider = StreamProvider((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentMemberProvider = FutureProvider((ref) async {
  // Authentication state değişikliğini dinle
  ref.watch(authStateProvider);

  final repo = ref.watch(membersRepositoryProvider);
  return repo.getCurrentMember();
});

final allMembersProvider = FutureProvider((ref) async {
  final repo = ref.watch(membersRepositoryProvider);
  return repo.getAllMembers();
});

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Basit login kontrolü
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/signin');
      });
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Yönlendiriliyor...'),
            ],
          ),
        ),
      );
    }

    return RoleBasedForm(
      adminForm: const AdminMembersForm(),
      memberForm: const MemberMembersForm(), // Yeni 2 satırlı tasarım
    );
  }
}

/// Admin form for managing all members
class AdminMembersForm extends ConsumerStatefulWidget {
  const AdminMembersForm({super.key});

  @override
  ConsumerState<AdminMembersForm> createState() => _AdminMembersFormState();
}

class _AdminMembersFormState extends ConsumerState<AdminMembersForm> {
  final GlobalKey<_AdminMembersListState> _listKey =
      GlobalKey<_AdminMembersListState>();

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsListProvider);
    final rolesAsync = ref.watch(rolesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MemberAddDialog(
                  onSuccess: () {
                    // Refresh the list after successful add
                    ref.invalidate(allMembersProvider);
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: const custom.NavigationDrawer(),
      body: Column(
        children: [
          // Admin filter widget - DB ile ilişkili temel filtreleme
          groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Gruplar yüklenemedi: $error')),
            data: (groups) {
              return rolesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Roller yüklenemedi: $error')),
                data: (roles) {
                  return AdminFilterWidget(
                    filterOptions: _buildDynamicFilterOptions(groups, roles),
                    onFilterChanged: (filters) {
                      // Apply filters to member list
                      _listKey.currentState?._onFilterChanged(filters);
                    },
                  );
                },
              );
            },
          ),
          // Member list - Admin için tam yönetim
          Expanded(child: AdminMembersList(key: _listKey)),
        ],
      ),
    );
  }

  List<FilterOption> _buildDynamicFilterOptions(
    List<dynamic> groups,
    List<dynamic> roles,
  ) {
    // Grup seçenekleri
    final groupOptions = <String>[
      'Tümü',
      ...groups.map((group) => group.name as String),
    ];

    // Rol seçenekleri
    final roleOptions = <String>[
      'Tümü',
      ...roles.map((role) => role.name as String),
    ];

    return [
      FilterOption(
        key: 'group',
        label: 'Grup',
        type: FilterType.dropdown,
        options: groupOptions,
      ),
      FilterOption(
        key: 'role',
        label: 'Rol',
        type: FilterType.dropdown,
        options: roleOptions,
      ),
      const FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Pasif', 'Beklemede'],
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Kayıt Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }
}

/// Member form for viewing own data - 2 satırlı responsive tasarım
class MemberMembersForm extends ConsumerStatefulWidget {
  const MemberMembersForm({super.key});

  @override
  ConsumerState<MemberMembersForm> createState() => _MemberMembersFormState();
}

class _MemberMembersFormState extends ConsumerState<MemberMembersForm> {
  @override
  Widget build(BuildContext context) {
    final memberAsync = ref.watch(currentMemberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const custom.NavigationDrawer(currentRoute: AppRoutes.members),
      body: memberAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Üye bilgileri bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // İlk satır: Member bilgileri
                    _MemberInfoRow(member: member),
                    const SizedBox(height: 24),
                    // İkinci satır: Hızlı erişim kartları
                    _QuickAccessRow(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// İlk satır: Member bilgileri kartı
class _MemberInfoRow extends ConsumerStatefulWidget {
  final MemberEntity member;

  const _MemberInfoRow({required this.member});

  @override
  ConsumerState<_MemberInfoRow> createState() => _MemberInfoRowState();
}

class _MemberInfoRowState extends ConsumerState<_MemberInfoRow> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _birthDate;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();
  bool _editMode = false;

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
        // Kompakt bilgi kartları
        _CompactInfoCard(
          icon: Icons.person,
          label: 'Ad Soyad',
          value: '${widget.member.firstName} ${widget.member.lastName}',
        ),
        const SizedBox(height: 8),
        _CompactInfoCard(
          icon: Icons.phone,
          label: 'Telefon',
          value: widget.member.phone ?? '-',
        ),
        const SizedBox(height: 8),
        _CompactInfoCard(
          icon: Icons.cake,
          label: 'Doğum Tarihi',
          value: widget.member.birthDate != null
              ? '${widget.member.birthDate!.day}/${widget.member.birthDate!.month}/${widget.member.birthDate!.year}'
              : '-',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CompactInfoCard(
                icon: Icons.admin_panel_settings,
                label: 'Rol',
                value: widget.member.roleName,
                valueColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CompactInfoCard(
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

/// İkinci satır: Hızlı erişim kartları
class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow();

  @override
  Widget build(BuildContext context) {
    final quickAccessItems = [
      {
        'icon': Icons.schedule,
        'title': 'Ders Programı',
        'subtitle': '3/8 ders tamamlandı',
        'color': Colors.blue,
        'badge': '3/8',
      },
      {
        'icon': Icons.notifications,
        'title': 'Bildirimler',
        'subtitle': '2 yeni bildirim',
        'color': Colors.orange,
        'badge': '2',
      },
      {
        'icon': Icons.event,
        'title': 'Etkinlikler',
        'subtitle': '1 yaklaşan etkinlik',
        'color': Colors.green,
        'badge': '1',
      },
      {
        'icon': Icons.payment,
        'title': 'Ödemeler',
        'subtitle': 'Son ödeme: 15.01.2024',
        'color': Colors.purple,
        'badge': 'Güncel',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ResponsiveGridList<Map<String, dynamic>>(
          items: quickAccessItems,
          itemBuilder: (context, item, index) {
            return _QuickAccessCard(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              color: item['color'] as Color,
              badge: item['badge'] as String?,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['title']} - TODO: Implement'),
                  ),
                );
              },
            );
          },
          aspectRatio: 1.5,
          maxColumns: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}

class _CompactInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _CompactInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        valueColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin members list for full management
class AdminMembersList extends ConsumerStatefulWidget {
  const AdminMembersList({super.key});

  @override
  ConsumerState<AdminMembersList> createState() => _AdminMembersListState();
}

class _AdminMembersListState extends ConsumerState<AdminMembersList> {
  Map<String, dynamic> _filters = {};

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
      data: (members) {
        // Apply filters
        List<MemberEntity> filteredMembers = members;

        if (_filters['search'] != null &&
            _filters['search'].toString().isNotEmpty) {
          final searchTerm = _filters['search'].toString().toLowerCase();
          filteredMembers = filteredMembers.where((member) {
            return member.firstName.toLowerCase().contains(searchTerm) ||
                member.lastName.toLowerCase().contains(searchTerm) ||
                member.email.toLowerCase().contains(searchTerm);
          }).toList();
        }

        if (_filters['group'] != null && _filters['group'] != 'Tümü') {
          filteredMembers = filteredMembers.where((member) {
            return member.groupName == _filters['group'];
          }).toList();
        }

        if (_filters['role'] != null && _filters['role'] != 'Tümü') {
          filteredMembers = filteredMembers.where((member) {
            return member.roleName == _filters['role'];
          }).toList();
        }

        if (_filters['status'] != null && _filters['status'] != 'Tümü') {
          filteredMembers = filteredMembers.where((member) {
            switch (_filters['status']) {
              case 'Aktif':
                return !member.isSuspended;
              case 'Pasif':
                return member.isSuspended;
              case 'Beklemede':
                return member.isSuspended;
              default:
                return true;
            }
          }).toList();
        }

        return ResponsiveGridList(
          items: filteredMembers,
          itemBuilder: (context, member, index) => _MemberCard(
            member: member,
            onEdit: () => _editMember(member),
            onDelete: () => _deleteMember(member),
          ),
          aspectRatio: 1.2,
          maxColumns: 4,
          emptyWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Üye bulunamadı',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Filtreleme kriterlerinizi değiştirmeyi deneyin',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editMember(MemberEntity member) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => MemberEditDialog(
          member: member,
          onSuccess: () {
            // Refresh the list after successful edit
            ref.invalidate(allMembersProvider);
          },
        ),
      );
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  void _deleteMember(MemberEntity member) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Üyeyi Sil'),
          content: Text(
            '${member.firstName} ${member.lastName} adlı üyeyi silmek istediğinizden emin misiniz?\n\n'
            'Bu işlem geri alınamaz ve üyenin tüm verileri kalıcı olarak silinecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  await _deleteMemberPermanently(member);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  Future<void> _deleteMemberPermanently(MemberEntity member) async {
    try {
      final repo = ref.read(membersRepositoryProvider);

      await repo.deleteMember(member.id);

      // Refresh the list
      ref.invalidate(allMembersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.firstName} ${member.lastName} silindi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _MemberCard extends StatelessWidget {
  final MemberEntity member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  void _showMemberDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showMemberDetail(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: member.isSuspended
                        ? Colors.red
                        : Colors.green,
                    child: Text(
                      member.firstName.isNotEmpty
                          ? member.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${member.firstName} ${member.lastName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (member.isInstructor) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Eğitmen',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          member.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Rol',
                value: member.roleName.isNotEmpty ? member.roleName : '-',
              ),
              _InfoRow(
                label: 'Grup',
                value: member.groupName.isNotEmpty ? member.groupName : '-',
              ),
              _InfoRow(
                label: 'Durum',
                value: member.isSuspended ? 'Askıda' : 'Aktif',
                valueColor: member.isSuspended ? Colors.red : Colors.green,
              ),
              if (member.phone != null && member.phone!.isNotEmpty)
                _InfoRow(label: 'Telefon', value: member.phone!),
              if (member.createdDate != null)
                _InfoRow(
                  label: 'Kayıt Tarihi',
                  value:
                      '${member.createdDate!.day}/${member.createdDate!.month}/${member.createdDate!.year}',
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Düzenle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Sil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? '-' : value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: valueColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
