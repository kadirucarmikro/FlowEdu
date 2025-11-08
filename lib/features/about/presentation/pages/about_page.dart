import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/about_providers.dart';
import '../widgets/about_content_card.dart';
import '../widgets/about_content_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/services/role_service.dart';
import '../../../../core/widgets/responsive_grid_list.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../domain/entities/about_content.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Hakkımızda'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateAboutContentDialog(context),
                  tooltip: 'Yeni İçerik Ekle',
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
    final aboutContentsAsync = ref.watch(aboutContentsProvider);

    return Column(
      children: [
        AdminFilterWidget(
          filterOptions: _buildFilterOptions(),
          onFilterChanged: (filters) {
            setState(() {
              _filters = filters;
            });
          },
        ),
        Expanded(
          child: aboutContentsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(aboutContentsProvider),
            ),
            data: (contents) {
              final filteredContents = _applyFilters(contents);

              if (filteredContents.isEmpty) {
                return CenteredEmptyWidget(
                  title: _filters.isEmpty
                      ? 'Henüz içerik bulunmuyor'
                      : 'Filtreye uygun içerik bulunamadı',
                  message: _filters.isEmpty
                      ? 'İlk içeriği eklemek için + butonuna tıklayın'
                      : 'Filtreleri değiştirerek tekrar deneyin',
                  icon: Icons.info_outline,
                  onAction: _filters.isEmpty
                      ? () => _showCreateAboutContentDialog(context)
                      : null,
                  actionText: _filters.isEmpty ? 'Yeni İçerik Ekle' : null,
                );
              }

              return RefreshableResponsiveGridList<AboutContent>(
                items: filteredContents,
                onRefresh: () async {
                  ref.invalidate(aboutContentsProvider);
                },
                aspectRatio: 1.5,
                maxColumns: 3,
                itemBuilder: (context, content, index) {
                  return AboutContentCard(
                    content: content,
                    onEdit: () => _showEditAboutContentDialog(context, content),
                    onDelete: () => _deleteAboutContent(context, content.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    final aboutContentsAsync = ref.watch(aboutContentsProvider);

    return Column(
      children: [
        AdminFilterWidget(
          filterOptions: _buildMemberFilterOptions(),
          onFilterChanged: (filters) {
            setState(() {
              _filters = filters;
            });
          },
        ),
        Expanded(
          child: aboutContentsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(aboutContentsProvider),
            ),
            data: (contents) {
              final activeContents = contents
                  .where((content) => content.isActive)
                  .toList();

              final filteredContents = _applyFilters(activeContents);

              if (filteredContents.isEmpty) {
                return const CenteredEmptyWidget(
                  title: 'Henüz içerik bulunmuyor',
                  message: 'Yayınlanmış içerik bulunmuyor',
                  icon: Icons.info_outline,
                );
              }

              return RefreshableResponsiveGridList<AboutContent>(
                items: filteredContents,
                onRefresh: () async {
                  ref.invalidate(aboutContentsProvider);
                },
                aspectRatio: 1.5,
                maxColumns: 3,
                itemBuilder: (context, content, index) {
                  return AboutContentCard(
                    content: content,
                    onEdit: null, // Member içerikleri düzenleyemez
                    onDelete: null, // Member içerikleri silemez
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateAboutContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutContentFormDialog(
        onSave: (content) async {
          try {
            final createAboutContent = ref.read(createAboutContentProvider);
            await createAboutContent(content);
            if (mounted) {
              ref.invalidate(aboutContentsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İçerik başarıyla oluşturuldu')),
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
      ),
    );
  }

  void _showEditAboutContentDialog(BuildContext context, content) {
    showDialog(
      context: context,
      builder: (context) => AboutContentFormDialog(
        content: content,
        onSave: (updatedContent) async {
          try {
            final updateAboutContent = ref.read(updateAboutContentProvider);
            await updateAboutContent(updatedContent);
            if (mounted) {
              ref.invalidate(aboutContentsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İçerik başarıyla güncellendi')),
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
      ),
    );
  }

  void _deleteAboutContent(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçeriği Sil'),
        content: const Text('Bu içeriği silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deleteAboutContent = ref.read(deleteAboutContentProvider);
        await deleteAboutContent(id);
        if (mounted) {
          ref.invalidate(aboutContentsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İçerik başarıyla silindi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  List<FilterOption> _buildFilterOptions() {
    return [
      FilterOption(
        key: 'type',
        label: 'İçerik Tipi',
        type: FilterType.dropdown,
        options: ['Tümü', 'Metin', 'Resim', 'Video'],
      ),
      FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Pasif'],
      ),
      FilterOption(
        key: 'is_active',
        label: 'Sadece Aktif İçerikler',
        type: FilterType.checkbox,
      ),
      FilterOption(
        key: 'created_date',
        label: 'Oluşturulma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  List<FilterOption> _buildMemberFilterOptions() {
    return [
      FilterOption(
        key: 'type',
        label: 'İçerik Tipi',
        type: FilterType.dropdown,
        options: ['Tümü', 'Metin', 'Resim', 'Video'],
      ),
    ];
  }

  List<AboutContent> _applyFilters(List<AboutContent> contents) {
    if (_filters.isEmpty) return contents;

    return contents.where((content) {
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        final titleMatch = content.title.toLowerCase().contains(searchTerm);
        final contentMatch = content.contentText?.toLowerCase().contains(searchTerm) ?? false;
        if (!titleMatch && !contentMatch) {
          return false;
        }
      }

      if (_filters.containsKey('type') &&
          _filters['type'] != null &&
          _filters['type'] != 'Tümü') {
        final filterType = _filters['type'] as String;
        String contentType;
        switch (content.type) {
          case ContentType.text:
            contentType = 'Metin';
            break;
          case ContentType.image:
            contentType = 'Resim';
            break;
          case ContentType.video:
            contentType = 'Video';
            break;
        }
        if (contentType != filterType) {
          return false;
        }
      }

      if (_filters.containsKey('status') &&
          _filters['status'] != null &&
          _filters['status'] != 'Tümü') {
        final status = _filters['status'] as String;
        if (status == 'Aktif' && !content.isActive) return false;
        if (status == 'Pasif' && content.isActive) return false;
      }

      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!content.isActive) return false;
      }

      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        final contentDate = DateTime(
          content.createdAt.year,
          content.createdAt.month,
          content.createdAt.day,
        );
        final filterDay = DateTime(
          filterDate.year,
          filterDate.month,
          filterDate.day,
        );
        if (contentDate.isBefore(filterDay)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
