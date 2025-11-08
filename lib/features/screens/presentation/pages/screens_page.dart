import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/screens_providers.dart';
import '../widgets/screen_card.dart';
import '../widgets/screen_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class ScreensPage extends ConsumerStatefulWidget {
  const ScreensPage({super.key});

  @override
  ConsumerState<ScreensPage> createState() => _ScreensPageState();
}

class _ScreensPageState extends ConsumerState<ScreensPage> {
  final GlobalKey<_AdminScreensListState> _listKey =
      GlobalKey<_AdminScreensListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Ekranlar'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showCreateScreenDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Ekran Ekle',
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
    final screensAsync = ref.watch(screensListProvider);

    return Column(
      children: [
        // Admin Filter Widget - DB ile ilişkili temel filtreleme
        screensAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Ekranlar yüklenemedi: $error')),
          data: (screens) {
            return AdminFilterWidget(
              filterOptions: _buildDynamicFilterOptions(screens),
              onFilterChanged: (filters) {
                // Apply filters to screen list
                _listKey.currentState?._onFilterChanged(filters);
              },
            );
          },
        ),

        // Screens List - Admin için tam yönetim
        Expanded(
          child: screensAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(screensListProvider),
            ),
            data: (screens) {
              return AdminScreensList(
                key: _listKey,
                screens: screens,
                onEdit: (screen) => _showEditScreenDialog(context, screen),
                onDelete: (screen) => _showDeleteConfirmation(context, screen),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentUserScreenInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return CenteredErrorWidget.generalError(
            message: 'Ekran bilgileri yüklenemedi: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final userScreen = snapshot.data?['screen'];
        final screenName = userScreen?.name ?? 'Ekran atanmamış';

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.screen_share_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Ekran Bilgileriniz',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mevcut Ekranınız: $screenName',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                // Member için sadece ilgili sayfalara erişim
                _buildMemberScreenAccess(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberScreenAccess() {
    // Member kullanıcı için erişebileceği sayfalar
    final accessibleScreens = [
      {'name': 'Üyelik', 'route': '/members', 'icon': Icons.person},
      {'name': 'Gruplar', 'route': '/groups', 'icon': Icons.group},
      {'name': 'Etkinlikler', 'route': '/events', 'icon': Icons.event},
      {
        'name': 'Bildirimler',
        'route': '/notifications',
        'icon': Icons.notifications,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Erişebileceğiniz Sayfalar',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: accessibleScreens.map((screen) {
            return Card(
              child: InkWell(
                onTap: () {
                  // Navigate to screen
                  // GoRouter.of(context).go(screen['route']);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        screen['icon'] as IconData,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        screen['name'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCreateScreenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ScreenFormDialog(),
    );
  }

  void _showEditScreenDialog(BuildContext context, screen) {
    showDialog(
      context: context,
      builder: (context) => ScreenFormDialog(screen: screen),
    );
  }

  void _showDeleteConfirmation(BuildContext context, screen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ekranı Sil'),
        content: Text(
          '${screen.name} ekranını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteScreen(screen.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteScreen(String screenId) async {
    try {
      final deleteScreen = ref.read(deleteScreenProvider);
      await deleteScreen(screenId);

      if (mounted) {
        ref.invalidate(screensListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ekran başarıyla silindi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ekran silinemedi: $e')));
      }
    }
  }

  List<FilterOption> _buildDynamicFilterOptions(List<dynamic> screens) {
    // Ekran seçenekleri
    final screenOptions = <String>[
      'Tümü',
      ...screens.map((screen) => screen.name as String),
    ];

    return [
      FilterOption(
        key: 'name',
        label: 'Ekran Adı',
        type: FilterType.dropdown,
        options: screenOptions,
      ),
      FilterOption(
        key: 'is_active',
        label: 'Aktif Ekranlar',
        type: FilterType.checkbox,
      ),
      FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  Future<Map<String, dynamic>> _getCurrentUserScreenInfo() async {
    try {
      // Kullanıcının ekran bilgilerini al
      final response = await ref.read(screensListProvider.future);
      // Bu basit bir implementasyon, gerçek uygulamada kullanıcının ekranını al
      if (response.isNotEmpty) {
        return {'screen': response.first};
      }
      return {'screen': null};
    } catch (e) {
      return {'screen': null};
    }
  }
}

/// Admin Screens List - Roles sayfası ile tutarlı yapı
class AdminScreensList extends ConsumerStatefulWidget {
  final List<dynamic> screens;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;

  const AdminScreensList({
    super.key,
    required this.screens,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<AdminScreensList> createState() => _AdminScreensListState();
}

class _AdminScreensListState extends ConsumerState<AdminScreensList> {
  Map<String, dynamic> _filters = {};

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredScreens = _applyFilters(widget.screens);

    return ResponsiveGridList<dynamic>(
      items: filteredScreens,
      itemBuilder: (context, screen, index) {
        return ScreenCard(
          screen: screen,
          onEdit: () => widget.onEdit(screen),
          onDelete: () => widget.onDelete(screen),
        );
      },
      aspectRatio: 1.2,
      maxColumns: 3,
      emptyWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.screen_share_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz ekran bulunmuyor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'İlk ekranı eklemek için + butonuna tıklayın',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> screens) {
    if (_filters.isEmpty) return screens;

    return screens.where((screen) {
      // Search filter (AdminFilterWidget'ın arama kutusu)
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!screen.name.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Name filter (dropdown)
      if (_filters.containsKey('name') &&
          _filters['name'] != null &&
          _filters['name'] != 'Tümü') {
        final selectedScreen = _filters['name'] as String;
        if (screen.name != selectedScreen) {
          return false;
        }
      }

      // Active filter
      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!screen.isActive) {
          return false;
        }
      }

      // Date filter
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (screen.createdAt.isBefore(filterDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
