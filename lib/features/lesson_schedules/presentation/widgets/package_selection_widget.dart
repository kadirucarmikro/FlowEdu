import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payments/presentation/providers/payments_providers.dart';
import '../../../payments/domain/entities/lesson_package.dart';
import '../../../payments/data/providers/payments_providers.dart' as data;

class PackageSelectionWidget extends ConsumerStatefulWidget {
  final String? selectedPackageId;
  final Function(String?) onPackageSelected;

  const PackageSelectionWidget({
    super.key,
    required this.selectedPackageId,
    required this.onPackageSelected,
  });

  @override
  ConsumerState<PackageSelectionWidget> createState() =>
      _PackageSelectionWidgetState();
}

class _PackageSelectionWidgetState
    extends ConsumerState<PackageSelectionWidget> {
  void _showQuickPackageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuickPackageDialog(
        onPackageCreated: () {
          ref.invalidate(lessonPackagesProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Ders Paketi Seçimi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final packagesAsync = ref.watch(lessonPackagesProvider);

                return packagesAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Hata: $error'),
                  data: (packages) {
                    LessonPackage? selectedPackage;
                    if (widget.selectedPackageId != null && packages.isNotEmpty) {
                      try {
                        selectedPackage = packages.firstWhere(
                          (p) => p.id == widget.selectedPackageId,
                        );
                      } catch (e) {
                        // Paket bulunamadı, null bırak
                        selectedPackage = null;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: widget.selectedPackageId,
                          decoration: const InputDecoration(
                            labelText: 'Ders Paketi *',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Ders paketi seçiniz'),
                          items: packages.map((package) {
                            return DropdownMenuItem(
                              value: package.id,
                              child: Text(
                                '${package.name} (${package.lessonCount} Ders)',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            widget.onPackageSelected(value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ders paketi seçiniz';
                            }
                            return null;
                          },
                        ),
                        if (selectedPackage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Toplam Tutar:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₺${selectedPackage.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ders Başına Tutar:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₺${selectedPackage.pricePerLesson.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yeni ders paketi eklemek için',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showQuickPackageDialog(context);
                  },
                  child: const Text(
                    'Hızlı Paket Ekle',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickPackageDialog extends ConsumerStatefulWidget {
  final VoidCallback onPackageCreated;

  const QuickPackageDialog({super.key, required this.onPackageCreated});

  @override
  ConsumerState<QuickPackageDialog> createState() => _QuickPackageDialogState();
}

class _QuickPackageDialogState extends ConsumerState<QuickPackageDialog> {
  final _nameController = TextEditingController();
  final _lessonCountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lessonCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hızlı Ders Paketi Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Paket Adı *',
              hintText: 'Örn: 16 Derslik Paket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lessonCountController,
            decoration: const InputDecoration(
              labelText: 'Ders Sayısı *',
              hintText: 'Örn: 16',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isNotEmpty &&
                _lessonCountController.text.isNotEmpty) {
              try {
                final package = LessonPackage(
                  id: '',
                  name: _nameController.text,
                  lessonCount: int.parse(_lessonCountController.text),
                  price: 0.0, // Varsayılan değer, daha sonra düzenlenebilir
                  isActive: true,
                  createdAt: DateTime.now(),
                );

                await ref
                    .read(data.paymentsRepositoryProvider)
                    .createLessonPackage(package);

                widget.onPackageCreated();

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ders paketi başarıyla eklendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
