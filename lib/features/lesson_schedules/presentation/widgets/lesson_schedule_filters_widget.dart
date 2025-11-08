import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payments/presentation/providers/payments_providers.dart';
import '../../../members/data/providers/members_providers.dart';
import '../../../rooms/data/providers/rooms_providers.dart';
import '../../../groups/presentation/providers/groups_providers.dart';
import '../providers/lesson_schedules_providers.dart';

class LessonScheduleFilters {
  String? packageId;
  DateTime? startDate;
  List<String> selectedDays;
  int? lessonDuration; // dakika cinsinden
  String? instructorId;
  String? roomId;
  String? memberId;
  String? groupId;

  LessonScheduleFilters({
    this.packageId,
    this.startDate,
    this.selectedDays = const [],
    this.lessonDuration,
    this.instructorId,
    this.roomId,
    this.memberId,
    this.groupId,
  });

  LessonScheduleFilters copyWith({
    String? packageId,
    DateTime? startDate,
    List<String>? selectedDays,
    int? lessonDuration,
    String? instructorId,
    String? roomId,
    String? memberId,
    String? groupId,
  }) {
    return LessonScheduleFilters(
      packageId: packageId ?? this.packageId,
      startDate: startDate ?? this.startDate,
      selectedDays: selectedDays ?? this.selectedDays,
      lessonDuration: lessonDuration ?? this.lessonDuration,
      instructorId: instructorId ?? this.instructorId,
      roomId: roomId ?? this.roomId,
      memberId: memberId ?? this.memberId,
      groupId: groupId ?? this.groupId,
    );
  }

  bool get hasActiveFilters {
    return packageId != null ||
        startDate != null ||
        selectedDays.isNotEmpty ||
        lessonDuration != null ||
        instructorId != null ||
        roomId != null ||
        memberId != null ||
        groupId != null;
  }

  void clear() {
    packageId = null;
    startDate = null;
    selectedDays = [];
    lessonDuration = null;
    instructorId = null;
    roomId = null;
    memberId = null;
    groupId = null;
  }
}

class LessonScheduleFiltersWidget extends ConsumerStatefulWidget {
  final LessonScheduleFilters filters;
  final Function(LessonScheduleFilters) onFiltersChanged;

  const LessonScheduleFiltersWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<LessonScheduleFiltersWidget> createState() =>
      _LessonScheduleFiltersWidgetState();
}

