import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/roles_providers.dart';
import '../widgets/role_card.dart';
import '../widgets/role_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key});

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  final GlobalKey<_AdminRolesListState> _listKey =
      GlobalKey<_AdminRolesListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Roller'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showCreateRoleDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Rol Ekle',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const nav.NavigationDrawer(),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildMemberView(),
      ),
    );
  }

  Widget _buildAdminView() {
    final rolesAsync = ref.watch(rolesListProvider);

    return Column(
      children: [
        // Admin Filter Widget - DB ile ilişkili temel filtreleme
        rolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Roller yüklenemedi: $error')),
          data: (roles) {
            return AdminFilterWidget(
              filterOptions: _buildDynamicFilterOptions(roles),
              onFilterChanged: (filters) {
                // Apply filters to role list
                _listKey.currentState?._onFilterChanged(filters);
              },
            );
          },
        ),

        // Roles List - Admin için tam yönetim
        Expanded(
          child: rolesAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(rolesListProvider),
            ),
            data: (roles) {
              return AdminRolesList(
                key: _listKey,
                roles: roles,
                onEdit: (role) => _showEditRoleDialog(context, role),
                onDelete: (role) => _showDeleteConfirmation(context, role),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    return FutureBuilder<String>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredLoadingWidget();
        }

        if (snapshot.hasError) {
          return CenteredErrorWidget.generalError(
            message: 'Rol bilgisi alınamadı: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final userRole = snapshot.data ?? 'Bilinmiyor';

        return Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rol Bilgileriniz',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mevcut Rolunuz: $userRole',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FilterOption> _buildDynamicFilterOptions(List<dynamic> roles) {
    // Rol seçenekleri
    final roleOptions = <String>[
      'Tümü',
      ...roles.map((role) => role.name as String),
    ];

    return [
      FilterOption(
        key: 'name',
        label: 'Rol Adı',
        type: FilterType.dropdown,
        options: roleOptions,
      ),
      const FilterOption(
        key: 'is_active',
        label: 'Aktif Roller',
        type: FilterType.checkbox,
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  void _showCreateRoleDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const RoleFormDialog());
  }

  void _showEditRoleDialog(BuildContext context, role) {
    showDialog(
      context: context,
      builder: (context) => RoleFormDialog(role: role),
    );
  }

  void _showDeleteConfirmation(BuildContext context, role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rolü Sil'),
        content: Text(
          '${role.name} rolünü silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(deleteRoleProvider).call(role.id);
                ref.invalidate(rolesListProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rol başarıyla silindi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// Admin Roles List - Members sayfası ile tutarlı yapı
class AdminRolesList extends ConsumerStatefulWidget {
  final List<dynamic> roles;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;

  const AdminRolesList({
    super.key,
    required this.roles,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<AdminRolesList> createState() => _AdminRolesListState();
}

class _AdminRolesListState extends ConsumerState<AdminRolesList> {
  Map<String, dynamic> _filters = {};

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoles = _applyFilters(widget.roles);

    return ResponsiveGridList<dynamic>(
      items: filteredRoles,
      itemBuilder: (context, role, index) {
        return RoleCard(
          role: role,
          onEdit: () => widget.onEdit(role),
          onDelete: () => widget.onDelete(role),
          showActions: true,
        );
      },
      aspectRatio: 1.2,
      maxColumns: 3,
      emptyWidget: CenteredEmptyWidget(
        title: 'Henüz rol bulunmuyor',
        message: 'İlk rolü eklemek için + butonuna tıklayın',
        icon: Icons.admin_panel_settings_outlined,
        onAction: () {
          // Add role functionality
        },
        actionText: 'Yeni Rol Ekle',
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> roles) {
    if (_filters.isEmpty) return roles;

    return roles.where((role) {
      // Search filter (AdminFilterWidget'ın arama kutusu)
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!role.name.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Name filter (dropdown)
      if (_filters.containsKey('name') &&
          _filters['name'] != null &&
          _filters['name'] != 'Tümü') {
        final selectedRole = _filters['name'] as String;
        if (role.name != selectedRole) {
          return false;
        }
      }

      // Active filter
      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!role.isActive) {
          return false;
        }
      }

      // Date filter
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (role.createdAt.isBefore(filterDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
