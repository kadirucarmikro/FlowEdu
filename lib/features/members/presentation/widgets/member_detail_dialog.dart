import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/member_entity.dart';
import '../members_page.dart';
import 'member_edit_dialog.dart';

class MemberDetailDialog extends ConsumerWidget {
  final MemberEntity member;

  const MemberDetailDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: member.isSuspended
                        ? Colors.red
                        : Colors.green,
                    child: Text(
                      member.firstName.isNotEmpty
                          ? member.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.firstName} ${member.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Kişisel Bilgiler', [
                      _buildDetailRow(
                        'Ad Soyad',
                        '${member.firstName} ${member.lastName}',
                      ),
                      _buildDetailRow('E-posta', member.email),
                      if (member.phone != null && member.phone!.isNotEmpty)
                        _buildDetailRow('Telefon', member.phone!),
                      if (member.birthDate != null)
                        _buildDetailRow(
                          'Doğum Tarihi',
                          '${member.birthDate!.day}/${member.birthDate!.month}/${member.birthDate!.year}',
                        ),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Sistem Bilgileri', [
                      _buildDetailRow(
                        'Rol',
                        member.roleName.isNotEmpty ? member.roleName : '-',
                      ),
                      _buildDetailRow(
                        'Grup',
                        member.groupName.isNotEmpty ? member.groupName : '-',
                      ),
                      _buildDetailRow(
                        'Durum',
                        member.isSuspended ? 'Askıda' : 'Aktif',
                        valueColor: member.isSuspended
                            ? Colors.red
                            : Colors.green,
                      ),
                      if (member.createdDate != null)
                        _buildDetailRow(
                          'Kayıt Tarihi',
                          '${member.createdDate!.day}/${member.createdDate!.month}/${member.createdDate!.year}',
                        ),
                    ]),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _editMember(context, ref);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Düzenle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteMember(context, ref);
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Sil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editMember(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => MemberEditDialog(
        member: member,
        onSuccess: () {
          // Refresh the list after successful edit
          ref.invalidate(allMembersProvider);
        },
      ),
    );
  }

  void _deleteMember(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Üyeyi Sil'),
        content: Text(
          '${member.firstName} ${member.lastName} adlı üyeyi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                ref.invalidate(allMembersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Üye başarıyla silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
