import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_sources/events_remote_data_source.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../domain/use_cases/create_event.dart';
import '../../domain/use_cases/delete_event.dart';
import '../../domain/use_cases/get_events.dart';
import '../../domain/use_cases/update_event.dart';
import '../../domain/use_cases/create_event_response.dart';

// Data Sources
final eventsRemoteDataSourceProvider = Provider<EventsRemoteDataSource>((ref) {
  return EventsRemoteDataSource(Supabase.instance.client);
});

// Repositories
final eventsRepositoryProvider = Provider<EventsRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(eventsRemoteDataSourceProvider);
  return EventsRepositoryImpl(remoteDataSource);
});

// Use Cases
final getEventsProvider = Provider<GetEvents>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return GetEvents(repository);
});

final createEventProvider = Provider<CreateEvent>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return CreateEvent(repository);
});

final updateEventProvider = Provider<UpdateEvent>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return UpdateEvent(repository);
});

final deleteEventProvider = Provider<DeleteEvent>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return DeleteEvent(repository);
});

final createEventResponseProvider = Provider<CreateEventResponse>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return CreateEventResponse(repository);
});

// State Providers
final eventsProvider = FutureProvider((ref) async {
  final getEvents = ref.watch(getEventsProvider);
  return await getEvents.call();
});

// Event read status tracking - using NotifierProvider
final eventReadStatusProvider =
    NotifierProvider<EventReadStatusNotifier, Set<String>>(
      () => EventReadStatusNotifier(),
    );

class EventReadStatusNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void markAsRead(String eventId) {
    state = {...state, eventId};
  }

  bool isRead(String eventId) {
    return state.contains(eventId);
  }
}

void markEventAsRead(WidgetRef ref, String eventId) {
  ref.read(eventReadStatusProvider.notifier).markAsRead(eventId);
}

// final eventsLoadingProvider = StateProvider<bool>((ref) => false);
