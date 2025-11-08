import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../members/data/providers/members_providers.dart';
import '../../../groups/presentation/providers/groups_providers.dart';
import '../../../rooms/data/providers/rooms_providers.dart';
import '../../../payments/presentation/providers/payments_providers.dart';
import '../../../payments/domain/entities/lesson_package.dart';

class MemberSelectionWidget extends ConsumerStatefulWidget {
  final List<String> selectedMemberIds;
  final String? selectedGroupId;
  final String? selectedRoomId;
  final String? selectedPackageId;
  final Function(List<String>) onMemberIdsChanged;
  final Function(String?) onGroupSelected;
  final Function(Map<String, double>)? onMemberPricesChanged; // memberId -> price

  const MemberSelectionWidget({
    super.key,
    required this.selectedMemberIds,
    required this.selectedGroupId,
    required this.selectedRoomId,
    this.selectedPackageId,
    required this.onMemberIdsChanged,
    required this.onGroupSelected,
    this.onMemberPricesChanged,
  });

  @override
  ConsumerState<MemberSelectionWidget> createState() =>
      _MemberSelectionWidgetState();
}

class _MemberSelectionWidgetState extends ConsumerState<MemberSelectionWidget> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  double? _groupDiscountPercent; // Grup indirimi yüzdesi
  String? _memberWithDiscount; // İndirimli üye ID'si
  double? _memberDiscountPercent; // Üye indirimi yüzdesi

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  // Üye fiyatlarını hesapla ve callback'i çağır
  void _calculateAndNotifyPrices(
    List filteredMembers,
    LessonPackage? selectedPackage,
  ) {
    if (selectedPackage == null || widget.onMemberPricesChanged == null) {
      return;
    }

    final Map<String, double> memberPrices = {};

    for (final member in filteredMembers) {
      if (!widget.selectedMemberIds.contains(member.id)) {
        continue;
      }

      // İndirim hesaplama
      double discountPercent = 0.0;
      if (widget.selectedGroupId != null &&
          member.groupId == widget.selectedGroupId &&
          _groupDiscountPercent != null) {
        discountPercent = _groupDiscountPercent!;
      }
      if (_memberWithDiscount == member.id &&
          _memberDiscountPercent != null) {
        discountPercent = _memberDiscountPercent!;
      }

      // Fiyat hesaplama
      final basePrice = selectedPackage.price;
      final discountedPrice = basePrice * (1 - discountPercent / 100);
      memberPrices[member.id] = discountedPrice;
    }

    widget.onMemberPricesChanged!(memberPrices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '7. Üye Seçimi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu ders programına katılacak üyeleri seçiniz',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Group selection (optional)
              Consumer(
                builder: (context, ref, child) {
                  final groupsAsync = ref.watch(groupsListProvider);

                  return groupsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (groups) {
                      if (groups.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Grup Seç (Opsiyonel)',
                              border: OutlineInputBorder(),
                              hintText: 'Tüm üyeler',
                            ),
                            value: widget.selectedGroupId,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Tüm üyeler'),
                              ),
                              ...groups.map(
                                (group) => DropdownMenuItem(
                                  value: group.id,
                                  child: Text(group.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              widget.onGroupSelected(value);
                              if (value == null) {
                                setState(() {
                                  _groupDiscountPercent = null;
                                });
                              }
                            },
                          ),
                          if (widget.selectedGroupId != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Grup İndirimi (%)',
                                      hintText: 'Örn: 10',
                                      border: const OutlineInputBorder(),
                                      suffixText: '%',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _groupDiscountPercent =
                                            double.tryParse(value);
                                      });
                                      // Fiyatları yeniden hesapla - Consumer içinde yapılacak
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),

              // Member list
              Consumer(
                builder: (context, ref, child) {
                  final membersAsync = ref.watch(membersProvider);

                  return membersAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text(
                      'Üyeler yüklenemedi: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    data: (members) {
                      // Group filtering
                      List filteredMembers = members;
                      if (widget.selectedGroupId != null) {
                        filteredMembers = members
                            .where(
                              (member) =>
                                  member.groupId == widget.selectedGroupId,
                            )
                            .toList();
                      }

                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        filteredMembers = filteredMembers
                            .where(
                              (m) =>
                                  (m.fullName as String).toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  (m.email as String).toLowerCase().contains(
                                    _searchQuery,
                                  ),
                            )
                            .toList();
                      }

                      if (filteredMembers.isEmpty) {
                        return const Text(
                          'Seçilen grupta üye bulunamadı',
                          style: TextStyle(color: Colors.orange),
                        );
                      }

                      final visibleIds = filteredMembers
                          .map<String>((m) => m.id as String)
                          .toList();
                      final int selectedVisibleCount = visibleIds
                          .where((id) => widget.selectedMemberIds.contains(id))
                          .length;
                      final bool noneSelected = selectedVisibleCount == 0;
                      final bool allSelected =
                          selectedVisibleCount == visibleIds.length &&
                          visibleIds.isNotEmpty;
                      final bool partiallySelected =
                          !noneSelected && !allSelected;

                      return Column(
                        children: [
                          // Header actions: Select All + counters + search + clear
                          Row(
                            children: [
                              Checkbox(
                                value: allSelected
                                    ? true
                                    : (partiallySelected ? null : false),
                                tristate: true,
                                onChanged: (value) async {
                                  if (value == true) {
                                    // Get capacity from current state
                                    final rooms = ref.read(roomsProvider).value;
                                    int? capacity;
                                    if (rooms != null) {
                                      final selectedRoom =
                                          rooms
                                              .where(
                                                (room) =>
                                                    room.id ==
                                                    widget.selectedRoomId,
                                              )
                                              .isNotEmpty
                                          ? rooms.firstWhere(
                                              (room) =>
                                                  room.id ==
                                                  widget.selectedRoomId,
                                            )
                                          : null;
                                      if (selectedRoom != null) {
                                        capacity = selectedRoom.capacity;
                                      }
                                    }

                                    // Select all visible
                                    final Set<String> updated = {
                                      ...widget.selectedMemberIds,
                                      ...visibleIds,
                                    };
                                    if (capacity != null &&
                                        updated.length > capacity) {
                                      final proceed =
                                          await _confirmOverCapacity(
                                            context,
                                            updated.length,
                                            capacity,
                                          );
                                      if (!proceed) return;
                                    }
                                    widget.onMemberIdsChanged(updated.toList());
                                  } else {
                                    // Unselect all visible
                                    final Set<String> updated = {
                                      ...widget.selectedMemberIds,
                                    };
                                    for (final id in visibleIds) {
                                      updated.remove(id);
                                    }
                                    widget.onMemberIdsChanged(updated.toList());
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final roomsAsync = ref.watch(roomsProvider);
                                    return roomsAsync.when(
                                      loading: () => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: const Text('Yükleniyor...'),
                                      ),
                                      error: (error, stack) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: const Text('Hata'),
                                      ),
                                      data: (rooms) {
                                        int? capacity;
                                        final selectedRoom =
                                            rooms
                                                .where(
                                                  (room) =>
                                                      room.id ==
                                                      widget.selectedRoomId,
                                                )
                                                .isNotEmpty
                                            ? rooms.firstWhere(
                                                (room) =>
                                                    room.id ==
                                                    widget.selectedRoomId,
                                              )
                                            : null;
                                        if (selectedRoom != null) {
                                          capacity = selectedRoom.capacity;
                                        }
                                        final bool over =
                                            capacity != null &&
                                            widget.selectedMemberIds.length >
                                                capacity;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: over
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: over
                                                  ? Colors.red
                                                  : Colors.blue,
                                            ),
                                          ),
                                          child: Text(
                                            capacity != null
                                                ? 'Seçilen: ${widget.selectedMemberIds.length} / Kapasite: $capacity'
                                                : 'Seçilen: ${widget.selectedMemberIds.length}',
                                            style: TextStyle(
                                              color: over
                                                  ? Colors.red
                                                  : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    prefixIcon: Icon(Icons.search, size: 18),
                                    hintText: 'Üye ara...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Hepsini temizle',
                                onPressed: () {
                                  widget.onMemberIdsChanged([]);
                                },
                                icon: const Icon(Icons.clear_all),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer(
                            builder: (context, ref, child) {
                              final roomsAsync = ref.watch(roomsProvider);
                              return roomsAsync.when(
                                data: (rooms) {
                                  final selectedRoom =
                                      rooms
                                          .where(
                                            (room) =>
                                                room.id ==
                                                widget.selectedRoomId,
                                          )
                                          .isNotEmpty
                                      ? rooms.firstWhere(
                                          (room) =>
                                              room.id == widget.selectedRoomId,
                                        )
                                      : null;

                                  if (selectedRoom != null) {
                                    final isOverCapacity =
                                        widget.selectedMemberIds.length >
                                        selectedRoom.capacity;
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isOverCapacity
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isOverCapacity
                                              ? Colors.red
                                              : Colors.blue,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isOverCapacity
                                                ? Icons.warning
                                                : Icons.info,
                                            color: isOverCapacity
                                                ? Colors.red
                                                : Colors.blue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Seçilen: ${widget.selectedMemberIds.length} / Kapasite: ${selectedRoom.capacity}',
                                            style: TextStyle(
                                              color: isOverCapacity
                                                  ? Colors.red
                                                  : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (error, stack) =>
                                    const SizedBox.shrink(),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Member checkbox list with pricing
                          Consumer(
                            builder: (context, ref, child) {
                              final packagesAsync =
                                  ref.watch(lessonPackagesProvider);

                              return packagesAsync.when(
                                loading: () => Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('Hata: $error'),
                                  ),
                                ),
                                data: (packages) {
                                  LessonPackage? selectedPackage;
                                  if (widget.selectedPackageId != null &&
                                      packages.isNotEmpty) {
                                    try {
                                      selectedPackage = packages.firstWhere(
                                        (p) => p.id == widget.selectedPackageId,
                                      );
                                    } catch (e) {
                                      // Paket bulunamadı, null bırak
                                      selectedPackage = null;
                                    }
                                  }

                                  // Fiyatları hesapla ve callback'i çağır
                                  if (selectedPackage != null) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _calculateAndNotifyPrices(
                                        filteredMembers,
                                        selectedPackage,
                                      );
                                    });
                                  }

                                  if (selectedPackage == null) {
                                    return Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Lütfen önce bir ders paketi seçin',
                                        ),
                                      ),
                                    );
                                  }

                                  return Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListView.builder(
                                      itemCount: filteredMembers.length,
                                      itemBuilder: (context, index) {
                                        final member = filteredMembers[index];
                                        final isSelected =
                                            widget.selectedMemberIds
                                                .contains(member.id);

                                        // İndirim hesaplama
                                        double discountPercent = 0.0;
                                        if (widget.selectedGroupId != null &&
                                            member.groupId ==
                                                widget.selectedGroupId &&
                                            _groupDiscountPercent != null) {
                                          discountPercent =
                                              _groupDiscountPercent!;
                                        }
                                        if (_memberWithDiscount == member.id &&
                                            _memberDiscountPercent != null) {
                                          discountPercent =
                                              _memberDiscountPercent!;
                                        }

                                        // Fiyat hesaplama
                                        if (selectedPackage == null) {
                                          return const SizedBox.shrink();
                                        }
                                        final basePrice = selectedPackage.price;
                                        final discountedPrice = basePrice *
                                            (1 - discountPercent / 100);
                                        final pricePerLesson =
                                            discountedPrice /
                                                selectedPackage.lessonCount;

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: CheckboxListTile(
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  member.fullName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  member.email,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Toplam: ₺${discountedPrice.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: discountPercent >
                                                                    0
                                                                ? Colors.green
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Ders Başına: ₺${pricePerLesson.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (discountPercent > 0)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Text(
                                                          '%${discountPercent.toStringAsFixed(0)} İndirim',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (isSelected &&
                                                    _memberWithDiscount !=
                                                        member.id &&
                                                    (_memberWithDiscount == null ||
                                                        _memberWithDiscount!
                                                            .isEmpty)) ...[
                                                  const SizedBox(height: 4),
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      // Eğer başka bir üyeye indirim varsa, onu kaldır
                                                      if (_memberWithDiscount !=
                                                          null) {
                                                        setState(() {
                                                          _memberWithDiscount =
                                                              null;
                                                          _memberDiscountPercent =
                                                              null;
                                                        });
                                                      }
                                                      setState(() {
                                                        _memberWithDiscount =
                                                            member.id;
                                                      });
                                                      _showMemberDiscountDialog(
                                                        context,
                                                        member.fullName,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.discount,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'İndirim Uygula',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(4),
                                                      minimumSize:
                                                          const Size(0, 0),
                                                    ),
                                                  ),
                                                ],
                                                if (_memberWithDiscount ==
                                                    member.id) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'İndirim: %${_memberDiscountPercent?.toStringAsFixed(0) ?? '0'}',
                                                        style: const TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 16,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _memberWithDiscount =
                                                                null;
                                                            _memberDiscountPercent =
                                                                null;
                                                          });
                                                        },
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                            value: isSelected,
                                            onChanged: (checked) {
                                              final Set<String> updated = {
                                                ...widget.selectedMemberIds,
                                              };
                                              if (checked == true) {
                                                updated.add(member.id);
                                              } else {
                                                updated.remove(member.id);
                                                if (_memberWithDiscount ==
                                                    member.id) {
                                                  setState(() {
                                                    _memberWithDiscount = null;
                                                    _memberDiscountPercent =
                                                        null;
                                                  });
                                                }
                                              }
                                              widget.onMemberIdsChanged(
                                                updated.toList(),
                                              );
                                            },
                                            dense: true,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmOverCapacity(
    BuildContext context,
    int selectedCount,
    int capacity,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kapasite Aşılıyor'),
        content: Text(
          'Seçim $selectedCount kişi olacak ve kapasite $capacity değerini aşıyor. Yine de devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Devam'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMemberDiscountDialog(
    BuildContext context,
    String memberName,
  ) {
    final discountController = TextEditingController();
    if (_memberDiscountPercent != null) {
      discountController.text = _memberDiscountPercent!.toStringAsFixed(0);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$memberName için İndirim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: discountController,
              decoration: const InputDecoration(
                labelText: 'İndirim Yüzdesi (%)',
                hintText: 'Örn: 15',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_memberWithDiscount != null &&
                _memberWithDiscount !=
                    widget.selectedMemberIds.firstWhere(
                      (id) => id == _memberWithDiscount,
                      orElse: () => '',
                    ))
              const Text(
                'Not: Sadece bir üyeye indirim uygulanabilir. Bu üyeye indirim uygulanırsa diğer üyenin indirimi kaldırılacak.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final discountValue = double.tryParse(discountController.text);
              if (discountValue != null && discountValue >= 0 && discountValue <= 100) {
                setState(() {
                  _memberDiscountPercent = discountValue;
                });
                Navigator.of(dialogContext).pop();
                // Fiyatları yeniden hesapla - Consumer içinde yapılacak
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lütfen 0-100 arasında geçerli bir değer girin',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }
}