class _LessonScheduleFiltersWidgetState
    extends ConsumerState<LessonScheduleFiltersWidget>
    with SingleTickerProviderStateMixin {
  late LessonScheduleFilters _filters;
  late TabController _tabController;
  bool _isExpanded = false; // Başlangıçta kapalı

  @override
  void initState() {
    super.initState();
    _filters = widget.filters.copyWith();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header with clear button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtreler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_filters.hasActiveFilters) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_getActiveFilterCount()} aktif',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Tümünü Temizle',
                      onPressed: () {
                        setState(() {
                          _filters.clear();
                        });
                        _updateFilters();
                      },
                    ),
                  ],
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          // Tab Bar ve Tab Bar View - Sadece açıkken göster
          if (_isExpanded) ...[
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: 'Temel Bilgiler',
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Eğitmen & Oda',
                ),
                Tab(
                  icon: Icon(Icons.group),
                  text: 'Üye & Grup',
                ),
              ],
            ),
            // Tab Bar View
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Temel Bilgiler
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPackageFilter(),
                        const SizedBox(height: 16),
                        _buildStartDateFilter(),
                        const SizedBox(height: 16),
                        _buildDaysFilter(),
                        const SizedBox(height: 16),
                        _buildDurationFilter(),
                      ],
                    ),
                  ),
                  // Tab 2: Eğitmen & Oda
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructorFilter(),
                        const SizedBox(height: 16),
                        _buildRoomFilter(),
                      ],
                    ),
                  ),
                  // Tab 3: Üye & Grup
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMemberGroupFilter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Ders Paketi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final packagesAsync = ref.watch(lessonPackagesProvider);

            return packagesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
              data: (packages) {
                return DropdownButtonFormField<String>(
                  value: _filters.packageId,
                  decoration: const InputDecoration(
                    labelText: 'Ders Paketi',
                    border: OutlineInputBorder(),
                    hintText: 'Tüm paketler',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tüm paketler'),
                    ),
                    ...packages.map(
                      (package) => DropdownMenuItem(
                        value: package.id,
                        child: Text(
                          '${package.name} (${package.lessonCount} Ders)',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(packageId: value);
                    });
                    _updateFilters();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStartDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Başlangıç Tarihi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _filters.startDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _filters = _filters.copyWith(startDate: pickedDate);
              });
              _updateFilters();
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Başlangıç Tarihi',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _filters.startDate != null
                  ? '${_filters.startDate!.day}/${_filters.startDate!.month}/${_filters.startDate!.year}'
                  : 'Tarih seçiniz',
              style: TextStyle(
                color: _filters.startDate != null
                    ? Colors.black
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
        if (_filters.startDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _filters = _filters.copyWith(startDate: null);
                });
                _updateFilters();
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Temizle'),
            ),
          ),
      ],
    );
  }

  Widget _buildDaysFilter() {
    const daysOfWeek = [
      {'key': 'Monday', 'label': 'Pazartesi'},
      {'key': 'Tuesday', 'label': 'Salı'},
      {'key': 'Wednesday', 'label': 'Çarşamba'},
      {'key': 'Thursday', 'label': 'Perşembe'},
      {'key': 'Friday', 'label': 'Cuma'},
      {'key': 'Saturday', 'label': 'Cumartesi'},
      {'key': 'Sunday', 'label': 'Pazar'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Haftalık Ders Günleri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: daysOfWeek.map((day) {
            final isSelected = _filters.selectedDays.contains(day['key']);
            return FilterChip(
              label: Text(day['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newDays = List<String>.from(_filters.selectedDays);
                  if (selected) {
                    newDays.add(day['key']!);
                  } else {
                    newDays.remove(day['key']);
                  }
                  _filters = _filters.copyWith(selectedDays: newDays);
                });
                _updateFilters();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Ders Süresi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final durationsAsync = ref.watch(uniqueLessonDurationsProvider);

            return durationsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
              data: (durations) {
                if (durations.isEmpty) {
                  return const Text('Henüz ders süresi kaydı yok');
                }

                return DropdownButtonFormField<int>(
                  value: _filters.lessonDuration,
                  decoration: const InputDecoration(
                    labelText: 'Ders Süresi (Dakika)',
                    border: OutlineInputBorder(),
                    hintText: 'Tüm süreler',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tüm süreler'),
                    ),
                    ...durations.map(
                      (duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration dakika'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(lessonDuration: value);
                    });
                    _updateFilters();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Eğitmen Seçimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final instructorsAsync = ref.watch(instructorMembersProvider);

            return instructorsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
              data: (instructors) {
                if (instructors.isEmpty) {
                  return const Text('Henüz eğitmen kaydı yok');
                }

                return DropdownButtonFormField<String>(
                  value: _filters.instructorId,
                  decoration: const InputDecoration(
                    labelText: 'Eğitmen',
                    border: OutlineInputBorder(),
                    hintText: 'Tüm eğitmenler',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tüm eğitmenler'),
                    ),
                    ...instructors.map(
                      (instructor) => DropdownMenuItem(
                        value: instructor.id,
                        child: Text(instructor.fullName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(instructorId: value);
                    });
                    _updateFilters();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoomFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. Oda Seçimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final roomsAsync = ref.watch(roomsProvider);

            return roomsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return const Text('Henüz oda kaydı yok');
                }

                return DropdownButtonFormField<String>(
                  value: _filters.roomId,
                  decoration: const InputDecoration(
                    labelText: 'Oda',
                    border: OutlineInputBorder(),
                    hintText: 'Tüm odalar',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tüm odalar'),
                    ),
                    ...rooms.map(
                      (room) => DropdownMenuItem(
                        value: room.id,
                        child: Text(room.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(roomId: value);
                    });
                    _updateFilters();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMemberGroupFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7. Üye/Grup Seçimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Grup seçimi
        Consumer(
          builder: (context, ref, child) {
            final groupsAsync = ref.watch(groupsListProvider);

            return groupsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (groups) {
                if (groups.isNotEmpty) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _filters.groupId,
                        decoration: const InputDecoration(
                          labelText: 'Grup',
                          border: OutlineInputBorder(),
                          hintText: 'Tüm gruplar',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tüm gruplar'),
                          ),
                          ...groups.map(
                            (group) => DropdownMenuItem(
                              value: group.id,
                              child: Text(group.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filters = _filters.copyWith(
                              groupId: value,
                              memberId: value != null ? null : _filters.memberId,
                            );
                          });
                          _updateFilters();
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        // Üye seçimi
        Consumer(
          builder: (context, ref, child) {
            final membersAsync = ref.watch(membersProvider);

            return membersAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Hata: $error'),
              data: (members) {
                // Grup filtresi varsa, sadece o gruba ait üyeleri göster
                List filteredMembers = members;
                if (_filters.groupId != null) {
                  filteredMembers = members
                      .where(
                        (member) => member.groupId == _filters.groupId,
                      )
                      .toList();
                }

                return DropdownButtonFormField<String>(
                  value: _filters.memberId,
                  decoration: const InputDecoration(
                    labelText: 'Üye',
                    border: OutlineInputBorder(),
                    hintText: 'Tüm üyeler',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tüm üyeler'),
                    ),
                    ...filteredMembers.map(
                      (member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.fullName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(memberId: value);
                    });
                    _updateFilters();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_filters.packageId != null) count++;
    if (_filters.startDate != null) count++;
    if (_filters.selectedDays.isNotEmpty) count++;
    if (_filters.lessonDuration != null) count++;
    if (_filters.instructorId != null) count++;
    if (_filters.roomId != null) count++;
    if (_filters.memberId != null) count++;
    if (_filters.groupId != null) count++;
    return count;
  }
}

