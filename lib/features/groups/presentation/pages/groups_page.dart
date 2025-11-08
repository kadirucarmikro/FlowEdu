import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/groups_providers.dart';
import '../widgets/group_card.dart';
import '../widgets/group_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  final GlobalKey<_AdminGroupsListState> _listKey =
      GlobalKey<_AdminGroupsListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Gruplar'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showCreateGroupDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Grup Ekle',
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
    final groupsAsync = ref.watch(groupsListProvider);

    return Column(
      children: [
        // Admin Filter Widget - DB ile ilişkili temel filtreleme
        groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Gruplar yüklenemedi: $error')),
          data: (groups) {
            return AdminFilterWidget(
              filterOptions: _buildDynamicFilterOptions(groups),
              onFilterChanged: (filters) {
                // Apply filters to group list
                _listKey.currentState?._onFilterChanged(filters);
              },
            );
          },
        ),

        // Groups List - Admin için tam yönetim
        Expanded(
          child: groupsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(groupsListProvider),
            ),
            data: (groups) {
              return AdminGroupsList(
                key: _listKey,
                groups: groups,
                onEdit: (group) => _showEditGroupDialog(context, group),
                onDelete: (group) => _showDeleteConfirmation(context, group),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentUserGroupInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredLoadingWidget();
        }

        if (snapshot.hasError) {
          return CenteredErrorWidget.generalError(
            message: 'Grup bilgisi alınamadı: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final userInfo = snapshot.data ?? {};
        final userGroup = userInfo['group'];
        final groupName = userGroup?['name'] ?? 'Grup atanmamış';

        return Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Grup Bilgileriniz',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mevcut Grubunuz: $groupName',
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

  Future<Map<String, dynamic>> _getCurrentUserGroupInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {'group': null};
      }

      // Kullanıcının grup bilgilerini çek
      final response = await Supabase.instance.client
          .from('members')
          .select('groups(name, is_active)')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        return {'group': response['groups']};
      }

      return {'group': null};
    } catch (e) {
      return {'group': null};
    }
  }

  List<FilterOption> _buildDynamicFilterOptions(List<dynamic> groups) {
    // Grup seçenekleri
    final groupOptions = <String>[
      'Tümü',
      ...groups.map((group) => group.name as String),
    ];

    return [
      FilterOption(
        key: 'name',
        label: 'Grup Adı',
        type: FilterType.dropdown,
        options: groupOptions,
      ),
      const FilterOption(
        key: 'is_active',
        label: 'Aktif Gruplar',
        type: FilterType.checkbox,
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const GroupFormDialog());
  }

  void _showEditGroupDialog(BuildContext context, group) {
    showDialog(
      context: context,
      builder: (context) => GroupFormDialog(group: group),
    );
  }

  void _showDeleteConfirmation(BuildContext context, group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grubu Sil'),
        content: Text(
          '${group.name} grubunu silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteGroup(group.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      final deleteGroup = ref.read(deleteGroupProvider);
      await deleteGroup(groupId);

      if (mounted) {
        ref.invalidate(groupsListProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Grup başarıyla silindi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Grup silinemedi: $e')));
      }
    }
  }
}

/// Admin Groups List - Roles sayfası ile tutarlı yapı
class AdminGroupsList extends ConsumerStatefulWidget {
  final List<dynamic> groups;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;

  const AdminGroupsList({
    super.key,
    required this.groups,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<AdminGroupsList> createState() => _AdminGroupsListState();
}

class _AdminGroupsListState extends ConsumerState<AdminGroupsList> {
  Map<String, dynamic> _filters = {};

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _applyFilters(widget.groups);

    return ResponsiveGridList<dynamic>(
      items: filteredGroups,
      itemBuilder: (context, group, index) {
        return GroupCard(
          group: group,
          onEdit: () => widget.onEdit(group),
          onDelete: () => widget.onDelete(group),
          showActions: true,
        );
      },
      aspectRatio: 1.2,
      maxColumns: 3,
      emptyWidget: CenteredEmptyWidget(
        title: 'Henüz grup bulunmuyor',
        message: 'İlk grubu eklemek için + butonuna tıklayın',
        icon: Icons.group_outlined,
        onAction: () {
          // Add group functionality
        },
        actionText: 'Yeni Grup Ekle',
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> groups) {
    if (_filters.isEmpty) return groups;

    return groups.where((group) {
      // Search filter (AdminFilterWidget'ın arama kutusu)
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!group.name.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Name filter (dropdown)
      if (_filters.containsKey('name') &&
          _filters['name'] != null &&
          _filters['name'] != 'Tümü') {
        final selectedGroup = _filters['name'] as String;
        if (group.name != selectedGroup) {
          return false;
        }
      }

      // Active filter
      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!group.isActive) {
          return false;
        }
      }

      // Date filter
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (group.createdAt.isBefore(filterDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
