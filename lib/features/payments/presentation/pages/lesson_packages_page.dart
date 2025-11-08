import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/payments_providers.dart';
import '../widgets/lesson_package_card.dart';
import '../widgets/lesson_package_form_dialog.dart';
import '../../domain/entities/lesson_package.dart';
import '../../data/providers/payments_providers.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/centered_empty_widget.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class LessonPackagesPage extends ConsumerStatefulWidget {
  const LessonPackagesPage({super.key});

  @override
  ConsumerState<LessonPackagesPage> createState() => _LessonPackagesPageState();
}

class _LessonPackagesPageState extends ConsumerState<LessonPackagesPage> {
  final GlobalKey<_FilteredPackagesListState> _listKey =
      GlobalKey<_FilteredPackagesListState>();

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(lessonPackagesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return FutureBuilder<bool>(
      future: RoleService.isAdmin(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: const AppBarLogo(),
              title: const Text('Ders Paketleri'),
            ),
            drawer: const nav.NavigationDrawer(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is admin
        final isAdmin = snapshot.data ?? false;
        if (!isAdmin) {
          // Member user - show access denied
          return Scaffold(
            appBar: AppBar(
              leading: const AppBarLogo(),
              title: const Text('Ders Paketleri'),
            ),
            drawer: const nav.NavigationDrawer(),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: isMobile ? 64 : 96,
                      color: Colors.grey,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Erişim Reddedildi',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'Bu sayfaya sadece yönetici kullanıcılar erişebilir.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (context.mounted) {
                          context.go('/members');
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Ana Sayfaya Dön'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Admin user - show normal page
        return Scaffold(
          appBar: AppBar(
            leading: const AppBarLogo(),
            title: const Text('Ders Paketleri'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreatePackageDialog(context),
              ),
            ],
          ),
          drawer: const nav.NavigationDrawer(),
          body: Column(
            children: [
              // Filtreleme Widget
              packagesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
                data: (packages) {
                  return AdminFilterWidget(
                    filterOptions:
                        CommonFilterOptions.getLessonPackageFilters(),
                    onFilterChanged: (filters) {
                      _listKey.currentState?._onFilterChanged(filters);
                    },
                  );
                },
              ),
              // Paket Listesi
              Expanded(
                child: packagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isMobile ? 48 : 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            'Hata: $error',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(lessonPackagesProvider),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (packages) {
                    return FilteredPackagesList(
                      key: _listKey,
                      packages: packages,
                      onEdit: (package) =>
                          _showEditPackageDialog(context, package),
                      onDelete: (id) => _deletePackage(context, id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePackageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LessonPackageFormDialog(
        onSave: (packageData) async {
          try {
            final repository = ref.read(paymentsRepositoryProvider);
            final package = LessonPackage(
              id: '', // Will be generated by repository
              name: packageData['name'],
              lessonCount: packageData['lessonCount'],
              price: packageData['price'] as double,
              isActive: packageData['isActive'],
              createdAt: DateTime.now(),
            );
            await repository.createLessonPackage(package);
            ref.invalidate(lessonPackagesProvider);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ders paketi oluşturuldu')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
            }
          }
        },
      ),
    );
  }

  void _showEditPackageDialog(BuildContext context, dynamic package) {
    showDialog(
      context: context,
      builder: (context) => LessonPackageFormDialog(
        package: package,
        onSave: (packageData) async {
          try {
            final repository = ref.read(paymentsRepositoryProvider);
            final updatedPackage = package.copyWith(
              name: packageData['name'],
              lessonCount: packageData['lessonCount'],
              price: packageData['price'] as double,
              isActive: packageData['isActive'],
            );
            await repository.updateLessonPackage(updatedPackage);
            ref.invalidate(lessonPackagesProvider);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ders paketi güncellendi')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
            }
          }
        },
      ),
    );
  }

  void _deletePackage(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paketi Sil'),
        content: const Text(
          'Bu ders paketini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(paymentsRepositoryProvider);
        await repository.deleteLessonPackage(id);
        ref.invalidate(lessonPackagesProvider);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ders paketi silindi')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
        }
      }
    }
  }
}

/// Filtrelenmiş Paket Listesi
class FilteredPackagesList extends ConsumerStatefulWidget {
  final List<LessonPackage> packages;
  final Function(LessonPackage) onEdit;
  final Function(String) onDelete;

  const FilteredPackagesList({
    super.key,
    required this.packages,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<FilteredPackagesList> createState() =>
      _FilteredPackagesListState();
}

class _FilteredPackagesListState extends ConsumerState<FilteredPackagesList> {
  Map<String, dynamic> _filters = {};

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPackages = _applyFilters(widget.packages);

    return RefreshableResponsiveGridList<LessonPackage>(
      items: filteredPackages,
      onRefresh: () async => ref.invalidate(lessonPackagesProvider),
      itemBuilder: (context, package, index) {
        return LessonPackageCard(
          package: package,
          onEdit: () => widget.onEdit(package),
          onDelete: () => widget.onDelete(package.id),
        );
      },
      aspectRatio: 1.2,
      maxColumns: 3,
      emptyWidget: CenteredEmptyWidget(
        icon: Icons.school_outlined,
        title: 'Henüz ders paketi bulunmuyor',
        subtitle: _filters.isEmpty
            ? 'İlk ders paketini eklemek için + butonuna tıklayın'
            : 'Filtreleme kriterlerinizi değiştirmeyi deneyin',
      ),
    );
  }

  List<LessonPackage> _applyFilters(List<LessonPackage> packages) {
    if (_filters.isEmpty) return packages;

    return packages.where((package) {
      // Arama filtresi
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!package.name.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Ders sayısı filtresi
      if (_filters.containsKey('lesson_count') &&
          _filters['lesson_count'] != null &&
          _filters['lesson_count'] != 'Tümü') {
        final lessonCount = package.lessonCount;
        final filterValue = _filters['lesson_count'] as String;

        switch (filterValue) {
          case '1-5 ders':
            if (lessonCount < 1 || lessonCount > 5) return false;
            break;
          case '6-10 ders':
            if (lessonCount < 6 || lessonCount > 10) return false;
            break;
          case '11-20 ders':
            if (lessonCount < 11 || lessonCount > 20) return false;
            break;
          case '20+ ders':
            if (lessonCount < 21) return false;
            break;
        }
      }

      // Durum filtresi
      if (_filters.containsKey('status') &&
          _filters['status'] != null &&
          _filters['status'] != 'Tümü') {
        final status = _filters['status'] as String;
        if (status == 'Aktif' && !package.isActive) return false;
        if (status == 'Pasif' && package.isActive) return false;
      }

      // Aktif paket filtresi (checkbox)
      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!package.isActive) return false;
      }

      // Tarih filtresi
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (package.createdAt.day != filterDate.day ||
            package.createdAt.month != filterDate.month ||
            package.createdAt.year != filterDate.year) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
