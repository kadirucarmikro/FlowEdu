import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/lesson_package.dart';
import '../providers/payments_providers.dart';
import '../../../members/data/providers/members_providers.dart';
import '../../data/providers/payments_providers.dart' as data_providers;

class PaymentFormDialog extends ConsumerStatefulWidget {
  final Payment? payment;
  final Function(Map<String, dynamic>) onSave;

  const PaymentFormDialog({super.key, this.payment, required this.onSave});

  @override
  ConsumerState<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends ConsumerState<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _memberSearchController = TextEditingController();
  String? _selectedMemberId;
  String? _selectedPackageId;
  LessonPackage? _selectedPackage;
  DateTime? _dueDate;
  PaymentStatus _status = PaymentStatus.pending;
  bool _usePercentDiscount = false; // Yüzde mi tutar mı
  String _memberSearchQuery = '';
  String? _scheduleId; // Ders programı ID'si
  DateTime? _scheduleStartDate; // Ders programı başlangıç tarihi
  DateTime? _scheduleEndDate; // Ders programı bitiş tarihi
  List<Map<String, dynamic>> _availableSchedules =
      []; // Seçilebilir ders programları

  @override
  void initState() {
    super.initState();
    _memberSearchController.addListener(() {
      setState(() {
        _memberSearchQuery = _memberSearchController.text.toLowerCase();
      });
    });
    if (widget.payment != null) {
      _selectedMemberId = widget.payment!.memberId;
      _selectedPackageId = widget.payment!.packageId;
      _amountController.text = widget.payment!.amount.toString();
      _discountAmountController.text = widget.payment!.discountAmount
          .toString();
      _dueDate = widget.payment!.dueDate;
      _status = widget.payment!.status;
      _scheduleId = widget.payment!.scheduleId;

      // Üye ve paket seçildiyse, ders programlarını yükle
      if (_selectedMemberId != null && _selectedPackageId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadAvailableSchedules(_selectedMemberId!, _selectedPackageId!);
          // Eğer scheduleId varsa, tarih bilgilerini yükle
          if (_scheduleId != null) {
            _loadMemberPackageDiscount(
              _selectedMemberId!,
              _selectedPackageId!,
              _scheduleId,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountAmountController.dispose();
    _discountPercentController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.payment == null ? 'Yeni Ödeme' : 'Ödeme Düzenle',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üye Seçimi (Arama Özellikli)
                      Consumer(
                        builder: (context, ref, child) {
                          final membersAsync = ref.watch(membersProvider);

                          return membersAsync.when(
                            loading: () => const TextField(
                              decoration: InputDecoration(
                                labelText: 'Üyeler yükleniyor...',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                            error: (error, stack) => TextField(
                              controller: _memberSearchController,
                              decoration: const InputDecoration(
                                labelText: 'Üye Ara',
                                hintText: 'Üye adı veya email ile ara...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                            data: (members) {
                              // Arama filtresi - _memberSearchQuery state değişikliklerini dinlemek için
                              // StatefulBuilder kullanıyoruz
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  // Arama filtresi
                                  var filteredMembers =
                                      _memberSearchQuery.isEmpty
                                      ? members
                                      : members.where((member) {
                                          final fullName =
                                              '${member.firstName} ${member.lastName}'
                                                  .toLowerCase();
                                          final email = member.email
                                              .toLowerCase();
                                          return fullName.contains(
                                                _memberSearchQuery,
                                              ) ||
                                              email.contains(
                                                _memberSearchQuery,
                                              );
                                        }).toList();

                                  // Seçili üye filtrelenmiş listede yoksa, onu da ekle
                                  String? selectedMemberId = _selectedMemberId;
                                  if (selectedMemberId != null) {
                                    final selectedMemberExists = filteredMembers
                                        .any((m) => m.id == selectedMemberId);
                                    if (!selectedMemberExists) {
                                      // Seçili üye filtrelenmiş listede yok, tüm listeden bul
                                      try {
                                        final selectedMember = members
                                            .firstWhere(
                                              (m) => m.id == selectedMemberId,
                                            );
                                        // Filtrelenmiş listeye ekle (başa ekle)
                                        filteredMembers = [
                                          selectedMember,
                                          ...filteredMembers,
                                        ];
                                      } catch (e) {
                                        // Seçili üye bulunamadı, null yap
                                        selectedMemberId = null;
                                        _selectedMemberId = null;
                                      }
                                    }
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Arama kutusu
                                      TextField(
                                        controller: _memberSearchController,
                                        decoration: InputDecoration(
                                          labelText: 'Üye Ara',
                                          hintText:
                                              'Üye adı veya email ile ara...',
                                          prefixIcon: const Icon(Icons.search),
                                          suffixIcon:
                                              _memberSearchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _memberSearchController
                                                        .clear();
                                                  },
                                                )
                                              : null,
                                          border: const OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          final searchQuery = value
                                              .toLowerCase();

                                          // State güncellemesi - hem local hem parent state
                                          setState(() {
                                            _memberSearchQuery = searchQuery;
                                          });
                                          // Parent state'i de güncelle
                                          this.setState(() {
                                            _memberSearchQuery = searchQuery;

                                            // Eğer arama sonucunda tek bir üye varsa, otomatik seç
                                            if (searchQuery.isNotEmpty) {
                                              final filtered = members.where((
                                                member,
                                              ) {
                                                final fullName =
                                                    '${member.firstName} ${member.lastName}'
                                                        .toLowerCase();
                                                final email = member.email
                                                    .toLowerCase();
                                                return fullName.contains(
                                                      searchQuery,
                                                    ) ||
                                                    email.contains(searchQuery);
                                              }).toList();

                                              // Tek sonuç varsa ve henüz seçili değilse, otomatik seç
                                              if (filtered.length == 1 &&
                                                  _selectedMemberId !=
                                                      filtered.first.id) {
                                                _selectedMemberId =
                                                    filtered.first.id;
                                              }
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      // Üye listesi (Dropdown)
                                      DropdownButtonFormField<String>(
                                        value: selectedMemberId,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Üye Seçin',
                                          border: OutlineInputBorder(),
                                          hintText: 'Yukarıdan arama yapın',
                                        ),
                                        items: filteredMembers.isEmpty
                                            ? [
                                                const DropdownMenuItem(
                                                  value: null,
                                                  child: Text('Üye bulunamadı'),
                                                  enabled: false,
                                                ),
                                              ]
                                            : filteredMembers.map((member) {
                                                return DropdownMenuItem(
                                                  value: member.id,
                                                  child: Text(
                                                    '${member.firstName} ${member.lastName}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                        onChanged: (value) {
                                          this.setState(() {
                                            _selectedMemberId = value;
                                          });

                                          // Üye ve paket seçildiyse, ders programlarını yükle
                                          if (value != null &&
                                              _selectedPackageId != null) {
                                            _loadAvailableSchedules(
                                              value,
                                              _selectedPackageId!,
                                            );
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Üye seçimi gerekli';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Paket Seçimi (Fiyat Gösterimi ile)
                      Consumer(
                        builder: (context, ref, child) {
                          final packagesAsync = ref.watch(
                            lessonPackagesProvider,
                          );

                          return packagesAsync.when(
                            data: (packages) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedPackageId,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Paket Seçin',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: packages.map((package) {
                                    return DropdownMenuItem(
                                      value: package.id,
                                      child: Text(
                                        '${package.name} (${package.lessonCount} Ders) - ${package.price.toStringAsFixed(2)} TL',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPackageId = value;
                                      if (value != null) {
                                        try {
                                          _selectedPackage = packages
                                              .firstWhere((p) => p.id == value);
                                        } catch (e) {
                                          // Paket bulunamadı, ilk paketi seç
                                          if (packages.isNotEmpty) {
                                            _selectedPackage = packages.first;
                                            _selectedPackageId =
                                                packages.first.id;
                                          }
                                        }
                                      }
                                    });

                                    // Üye ve paket seçildiyse, ders programlarını yükle
                                    if (value != null &&
                                        _selectedMemberId != null) {
                                      _loadAvailableSchedules(
                                        _selectedMemberId!,
                                        value,
                                      );
                                    } else if (value != null &&
                                        _amountController.text.isEmpty) {
                                      // Sadece paket seçildiyse ve tutar boşsa, paket fiyatını doldur
                                      setState(() {
                                        _amountController.text =
                                            _selectedPackage!.price
                                                .toStringAsFixed(2);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Paket seçimi gerekli';
                                    }
                                    return null;
                                  },
                                ),
                                // Seçilen paket bilgileri
                                if (_selectedPackage != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Paket Fiyatı: ${_selectedPackage!.price.toStringAsFixed(2)} TL',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                              Text(
                                                'Ders Başına: ${_selectedPackage!.pricePerLesson.toStringAsFixed(2)} TL',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            loading: () => DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Paketler yükleniyor...',
                                border: OutlineInputBorder(),
                              ),
                              items: [],
                              onChanged: null,
                            ),
                            error: (error, stack) =>
                                DropdownButtonFormField<String>(
                                  value: _selectedPackageId,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Paket Seçin (Mock Veri)',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ref.watch(mockPackagesProvider).map((
                                    package,
                                  ) {
                                    return DropdownMenuItem(
                                      value: package['id'],
                                      child: Text(
                                        package['name']!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPackageId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Paket seçimi gerekli';
                                    }
                                    return null;
                                  },
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Ders Programı Seçimi (Üye ve Paket seçildikten sonra görünür)
                      if (_selectedMemberId != null &&
                          _selectedPackageId != null)
                        _buildScheduleSelection(),
                      const SizedBox(height: 16),
                      // Tutar
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Tutar (TL)',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: 1500.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tutar gerekli';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Geçerli bir tutar girin';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Tutar 0\'dan büyük olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // İndirim Tipi Seçimi
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Tutar'),
                              value: false,
                              groupValue: _usePercentDiscount,
                              onChanged: (value) {
                                setState(() {
                                  _usePercentDiscount = false;
                                  _discountPercentController.clear();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Yüzde'),
                              value: true,
                              groupValue: _usePercentDiscount,
                              onChanged: (value) {
                                setState(() {
                                  _usePercentDiscount = true;
                                  _discountAmountController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // İndirim Girişi
                      TextFormField(
                        controller: _usePercentDiscount
                            ? _discountPercentController
                            : _discountAmountController,
                        decoration: InputDecoration(
                          labelText: _usePercentDiscount
                              ? 'İndirim (%)'
                              : 'İndirim (TL)',
                          hintText: _usePercentDiscount
                              ? 'Örn: 10'
                              : 'Örn: 150.00',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            _usePercentDiscount
                                ? Icons.percent
                                : Icons.currency_lira,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Geçerli bir değer girin';
                            }
                            final discountValue = double.parse(value);
                            if (discountValue < 0) {
                              return 'İndirim negatif olamaz';
                            }
                            if (_usePercentDiscount && discountValue > 100) {
                              return 'İndirim %100\'den fazla olamaz';
                            }
                            // Tutar kontrolü
                            if (!_usePercentDiscount &&
                                _amountController.text.isNotEmpty) {
                              final amount = double.tryParse(
                                _amountController.text,
                              );
                              if (amount != null && discountValue > amount) {
                                return 'İndirim tutardan fazla olamaz';
                              }
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            // Yüzde seçildiyse tutarı hesapla
                            if (_usePercentDiscount &&
                                value.isNotEmpty &&
                                _amountController.text.isNotEmpty) {
                              final amount = double.tryParse(
                                _amountController.text,
                              );
                              final percent = double.tryParse(value);
                              if (amount != null && percent != null) {
                                final discountAmount = amount * (percent / 100);
                                _discountAmountController.text = discountAmount
                                    .toStringAsFixed(2);
                              }
                            }
                          });
                        },
                      ),
                      // Net tutar gösterimi
                      _buildNetAmountDisplay(),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaymentStatus>(
                        initialValue: _status,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Durum',
                          border: OutlineInputBorder(),
                        ),
                        items: PaymentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              _getStatusText(status),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _status = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDueDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                _dueDate != null
                                    ? 'Vade Tarihi: ${_formatDate(_dueDate!)}'
                                    : 'Vade Tarihi Seçin',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Footer buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _savePayment,
                      child: Text(
                        widget.payment == null ? 'Oluştur' : 'Güncelle',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  // Üye ve paket seçildiğinde ders programlarını yükle
  void _loadAvailableSchedules(String memberId, String packageId) async {
    try {
      final repository = ref.read(data_providers.paymentsRepositoryProvider);
      final schedules = await repository.getMemberPackageSchedules(
        memberId,
        packageId,
      );

      if (mounted) {
        setState(() {
          _availableSchedules = schedules;
          // Eğer schedule yoksa, mevcut seçimi temizle
          if (schedules.isEmpty) {
            _scheduleId = null;
            _scheduleStartDate = null;
            _scheduleEndDate = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSchedules = [];
        });
      }
    }
  }

  // Ders programı seçildiğinde tarih ve fiyat bilgilerini yükle
  void _onScheduleSelected(String? scheduleId) async {
    if (scheduleId == null ||
        _selectedMemberId == null ||
        _selectedPackageId == null) {
      setState(() {
        _scheduleId = null;
        _scheduleStartDate = null;
        _scheduleEndDate = null;
      });
      return;
    }

    // Seçilen schedule'ı bul
    final selectedSchedule = _availableSchedules.firstWhere(
      (s) => s['scheduleId'] == scheduleId,
      orElse: () => _availableSchedules.first,
    );

    setState(() {
      _scheduleId = selectedSchedule['scheduleId'] as String?;
      final startDateStr = selectedSchedule['startDate'] as String?;
      final endDateStr = selectedSchedule['endDate'] as String?;

      if (startDateStr != null) {
        _scheduleStartDate = DateTime.parse(startDateStr);
      }
      if (endDateStr != null) {
        _scheduleEndDate = DateTime.parse(endDateStr);
      }
    });

    // Seçilen schedule için fiyat ve indirim bilgisini yükle
    _loadMemberPackageDiscount(
      _selectedMemberId!,
      _selectedPackageId!,
      scheduleId,
    );
  }

  // Üye ve paket için lesson_attendees tablosundan tutar ve indirim bilgisini yükle
  void _loadMemberPackageDiscount(
    String memberId,
    String packageId, [
    String? specificScheduleId,
  ]) async {
    try {
      final repository = ref.read(data_providers.paymentsRepositoryProvider);
      final priceAndDiscount = await repository
          .getMemberPackagePriceAndDiscount(
            memberId,
            packageId,
            specificScheduleId,
          );

      if (priceAndDiscount != null && mounted) {
        final amount = priceAndDiscount['amount'] as double;
        final discountAmount = priceAndDiscount['discountAmount'] as double;
        final discountPercent = priceAndDiscount['discountPercent'] as double;
        final scheduleId = priceAndDiscount['scheduleId'] as String?;
        final startDateStr = priceAndDiscount['startDate'] as String?;
        final endDateStr = priceAndDiscount['endDate'] as String?;

        // Tutar ve indirim bilgisi bulundu, otomatik doldur
        if (mounted) {
          setState(() {
            // Tutarı doldur (lesson_attendees'den gelen veri öncelikli)
            _amountController.text = amount.toStringAsFixed(2);

            // Ders programı bilgilerini kaydet
            _scheduleId = scheduleId;
            if (startDateStr != null) {
              _scheduleStartDate = DateTime.parse(startDateStr);
            }
            if (endDateStr != null) {
              _scheduleEndDate = DateTime.parse(endDateStr);
            }

            // İndirimi doldur - Ders programında indirim her zaman yüzde olarak tanımlanıyor
            // Bu yüzden öncelikle yüzde indirimi kullan
            if (discountPercent > 0) {
              _usePercentDiscount = true;
              _discountPercentController.text = discountPercent.toStringAsFixed(
                2,
              );
              _discountAmountController.clear();
            } else if (discountAmount > 0) {
              // Eğer yüzde yoksa ama tutar varsa, tutar olarak doldur
              _usePercentDiscount = false;
              _discountAmountController.text = discountAmount.toStringAsFixed(
                2,
              );
              _discountPercentController.clear();
            } else {
              // İndirim yoksa alanları temizle
              _discountPercentController.clear();
              _discountAmountController.clear();
            }
          });
        }
      } else {
        // Veri bulunamadığında tarih bilgilerini temizle
        setState(() {
          _scheduleId = null;
          _scheduleStartDate = null;
          _scheduleEndDate = null;
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
      // Kullanıcı manuel olarak tutar ve indirim girebilir
    }
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      // Aynı üye-paket-schedule için ödeme kontrolü
      if (_scheduleId != null &&
          _selectedMemberId != null &&
          _selectedPackageId != null) {
        try {
          final repository = ref.read(
            data_providers.paymentsRepositoryProvider,
          );
          final hasExistingPayment = await (repository as dynamic)
              .checkExistingPaymentForSchedule(
                _selectedMemberId!,
                _selectedPackageId!,
                _scheduleId!,
              );

          if (hasExistingPayment == true) {
            // Aynı ders programı için ödeme var
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bu üye için bu paket ve ders programı için zaten bir ödeme kaydı bulunmaktadır. Lütfen farklı bir ders programı seçin veya mevcut ödemeyi düzenleyin.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            }
            return;
          }
        } catch (e) {
          // Hata durumunda devam et
        }
      }

      // İndirim hesaplama
      double discountAmount = 0.0;
      if (_usePercentDiscount && _discountPercentController.text.isNotEmpty) {
        final amount = double.parse(_amountController.text);
        final percent = double.parse(_discountPercentController.text);
        discountAmount = amount * (percent / 100);
      } else if (!_usePercentDiscount &&
          _discountAmountController.text.isNotEmpty) {
        discountAmount = double.parse(_discountAmountController.text);
      }

      final paymentData = {
        'memberId': _selectedMemberId!,
        'packageId': _selectedPackageId!,
        'amount': double.parse(_amountController.text),
        'discountAmount': discountAmount,
        'dueDate': _dueDate,
        'status': _status,
        'scheduleId': _scheduleId,
      };

      widget.onSave(paymentData);
    }
  }

  // Ders programı seçimi dropdown widget'ı
  Widget _buildScheduleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _scheduleId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Ders Programı Seçin',
            border: OutlineInputBorder(),
            hintText: 'Ders programı seçin...',
          ),
          items: _availableSchedules.isEmpty
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Ders programı bulunamadı'),
                    enabled: false,
                  ),
                ]
              : _availableSchedules.map((schedule) {
                  final startDateStr = schedule['startDate'] as String?;
                  final endDateStr = schedule['endDate'] as String?;
                  final scheduleId = schedule['scheduleId'] as String;

                  String displayText = 'Ders Programı';
                  if (startDateStr != null && endDateStr != null) {
                    try {
                      final startDate = DateTime.parse(startDateStr);
                      final endDate = DateTime.parse(endDateStr);
                      displayText =
                          '${_formatDate(startDate)} - ${_formatDate(endDate)}';
                    } catch (e) {
                      displayText = 'Ders Programı';
                    }
                  }

                  return DropdownMenuItem(
                    value: scheduleId,
                    child: Text(displayText, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
          onChanged: (value) {
            _onScheduleSelected(value);
          },
          validator: (value) {
            if (_availableSchedules.isNotEmpty &&
                (value == null || value.isEmpty)) {
              return 'Ders programı seçimi gerekli';
            }
            return null;
          },
        ),
        // Seçilen ders programı tarih bilgileri
        if (_scheduleStartDate != null || _scheduleEndDate != null)
          _buildScheduleDateInfo(),
      ],
    );
  }

  // Ders programı tarih bilgilerini gösteren widget
  Widget _buildScheduleDateInfo() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ders Programı Tarihleri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_scheduleStartDate != null)
                      Text(
                        'Başlangıç: ${_formatDate(_scheduleStartDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    if (_scheduleEndDate != null)
                      Text(
                        'Bitiş: ${_formatDate(_scheduleEndDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.failed:
        return 'Başarısız';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildNetAmountDisplay() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    double discount = 0.0;
    if (_usePercentDiscount) {
      final percent = double.tryParse(_discountPercentController.text) ?? 0.0;
      discount = amount * (percent / 100);
    } else {
      discount = double.tryParse(_discountAmountController.text) ?? 0.0;
    }
    final netAmount = amount - discount;

    if (amount > 0 || discount > 0) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calculate, size: 20, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Net Tutar: ${netAmount.toStringAsFixed(2)} TL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
