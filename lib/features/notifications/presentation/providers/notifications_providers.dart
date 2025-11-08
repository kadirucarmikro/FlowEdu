import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_sources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/use_cases/get_notifications.dart';
import '../../domain/use_cases/create_notification.dart';
import '../../domain/use_cases/update_notification.dart';
import '../../domain/use_cases/delete_notification.dart';
import '../../domain/use_cases/get_member_notifications.dart';
import '../../domain/use_cases/create_notification_targets.dart';
import '../../domain/use_cases/mark_notification_as_read.dart';

// Data Source Provider
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      return NotificationsRemoteDataSourceImpl(Supabase.instance.client);
    });

// Repository Provider
final notificationsRepositoryProvider = Provider<NotificationsRepositoryImpl>((
  ref,
) {
  final remoteDataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource);
});

// Use Cases Providers
final getNotificationsProvider = Provider<GetNotifications>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetNotifications(repository);
});

final createNotificationProvider = Provider<CreateNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return CreateNotification(repository);
});

final updateNotificationProvider = Provider<UpdateNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return UpdateNotification(repository);
});

final deleteNotificationProvider = Provider<DeleteNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return DeleteNotification(repository);
});

final getMemberNotificationsProvider = Provider<GetMemberNotifications>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetMemberNotifications(repository);
});

final createNotificationTargetsProvider = Provider<CreateNotificationTargets>((
  ref,
) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return CreateNotificationTargets(repository);
});

final markNotificationAsReadProvider = Provider<MarkNotificationAsRead>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return MarkNotificationAsRead(repository);
});

// Data Providers
final notificationsListProvider = FutureProvider((ref) async {
  final getNotifications = ref.watch(getNotificationsProvider);
  return await getNotifications();
});

final memberNotificationsListProvider = FutureProvider((ref) async {
  final getMemberNotifications = ref.watch(getMemberNotificationsProvider);
  return await getMemberNotifications();
});
