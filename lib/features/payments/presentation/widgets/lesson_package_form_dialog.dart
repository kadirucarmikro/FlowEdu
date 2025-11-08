import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_package.dart';

class LessonPackageFormDialog extends ConsumerStatefulWidget {
  final LessonPackage? package;
  final Function(Map<String, dynamic>) onSave;

  const LessonPackageFormDialog({
    super.key,
    this.package,
    required this.onSave,
  });

  @override
  ConsumerState<LessonPackageFormDialog> createState() =>
      _LessonPackageFormDialogState();
}

class _LessonPackageFormDialogState
    extends ConsumerState<LessonPackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lessonCountController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isActive = true;
  double _pricePerLesson = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.package != null) {
      _nameController.text = widget.package!.name;
      _lessonCountController.text = widget.package!.lessonCount.toString();
      _priceController.text = widget.package!.price.toStringAsFixed(2);
      _isActive = widget.package!.isActive;
      _calculatePricePerLesson();
    }
    // Listeners for automatic calculation
    _lessonCountController.addListener(_calculatePricePerLesson);
    _priceController.addListener(_calculatePricePerLesson);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lessonCountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculatePricePerLesson() {
    final lessonCount = int.tryParse(_lessonCountController.text) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    
    if (lessonCount > 0 && price > 0) {
      setState(() {
        _pricePerLesson = price / lessonCount;
      });
    } else {
      setState(() {
        _pricePerLesson = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.package == null
                    ? 'Yeni Ders Paketi'
                    : 'Ders Paketi Düzenle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Paket Adı',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: 8 Derslik Paket',
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
                  labelText: 'Ders Sayısı',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: 8',
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
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Paket Tutarı (₺)',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: 800.00',
                  prefixText: '₺ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Paket tutarı gerekli';
                  }
                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null) {
                    return 'Geçerli bir tutar girin';
                  }
                  if (price <= 0) {
                    return 'Tutar 0\'dan büyük olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Otomatik hesaplanan ders başına tutar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ders Başına Tutar',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _pricePerLesson > 0
                                ? '₺ ${_pricePerLesson.toStringAsFixed(2)}'
                                : '₺ 0.00',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                subtitle: const Text('Bu paket kullanıma açık mı?'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _savePackage,
                    child: Text(
                      widget.package == null ? 'Oluştur' : 'Güncelle',
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

  void _savePackage() {
    if (_formKey.currentState!.validate()) {
      final packageData = {
        'name': _nameController.text,
        'lessonCount': int.parse(_lessonCountController.text),
        'price': double.parse(_priceController.text.replaceAll(',', '.')),
        'isActive': _isActive,
      };

      widget.onSave(packageData);
    }
  }
}
