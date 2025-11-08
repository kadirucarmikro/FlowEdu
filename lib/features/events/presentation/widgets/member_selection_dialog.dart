import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/member_entity.dart';
import '../../../members/data/members_repository_impl.dart';
import '../../../../core/widgets/centered_error_widget.dart';

class MemberSelectionDialog extends ConsumerStatefulWidget {
  const MemberSelectionDialog({
    super.key,
    required this.title,
    required this.onMembersSelected,
    this.selectedMembers = const [],
    this.multipleSelection = true,
  });

  final String title;
  final Function(List<Member>) onMembersSelected;
  final List<Member> selectedMembers;
  final bool multipleSelection;

  @override
  ConsumerState<MemberSelectionDialog> createState() =>
      _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends ConsumerState<MemberSelectionDialog> {
  final List<Member> _selectedMembers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Members provider
  static final membersRepositoryProvider = Provider<MembersRepositoryImpl>((
    ref,
  ) {
    return MembersRepositoryImpl(Supabase.instance.client);
  });

  static final allMembersProvider = FutureProvider<List<MemberEntity>>((
    ref,
  ) async {
    final repo = ref.watch(membersRepositoryProvider);
    return repo.getAllMembers();
  });

  @override
  void initState() {
    super.initState();
    _selectedMembers.addAll(widget.selectedMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Üye ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Members list
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final membersAsync = ref.watch(allMembersProvider);

                  return membersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => CenteredErrorWidget.generalError(
                      message: 'Üyeler yüklenirken hata oluştu: $error',
                      onRetry: () => ref.invalidate(allMembersProvider),
                    ),
                    data: (members) => _buildMembersList(members),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedMembers.length} üye seçildi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _selectedMembers.isNotEmpty
                            ? () {
                                widget.onMembersSelected(_selectedMembers);
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: const Text('Seç'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<MemberEntity> members) {
    // MemberEntity'yi Member'a dönüştür
    final memberList = members
        .map(
          (entity) => Member(
            id: entity.id,
            userId: entity.userId,
            roleId: entity.roleId ?? '',
            groupId: entity.groupId ?? '',
            firstName: entity.firstName,
            lastName: entity.lastName,
            phone: entity.phone ?? '',
            email: entity.email,
            birthDate: entity.birthDate,
            isSuspended: entity.isSuspended,
            createdAt: entity.createdDate ?? DateTime.now(),
          ),
        )
        .toList();

    final filteredMembers = memberList.where((member) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return member.firstName.toLowerCase().contains(query) ||
          member.lastName.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query);
    }).toList();

    if (filteredMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Henüz üye kaydı bulunmuyor'
                  : 'Arama kriterlerine uygun üye bulunamadı',
              style: const TextStyle(color: Colors.grey),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('İlk Üyeyi Ekle'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        final isSelected = _selectedMembers.any((m) => m.id == member.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              '${member.firstName.isNotEmpty ? member.firstName[0] : '?'}${member.lastName.isNotEmpty ? member.lastName[0] : '?'}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text('${member.firstName} ${member.lastName}'),
          subtitle: Text(member.email),
          trailing: widget.multipleSelection
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedMembers.add(member);
                      } else {
                        _selectedMembers.removeWhere((m) => m.id == member.id);
                      }
                    });
                  },
                )
              : Radio<bool>(
                  value: isSelected,
                  groupValue: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedMembers.clear();
                      _selectedMembers.add(member);
                    });
                  },
                ),
          onTap: () {
            if (widget.multipleSelection) {
              setState(() {
                if (isSelected) {
                  _selectedMembers.removeWhere((m) => m.id == member.id);
                } else {
                  _selectedMembers.add(member);
                }
              });
            } else {
              setState(() {
                _selectedMembers.clear();
                _selectedMembers.add(member);
              });
            }
          },
        );
      },
    );
  }
}
