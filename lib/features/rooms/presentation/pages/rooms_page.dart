import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/navigation_drawer.dart' as custom;
import '../../../../core/widgets/responsive_grid_list.dart';
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/services/role_service.dart';
import '../../data/providers/rooms_providers.dart';
import '../widgets/room_form_dialog.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  Map<String, dynamic> _filters = {};
  bool _isMember = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final isMember = await RoleService.isMember();
      setState(() {
        _isMember = isMember;
        _isLoadingRole = false;
      });
    } catch (e) {
      setState(() {
        _isMember = false;
        _isLoadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Oda Yönetimi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showAddRoomDialog(context, ref),
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Oda Ekle',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const custom.NavigationDrawer(),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildAccessDeniedView(),
      ),
    );
  }

  Widget _buildAdminView() {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Column(
      children: [
        AdminFilterWidget(
          filterOptions: _getRoomFilterOptions(),
          onFilterChanged: _onFilterChanged,
        ),
        Expanded(
          child: roomsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget(
              title: 'Hata',
              message: error.toString(),
              onRetry: () => ref.invalidate(allRoomsProvider),
            ),
            data: (rooms) {
              final filteredRooms = _applyFilters(rooms);

              if (filteredRooms.isEmpty) {
                return const CenteredEmptyWidget(
                  icon: Icons.meeting_room,
                  title: 'Henüz oda eklenmemiş',
                  message: 'Yeni oda eklemek için yukarıdaki butonu kullanın',
                );
              }

              return RefreshableResponsiveGridList(
                items: filteredRooms,
                onRefresh: () async => ref.invalidate(allRoomsProvider),
                itemBuilder: (context, room, index) =>
                    _buildRoomCard(context, room, ref),
                aspectRatio: 1.2,
                maxColumns: 4,
                emptyWidget: const CenteredEmptyWidget(
                  icon: Icons.meeting_room,
                  title: 'Henüz oda eklenmemiş',
                  message: 'Yeni oda eklemek için yukarıdaki butonu kullanın',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccessDeniedView() {
    return const CenteredErrorWidget(
      title: 'Erişim Reddedildi',
      message:
          'Bu sayfaya erişim yetkiniz bulunmamaktadır. Sadece Admin kullanıcılar Oda Yönetimi sayfasına erişebilir.',
      icon: Icons.lock_outline,
    );
  }

  List<FilterOption> _getRoomFilterOptions() {
    return [
      const FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Pasif'],
      ),
      const FilterOption(
        key: 'capacity',
        label: 'Kapasite',
        type: FilterType.dropdown,
        options: ['Tümü', '1-5 kişi', '6-10 kişi', '11-20 kişi', '20+ kişi'],
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturulma Tarihi',
        type: FilterType.dateRange,
      ),
      const FilterOption(
        key: 'is_active',
        label: 'Sadece Aktif Odalar',
        type: FilterType.checkbox,
      ),
    ];
  }

  List<dynamic> _applyFilters(List<dynamic> rooms) {
    if (_filters.isEmpty) return rooms;

    return rooms.where((room) {
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!room.name.toLowerCase().contains(searchTerm) &&
            !(room.features?.toLowerCase().contains(searchTerm) ?? false)) {
          return false;
        }
      }

      if (_filters.containsKey('status') &&
          _filters['status'] != null &&
          _filters['status'] != 'Tümü') {
        final status = _filters['status'] as String;
        if (status == 'Aktif' && !room.isActive) return false;
        if (status == 'Pasif' && room.isActive) return false;
      }

      if (_filters.containsKey('capacity') &&
          _filters['capacity'] != null &&
          _filters['capacity'] != 'Tümü') {
        final capacity = _filters['capacity'] as String;
        final roomCapacity = room.capacity;

        switch (capacity) {
          case '1-5 kişi':
            if (roomCapacity < 1 || roomCapacity > 5) return false;
            break;
          case '6-10 kişi':
            if (roomCapacity < 6 || roomCapacity > 10) return false;
            break;
          case '11-20 kişi':
            if (roomCapacity < 11 || roomCapacity > 20) return false;
            break;
          case '20+ kişi':
            if (roomCapacity < 21) return false;
            break;
        }
      }

      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (room.createdAt.day != filterDate.day ||
            room.createdAt.month != filterDate.month ||
            room.createdAt.year != filterDate.year) {
          return false;
        }
      }

      if (_filters.containsKey('is_active') && _filters['is_active'] == true) {
        if (!room.isActive) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildRoomCard(BuildContext context, room, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: room.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    room.isActive ? 'Aktif' : 'Pasif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Kapasite: ${room.capacity} kişi',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (room.features != null && room.features.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.features,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Oluşturulma: ${_formatDate(room.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const Spacer(),

            if (!_isMember && !_isLoadingRole)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showEditRoomDialog(context, ref, room),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Düzenle',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteRoomDialog(context, ref, room),
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Sil',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => RoomFormDialog(
        onSuccess: () {
          ref.invalidate(allRoomsProvider);
        },
      ),
    );
  }

  void _showEditRoomDialog(BuildContext context, WidgetRef ref, room) {
    showDialog(
      context: context,
      builder: (context) => RoomFormDialog(
        room: room,
        onSuccess: () {
          ref.invalidate(allRoomsProvider);
        },
      ),
    );
  }

  void _showDeleteRoomDialog(BuildContext context, WidgetRef ref, room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oda Sil'),
        content: Text(
          '${room.name} odasını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final repository = ref.read(roomsRepositoryProvider);
                await repository.deleteRoom(room.id);
                ref.invalidate(allRoomsProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${room.name} odası silindi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
