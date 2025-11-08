import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payments/domain/entities/lesson_package.dart';
import '../../../payments/presentation/providers/payments_providers.dart';
import '../../../payments/data/providers/payments_providers.dart' as data;
import '../../../../core/widgets/centered_error_widget.dart';

class PackageManagementDialog extends ConsumerStatefulWidget {
  const PackageManagementDialog({super.key});

  @override
  ConsumerState<PackageManagementDialog> createState() =>
      _PackageManagementDialogState();
}

class _PackageManagementDialogState
    extends ConsumerState<PackageManagementDialog> {
  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(lessonPackagesProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Ders Paketi Yönetimi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Kapat',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCreatePackageDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Paket Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(lessonPackagesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Packages list
            Expanded(
              child: packagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => CenteredErrorWidget.generalError(
                  message: 'Hata: $error',
                  onRetry: () => ref.invalidate(lessonPackagesProvider),
                ),
                data: (packages) {
                  if (packages.isEmpty) {
                    return CenteredEmptyWidget(
                      title: 'Henüz ders paketi bulunmuyor',
                      message:
                          'İlk ders paketini eklemek için + butonuna tıklayın',
                      icon: Icons.inventory_2_outlined,
                      onAction: () => _showCreatePackageDialog(context),
                      actionText: 'Yeni Paket Ekle',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(lessonPackagesProvider),
                    child: ListView.builder(
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return _buildPackageListItem(package);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageListItem(LessonPackage package) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: package.isActive ? Colors.green : Colors.red,
          child: Text(
            '${package.lessonCount}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          package.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoChip('${package.lessonCount} Ders', Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip(
                  package.isActive ? 'Aktif' : 'Pasif',
                  package.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Oluşturulma: ${_formatDate(package.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditPackageDialog(context, package);
                break;
              case 'delete':
                _showDeletePackageDialog(context, package);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreatePackageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PackageFormDialog(
        onSave: (packageData) async {
          try {
            final package = LessonPackage(
              id: '',
              name: packageData['name'],
              lessonCount: packageData['lessonCount'],
              price: (packageData['price'] as num?)?.toDouble() ?? 0.0,
              isActive: packageData['isActive'],
              createdAt: DateTime.now(),
            );

            final repository = ref.read(data.paymentsRepositoryProvider);
            await repository.createLessonPackage(package);

            ref.invalidate(lessonPackagesProvider);
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${package.name} paketi oluşturuldu'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
          }
        },
      ),
    );
  }

  void _showEditPackageDialog(BuildContext context, LessonPackage package) {
    showDialog(
      context: context,
      builder: (context) => _PackageFormDialog(
        package: package,
        onSave: (packageData) async {
          try {
            final updatedPackage = LessonPackage(
              id: package.id,
              name: packageData['name'],
              lessonCount: packageData['lessonCount'],
              price:
                  (packageData['price'] as num?)?.toDouble() ?? package.price,
              isActive: packageData['isActive'],
              createdAt: package.createdAt,
            );

            final repository = ref.read(data.paymentsRepositoryProvider);
            await repository.updateLessonPackage(updatedPackage);

            ref.invalidate(lessonPackagesProvider);
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${updatedPackage.name} paketi güncellendi'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
          }
        },
      ),
    );
  }

  void _showDeletePackageDialog(BuildContext context, LessonPackage package) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Paketi Sil'),
          content: Text(
            '${package.name} paketini silmek istediğinizden emin misiniz?',
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
                if (!mounted) return;

                try {
                  final repository = ref.read(data.paymentsRepositoryProvider);
                  await repository.deleteLessonPackage(package.id);

                  ref.invalidate(lessonPackagesProvider);

                  if (mounted) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${package.name} paketi silindi'),
                        backgroundColor: Colors.red,
                      ),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
}

class _PackageFormDialog extends StatefulWidget {
  final LessonPackage? package;
  final Function(Map<String, dynamic>) onSave;

  const _PackageFormDialog({this.package, required this.onSave});

  @override
  State<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<_PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lessonCountController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.package != null) {
      _nameController.text = widget.package!.name;
      _lessonCountController.text = widget.package!.lessonCount.toString();
      _isActive = widget.package!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lessonCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.package == null ? 'Yeni Paket Ekle' : 'Paket Düzenle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Paket Adı *',
                hintText: 'Örn: 16 Derslik Paket',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Paket adı gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lessonCountController,
              decoration: const InputDecoration(
                labelText: 'Ders Sayısı *',
                hintText: 'Örn: 16',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ders sayısı gerekli';
                }
                if (int.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                if (int.parse(value) <= 0) {
                  return 'Ders sayısı 0\'dan büyük olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'name': _nameController.text,
                'lessonCount': int.parse(_lessonCountController.text),
                'isActive': _isActive,
              });
            }
          },
          child: Text(widget.package == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }
}
