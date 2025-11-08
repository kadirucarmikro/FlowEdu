import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification.dart' as domain;
import '../providers/notifications_providers.dart';
import '../providers/selection_data_providers.dart';

class NotificationFormDialog extends ConsumerStatefulWidget {
  final domain.Notification? notification;

  const NotificationFormDialog({super.key, this.notification});

  @override
  ConsumerState<NotificationFormDialog> createState() =>
      _NotificationFormDialogState();
}

class _NotificationFormDialogState
    extends ConsumerState<NotificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  // Hedef seçimi
  String _selectedTargetType = 'role';
  String? _selectedGroupId;
  String? _selectedRoleId;
  String? _selectedMemberId;
  bool _includeBirthday = false;

  @override
  void initState() {
    super.initState();
    if (widget.notification != null) {
      _titleController.text = widget.notification!.title;
      _bodyController.text = widget.notification!.body ?? '';
      _loadNotificationTargets();
    }
  }

  Future<void> _loadNotificationTargets() async {
    if (widget.notification == null) return;

    try {
      // Notification targets'ı yükle
      final response = await Supabase.instance.client
          .from('notification_targets')
          .select('target_type, target_id')
          .eq('notification_id', widget.notification!.id);

      if (response.isNotEmpty) {
        final target = response.first;
        final targetType = target['target_type'] as String;
        final targetId = target['target_id'] as String?;

        setState(() {
          _selectedTargetType = targetType;
          _selectedGroupId = targetType == 'group' ? targetId : null;
          _selectedRoleId = targetType == 'role' ? targetId : null;
          _selectedMemberId = targetType == 'member' ? targetId : null;
          _includeBirthday = targetType == 'birthday';
        });
      }
    } catch (e) {
      // Hata durumunda varsayılan değerleri kullan
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.notification == null ? 'Yeni Bildirim' : 'Bildirimi Düzenle',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 768 ? 600 : null,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // İçerik
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'İçerik',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Hedef türü seçimi
                const Text(
                  'Hedef Seçimi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                _buildTargetTypeSelector(),
                const SizedBox(height: 16),

                // Hedef seçimi
                _buildTargetSelector(),
                const SizedBox(height: 16),

                // Hedef önizleme
                _buildTargetPreview(),

                const SizedBox(height: 16),

                // Doğum günü seçeneği
                CheckboxListTile(
                  title: const Text('Doğum günü yaklaşan üyelere de gönder'),
                  subtitle: const Text(
                    'Bugün doğum günü olan üyelere otomatik gönderilir',
                  ),
                  value: _includeBirthday,
                  onChanged: (value) {
                    setState(() {
                      _includeBirthday = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.notification == null ? 'Oluştur' : 'Güncelle'),
        ),
      ],
    );
  }

  Widget _buildTargetTypeSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Rol'),
          subtitle: const Text('Belirli bir role sahip üyelere gönder'),
          value: 'role',
          groupValue: _selectedTargetType,
          onChanged: (value) {
            setState(() {
              _selectedTargetType = value!;
              _selectedGroupId = null;
              _selectedRoleId = null;
              _selectedMemberId = null;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Grup'),
          subtitle: const Text('Belirli bir gruba gönder'),
          value: 'group',
          groupValue: _selectedTargetType,
          onChanged: (value) {
            setState(() {
              _selectedTargetType = value!;
              _selectedGroupId = null;
              _selectedRoleId = null;
              _selectedMemberId = null;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Üye'),
          subtitle: const Text('Belirli bir üyeye gönder'),
          value: 'member',
          groupValue: _selectedTargetType,
          onChanged: (value) {
            setState(() {
              _selectedTargetType = value!;
              _selectedGroupId = null;
              _selectedRoleId = null;
              _selectedMemberId = null;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Doğum Günü'),
          subtitle: const Text('Doğum günü yaklaşan üyelere gönder'),
          value: 'birthday',
          groupValue: _selectedTargetType,
          onChanged: (value) {
            setState(() {
              _selectedTargetType = value!;
              _selectedGroupId = null;
              _selectedRoleId = null;
              _selectedMemberId = null;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTargetSelector() {
    switch (_selectedTargetType) {
      case 'role':
        return _buildRoleSelector();
      case 'group':
        return _buildGroupSelector();
      case 'member':
        return _buildMemberSelector();
      case 'birthday':
        return _buildBirthdaySelector();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGroupSelector() {
    final groupsAsync = ref.watch(groupsProvider);

    return groupsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Hata: $error'),
      data: (groups) {
        if (groups.isEmpty) {
          return const Text('Grup bulunamadı');
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedGroupId,
          decoration: const InputDecoration(
            labelText: 'Grup Seçin',
            border: OutlineInputBorder(),
          ),
          items: groups.map((group) {
            return DropdownMenuItem<String>(
              value: group['id'] as String,
              child: Text(group['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGroupId = value;
            });
          },
          validator: (value) {
            if (_selectedTargetType == 'group' &&
                (value == null || value.isEmpty)) {
              return 'Grup seçimi gerekli';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildRoleSelector() {
    final rolesAsync = ref.watch(rolesProvider);

    return rolesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Hata: $error'),
      data: (roles) {
        if (roles.isEmpty) {
          return const Text('Rol bulunamadı');
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedRoleId,
          decoration: const InputDecoration(
            labelText: 'Rol Seçin',
            border: OutlineInputBorder(),
          ),
          items: roles.map((role) {
            return DropdownMenuItem<String>(
              value: role['id'] as String,
              child: Text(role['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRoleId = value;
            });
          },
          validator: (value) {
            if (_selectedTargetType == 'role' &&
                (value == null || value.isEmpty)) {
              return 'Rol seçimi gerekli';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildMemberSelector() {
    final membersAsync = ref.watch(membersProvider);

    return membersAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Hata: $error'),
      data: (members) {
        if (members.isEmpty) {
          return const Text('Üye bulunamadı');
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedMemberId,
          decoration: const InputDecoration(
            labelText: 'Üye Seçin',
            border: OutlineInputBorder(),
          ),
          items: members.map((member) {
            final name = '${member['first_name']} ${member['last_name']}';
            return DropdownMenuItem<String>(
              value: member['id'] as String,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMemberId = value;
            });
          },
          validator: (value) {
            if (_selectedTargetType == 'member' &&
                (value == null || value.isEmpty)) {
              return 'Üye seçimi gerekli';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildBirthdaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.cake, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doğum Günü Hedefleme',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Doğum günü yaklaşan (7 gün içinde) tüm üyelere bildirim gönderilecek.',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Hedef seçimi kontrolü
    if (_selectedTargetType == 'group' && _selectedGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir grup seçin')));
      return;
    }

    if (_selectedTargetType == 'role' && _selectedRoleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir rol seçin')));
      return;
    }

    if (_selectedTargetType == 'member' && _selectedMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir üye seçin')));
      return;
    }

    // Birthday target doesn't need additional validation

    setState(() {
      _isLoading = true;
    });

    try {
      final notificationData = {
        'title': _titleController.text,
        'body': _bodyController.text.isNotEmpty ? _bodyController.text : null,
      };

      if (widget.notification == null) {
        // Yeni bildirim oluştur
        final notification = await ref
            .read(createNotificationProvider)
            .call(notificationData);

        // Hedefleri ekle - doğru hedefleme mantığı ile
        await _createNotificationTargets(notification.id);

        if (mounted) {
          // Provider'ları invalidate et
          ref.invalidate(notificationsListProvider);
          ref.invalidate(memberNotificationsListProvider);

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildirim başarıyla oluşturuldu')),
          );
        }
      } else {
        // Bildirimi güncelle
        await ref
            .read(updateNotificationProvider)
            .call(widget.notification!.id, notificationData);

        if (mounted) {
          // Provider'ları invalidate et
          ref.invalidate(notificationsListProvider);
          ref.invalidate(memberNotificationsListProvider);

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildirim başarıyla güncellendi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNotificationTargets(String notificationId) async {
    try {
      // Ana hedef
      switch (_selectedTargetType) {
        case 'group':
          if (_selectedGroupId != null) {
            await Supabase.instance.client.rpc(
              'create_notification_targets',
              params: {
                'p_notification_id': notificationId,
                'p_target_type': 'group',
                'p_target_id': _selectedGroupId,
              },
            );
          }
          break;
        case 'role':
          if (_selectedRoleId != null) {
            await Supabase.instance.client.rpc(
              'create_notification_targets',
              params: {
                'p_notification_id': notificationId,
                'p_target_type': 'role',
                'p_target_id': _selectedRoleId,
              },
            );
          }
          break;
        case 'member':
          if (_selectedMemberId != null) {
            await Supabase.instance.client.rpc(
              'create_notification_targets',
              params: {
                'p_notification_id': notificationId,
                'p_target_type': 'member',
                'p_target_id': _selectedMemberId,
              },
            );
          }
          break;
        case 'birthday':
          await Supabase.instance.client.rpc(
            'create_notification_targets',
            params: {
              'p_notification_id': notificationId,
              'p_target_type': 'birthday',
              'p_target_id': null,
            },
          );
          break;
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildTargetPreview() {
    if (_selectedTargetType == 'group' && _selectedGroupId == null) {
      return const SizedBox.shrink();
    }
    if (_selectedTargetType == 'role' && _selectedRoleId == null) {
      return const SizedBox.shrink();
    }
    if (_selectedTargetType == 'member' && _selectedMemberId == null) {
      return const SizedBox.shrink();
    }
    if (_selectedTargetType == 'birthday') {
      return _buildBirthdayPreview();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Hedef Önizleme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPreviewItem(),
        ],
      ),
    );
  }

  Widget _buildPreviewItem() {
    switch (_selectedTargetType) {
      case 'group':
        return FutureBuilder(
          future: _getGroupName(_selectedGroupId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Grup: ${snapshot.data}');
            }
            return const Text('Grup yükleniyor...');
          },
        );
      case 'role':
        return FutureBuilder(
          future: _getRoleName(_selectedRoleId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Rol: ${snapshot.data}');
            }
            return const Text('Rol yükleniyor...');
          },
        );
      case 'member':
        return FutureBuilder(
          future: _getMemberName(_selectedMemberId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Üye: ${snapshot.data}');
            }
            return const Text('Üye yükleniyor...');
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<String> _getGroupName(String groupId) async {
    try {
      final response = await Supabase.instance.client
          .from('groups')
          .select('name')
          .eq('id', groupId)
          .single();
      return response['name'] as String;
    } catch (e) {
      return 'Bilinmeyen Grup';
    }
  }

  Future<String> _getRoleName(String roleId) async {
    try {
      final response = await Supabase.instance.client
          .from('roles')
          .select('name')
          .eq('id', roleId)
          .single();
      return response['name'] as String;
    } catch (e) {
      return 'Bilinmeyen Rol';
    }
  }

  Future<String> _getMemberName(String memberId) async {
    try {
      final response = await Supabase.instance.client
          .from('members')
          .select('first_name, last_name')
          .eq('id', memberId)
          .single();
      return '${response['first_name']} ${response['last_name']}';
    } catch (e) {
      return 'Bilinmeyen Üye';
    }
  }

  Widget _buildBirthdayPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake, color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Doğum Günü Hedefleme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Doğum günü yaklaşan (7 gün içinde) tüm üyelere bildirim gönderilecek.',
            style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
