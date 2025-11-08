import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> getNotificationById(String id);
  Future<NotificationModel> createNotification(Map<String, dynamic> data);
  Future<NotificationModel> updateNotification(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteNotification(String id);
  Future<List<NotificationModel>> getMemberNotifications();
  Future<void> createNotificationTargets(
    String notificationId,
    List<Map<String, dynamic>> targets,
  );
  Future<void> markNotificationAsRead(String notificationId);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final SupabaseClient _client;

  NotificationsRemoteDataSourceImpl(this._client);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client
        .from('notifications')
        .select('''
          id,
          title,
          body,
          created_by,
          created_at
        ''')
        .order('created_at', ascending: false);

    final notifications = (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();

    // Her bildirim için hedef bilgilerini yükle
    for (final notification in notifications) {
      await _loadTargetInfo(notification);
    }

    return notifications;
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final response = await _client
        .from('notifications')
        .select('''
          id,
          title,
          body,
          created_by,
          created_at
        ''')
        .eq('id', id)
        .single();

    return NotificationModel.fromJson(response);
  }

  @override
  Future<NotificationModel> createNotification(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.from('notifications').insert(data).select('''
          id,
          title,
          body,
          created_by,
          created_at
        ''').single();

    return NotificationModel.fromJson(response);
  }

  @override
  Future<NotificationModel> updateNotification(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('notifications')
        .update(data)
        .eq('id', id)
        .select('''
          id,
          title,
          body,
          created_by,
          created_at
        ''')
        .single();

    return NotificationModel.fromJson(response);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _client.from('notifications').delete().eq('id', id);
  }

  @override
  Future<List<NotificationModel>> getMemberNotifications() async {
    final response = await _client
        .from('member_notifications')
        .select('''
          id,
          title,
          body,
          created_by,
          created_at,
          target_type,
          target_id,
          is_read,
          has_response
        ''')
        .order('created_at', ascending: false);

    final notifications = (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();

    return notifications;
  }

  @override
  Future<void> createNotificationTargets(
    String notificationId,
    List<Map<String, dynamic>> targets,
  ) async {
    final targetsWithNotificationId = targets
        .map((target) => {...target, 'notification_id': notificationId})
        .toList();

    await _client
        .from('notification_targets')
        .insert(targetsWithNotificationId);
  }

  Future<void> _loadTargetInfo(NotificationModel notification) async {
    try {
      final response = await _client
          .from('notification_targets')
          .select('target_type, target_id')
          .eq('notification_id', notification.id)
          .limit(1);

      if (response.isNotEmpty) {
        final target = response.first;
        final targetType = target['target_type'] as String;
        final targetId = target['target_id'] as String?;

        String? targetName;

        switch (targetType) {
          case 'group':
            if (targetId != null) {
              final groupResponse = await _client
                  .from('groups')
                  .select('name')
                  .eq('id', targetId)
                  .single();
              targetName = groupResponse['name'] as String;
            }
            break;
          case 'role':
            if (targetId != null) {
              final roleResponse = await _client
                  .from('roles')
                  .select('name')
                  .eq('id', targetId)
                  .single();
              targetName = roleResponse['name'] as String;
            }
            break;
          case 'member':
            if (targetId != null) {
              final memberResponse = await _client
                  .from('members')
                  .select('first_name, last_name')
                  .eq('id', targetId)
                  .single();
              targetName =
                  '${memberResponse['first_name']} ${memberResponse['last_name']}';
            }
            break;
          case 'birthday':
            targetName = 'Doğum günü olan üyeler';
            break;
        }

        // NotificationModel'i güncelle
        notification.targetType = targetType;
        notification.targetId = targetId;
        notification.targetName = targetName;
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // Mevcut kullanıcının member ID'sini al
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    // Member ID'sini al
    final memberResponse = await _client
        .from('members')
        .select('id')
        .eq('user_id', currentUser.id)
        .single();

    final memberId = memberResponse['id'] as String;

    // notification_read_status tablosuna kayıt ekle
    await _client.from('notification_read_status').insert({
      'notification_id': notificationId,
      'member_id': memberId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }
}
