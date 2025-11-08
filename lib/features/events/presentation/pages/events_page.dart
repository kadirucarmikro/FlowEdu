import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/navigation_drawer.dart' as custom;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/responsive_grid_list.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/services/role_service.dart';
import '../providers/events_providers.dart';
import '../widgets/event_card.dart';
import '../widgets/enhanced_event_form_dialog.dart';
import '../widgets/event_response_dialog.dart';
import '../widgets/event_responses_widget.dart';
import '../widgets/event_question_responses_widget.dart';
import '../widgets/member_events_list.dart';
import '../widgets/member_event_detail_dialog.dart';
import '../../domain/entities/event.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Etkinlikler'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  onPressed: () => _showCreateEventDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Etkinlik',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const custom.NavigationDrawer(currentRoute: AppRoutes.events),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildMemberView(),
      ),
    );
  }

  Widget _buildAdminView() {
    final eventsAsync = ref.watch(eventsProvider);

    return Column(
      children: [
        // Admin filtreleme alanı - en üstte
        AdminFilterWidget(
          filterOptions: CommonFilterOptions.getEventFilters(),
          onFilterChanged: (filters) {
            setState(() {
              _filters = filters;
            });
          },
          initialFilters: _filters,
        ),

        // Liste görünümü
        Expanded(
          child: eventsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(eventsProvider),
            ),
            data: (events) {
              // Filtreleme uygula
              final filteredEvents = _applyFilters(events);

              return RefreshableResponsiveGridList<Event>(
                items: filteredEvents,
                onRefresh: () async => ref.invalidate(eventsProvider),
                itemBuilder: (context, event, index) => EventCard(
                  event: event,
                  onEdit: () => _showEditEventDialog(context, event),
                  onDelete: () => _deleteEvent(context, event.id),
                  onRespond: () => _showEventResponseDialog(context, event),
                  onViewResponses: () =>
                      _showEventResponsesDialog(context, event),
                ),
                aspectRatio: 1.2,
                maxColumns: 3,
                emptyWidget: CenteredEmptyWidget(
                  title: 'Henüz etkinlik bulunmuyor',
                  message: 'İlk etkinliği eklemek için + butonuna tıklayın',
                  icon: Icons.event_outlined,
                  onAction: () => _showCreateEventDialog(context),
                  actionText: 'Yeni Etkinlik Ekle',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    final eventsAsync = ref.watch(eventsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return eventsAsync.when(
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: isMobile ? 2 : 3),
              SizedBox(height: isMobile ? 16 : 20),
              Text(
                'Etkinlikler yükleniyor...',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => CenteredErrorWidget.generalError(
        message: 'Hata: $error',
        onRetry: () => ref.invalidate(eventsProvider),
      ),
      data: (events) {
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(eventsProvider),
          child: MemberEventsList(
            events: events,
            onEventRespond: (event) =>
                _showMemberEventDetailDialog(context, event),
            onViewResponses: null, // Member cannot view responses
          ),
        );
      },
    );
  }

  List<Event> _applyFilters(List<Event> events) {
    if (_filters.isEmpty) return events;

    return events.where((event) {
      // Arama filtresi
      if (_filters.containsKey('search') &&
          _filters['search'] != null &&
          _filters['search'].toString().isNotEmpty) {
        final searchTerm = _filters['search'].toString().toLowerCase();
        if (!event.title.toLowerCase().contains(searchTerm) &&
            !(event.description?.toLowerCase().contains(searchTerm) ?? false)) {
          return false;
        }
      }

      // Etkinlik türü filtresi
      if (_filters.containsKey('type') &&
          _filters['type'] != null &&
          _filters['type'] != 'Tümü') {
        final eventType = event.type.toString().split('.').last;
        final filterType = _filters['type'].toString().toLowerCase();
        if (filterType == 'normal' && eventType != 'normal') return false;
        if (filterType == 'etkileşimli' && eventType != 'interactive') {
          return false;
        }
        if (filterType == 'anket' && eventType != 'poll') return false;
      }

      // Durum filtresi
      if (_filters.containsKey('status') &&
          _filters['status'] != null &&
          _filters['status'] != 'Tümü') {
      }

      // Tarih filtresi
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        if (event.createdAt.day != filterDate.day ||
            event.createdAt.month != filterDate.month ||
            event.createdAt.year != filterDate.year) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showCreateEventDialog(BuildContext context) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => EnhancedEventFormDialog(
          onSave: (eventData) async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(dialogContext);
            try {
              // ref.read(eventsLoadingProvider.notifier).state = true;
              final createEvent = ref.read(createEventProvider);
              final createdEvent = await createEvent.call(
                title: eventData['title'] as String,
                description: eventData['description'] as String?,
                richDescription: eventData['rich_description'] as String?,
                imageUrl: eventData['image_url'] as String?,
                type: EventType.fromString(eventData['type'] as String),
                isMultipleChoice: eventData['is_multiple_choice'] as bool,
                startAt: eventData['start_at'] != null
                    ? DateTime.parse(eventData['start_at'] as String)
                    : null,
                endAt: eventData['end_at'] != null
                    ? DateTime.parse(eventData['end_at'] as String)
                    : null,
                location: eventData['location'] as String?,
                maxParticipants: eventData['max_participants'] != null
                    ? int.tryParse(eventData['max_participants'].toString())
                    : null,
                registrationDeadline: eventData['registration_deadline'] != null
                    ? DateTime.parse(
                        eventData['registration_deadline'] as String,
                      )
                    : null,
                optionTexts: eventData['optionTexts'] as List<String>?,
              );

              // Organizatörleri kaydet
              final organizers = eventData['organizers'] as List<dynamic>?;
              if (organizers != null && organizers.isNotEmpty) {
                final eventsRepository = ref.read(eventsRepositoryProvider);
                for (final organizer in organizers) {
                  await eventsRepository.createEventOrganizer(
                    eventId: createdEvent.id,
                    memberId: organizer['member_id'] as String,
                    role: organizer['role'] as String,
                  );
                }
              }

              // Eğitmenleri kaydet
              final instructors = eventData['instructors'] as List<dynamic>?;
              if (instructors != null && instructors.isNotEmpty) {
                final eventsRepository = ref.read(eventsRepositoryProvider);
                for (final instructor in instructors) {
                  await eventsRepository.createEventInstructor(
                    eventId: createdEvent.id,
                    memberId: instructor['member_id'] as String,
                    role: instructor['role'] as String,
                  );
                }
              }

              // Soruları kaydet
              final questions = eventData['questions'] as List<dynamic>?;
              if (questions != null && questions.isNotEmpty) {
                final eventsRepository = ref.read(eventsRepositoryProvider);
                for (int i = 0; i < questions.length; i++) {
                  final question = questions[i];

                  final createdQuestion = await eventsRepository
                      .createEventQuestion(
                        eventId: createdEvent.id,
                        questionText: question['question_text'] as String,
                        questionType: question['question_type'] as String,
                        isRequired: question['is_required'] as bool,
                        sortOrder: question['sort_order'] as int,
                      );

                  // Soru seçeneklerini kaydet
                  final options = question['options'] as List<dynamic>?;
                  if (options != null && options.isNotEmpty) {
                    for (int j = 0; j < options.length; j++) {
                      final option = options[j];
                      await eventsRepository.createEventQuestionOption(
                        questionId: createdQuestion.id,
                        optionText: option['option_text'] as String,
                        sortOrder: option['sort_order'] as int,
                      );
                    }
                  }
                }
              }

              // Medya dosyalarını kaydet
              final media = eventData['media'] as List<dynamic>?;
              if (media != null && media.isNotEmpty) {
                final eventsRepository = ref.read(eventsRepositoryProvider);
                for (final mediaFile in media) {
                  await eventsRepository.createEventMedia(
                    eventId: createdEvent.id,
                    fileName: mediaFile['file_name'] as String,
                    fileUrl: mediaFile['file_url'] as String,
                    fileType: mediaFile['file_type'] as String,
                    fileSize: mediaFile['file_size'] as int?,
                    uploadedBy: mediaFile['uploaded_by'] as String?,
                  );
                }
              }

              ref.invalidate(eventsProvider);
              if (mounted && navigator.canPop()) {
                // Dialog'u kapat - dialogContext kullan
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Etkinlik oluşturuldu')),
                );
              }
            } catch (e) {
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            } finally {
              // ref.read(eventsLoadingProvider.notifier).state = false;
            }
          },
        ),
      );
    } catch (e) {
      print('Error showing create event dialog: $e');
    }
  }

  void _showEditEventDialog(BuildContext context, dynamic event) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => EnhancedEventFormDialog(
          event: event,
          onSave: (eventData) async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(dialogContext);
            try {
              // ref.read(eventsLoadingProvider.notifier).state = true;
              final updateEvent = ref.read(updateEventProvider);
              await updateEvent.call(
                id: event.id,
                title: eventData['title'] as String,
                description: eventData['description'] as String?,
                richDescription: eventData['rich_description'] as String?,
                imageUrl: eventData['image_url'] as String?,
                type: EventType.fromString(eventData['type'] as String),
                isMultipleChoice: eventData['is_multiple_choice'] as bool,
                startAt: eventData['start_at'] != null
                    ? DateTime.parse(eventData['start_at'] as String)
                    : null,
                endAt: eventData['end_at'] != null
                    ? DateTime.parse(eventData['end_at'] as String)
                    : null,
                location: eventData['location'] as String?,
                maxParticipants: eventData['max_participants'] != null
                    ? int.tryParse(eventData['max_participants'].toString())
                    : null,
                registrationDeadline: eventData['registration_deadline'] != null
                    ? DateTime.parse(
                        eventData['registration_deadline'] as String,
                      )
                    : null,
                optionTexts: eventData['optionTexts'] as List<String>?,
              );

              // Organizatörleri güncelle
              final organizers = eventData['organizers'] as List<dynamic>?;
              if (organizers != null) {
                final eventsRepository = ref.read(eventsRepositoryProvider);

                // Mevcut organizatörleri sil
                await eventsRepository.deleteEventOrganizersByEventId(event.id);

                // Yeni organizatörleri ekle
                for (final organizer in organizers) {
                  await eventsRepository.createEventOrganizer(
                    eventId: event.id,
                    memberId: organizer['member_id'] as String,
                    role: organizer['role'] as String,
                  );
                }
              }

              // Eğitmenleri güncelle
              final instructors = eventData['instructors'] as List<dynamic>?;
              if (instructors != null) {
                final eventsRepository = ref.read(eventsRepositoryProvider);

                // Mevcut eğitmenleri sil
                await eventsRepository.deleteEventInstructorsByEventId(
                  event.id,
                );

                // Yeni eğitmenleri ekle
                for (final instructor in instructors) {
                  await eventsRepository.createEventInstructor(
                    eventId: event.id,
                    memberId: instructor['member_id'] as String,
                    role: instructor['role'] as String,
                  );
                }
              }

              // Soruları güncelle
              final questions = eventData['questions'] as List<dynamic>?;
              if (questions != null) {
                final eventsRepository = ref.read(eventsRepositoryProvider);

                // Mevcut soruları sil
                await eventsRepository.deleteEventQuestionsByEventId(event.id);

                // Yeni soruları ekle
                for (int i = 0; i < questions.length; i++) {
                  final question = questions[i];

                  final createdQuestion = await eventsRepository
                      .createEventQuestion(
                        eventId: event.id,
                        questionText: question['question_text'] as String,
                        questionType: question['question_type'] as String,
                        isRequired: question['is_required'] as bool,
                        sortOrder: question['sort_order'] as int,
                      );

                  // Soru seçeneklerini kaydet
                  final options = question['options'] as List<dynamic>?;
                  if (options != null && options.isNotEmpty) {
                    for (int j = 0; j < options.length; j++) {
                      final option = options[j];
                      await eventsRepository.createEventQuestionOption(
                        questionId: createdQuestion.id,
                        optionText: option['option_text'] as String,
                        sortOrder: option['sort_order'] as int,
                      );
                    }
                  }
                }
              }

              // Medya dosyalarını güncelle
              final media = eventData['media'] as List<dynamic>?;
              if (media != null) {
                final eventsRepository = ref.read(eventsRepositoryProvider);

                // Mevcut medya dosyalarını sil
                await eventsRepository.deleteEventMediaByEventId(event.id);

                // Yeni medya dosyalarını ekle
                for (final mediaFile in media) {
                  await eventsRepository.createEventMedia(
                    eventId: event.id,
                    fileName: mediaFile['file_name'] as String,
                    fileUrl: mediaFile['file_url'] as String,
                    fileType: mediaFile['file_type'] as String,
                    fileSize: mediaFile['file_size'] as int?,
                    uploadedBy: mediaFile['uploaded_by'] as String?,
                  );
                }
              }

              ref.invalidate(eventsProvider);
              if (mounted) {
                // Dialog'u kapat - dialogContext kullan
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Etkinlik güncellendi')),
                );
              }
            } catch (e) {
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            } finally {
              // ref.read(eventsLoadingProvider.notifier).state = false;
            }
          },
        ),
      );
    } catch (e) {
      print('Error showing edit event dialog: $e');
    }
  }

  void _deleteEvent(BuildContext context, String eventId) {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Etkinliği Sil'),
          content: const Text(
            'Bu etkinliği silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                try {
                  // ref.read(eventsLoadingProvider.notifier).state = true;
                  final deleteEvent = ref.read(deleteEventProvider);
                  await deleteEvent.call(eventId);
                  ref.invalidate(eventsProvider);
                  if (mounted) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Etkinlik silindi')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                } finally {
                  // ref.read(eventsLoadingProvider.notifier).state = false;
                }
              },
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing delete event dialog: $e');
    }
  }

  void _showEventResponseDialog(BuildContext context, dynamic event) {
    showDialog(
      context: context,
      builder: (context) => EventResponseDialog(event: event),
    );
  }

  void _showEventResponsesDialog(BuildContext context, dynamic event) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 768 ? 800 : 600,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${event.title} - Yanıtlar',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Eski event responses (poll/interactive için)
                      if (event.type == EventType.poll ||
                          event.type == EventType.interactive) ...[
                        EventResponsesWidget(event: event),
                        const SizedBox(height: 16),
                      ],
                      // Yeni soru yanıtları
                      if (event.questions.isNotEmpty) ...[
                        EventQuestionResponsesWidget(event: event),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
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

  void _showMemberEventDetailDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final eventsAsync = ref.watch(eventsProvider);
          return eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Hata: $error')),
            data: (events) {
              // Güncel event verisini bul
              final updatedEvent = events.firstWhere(
                (e) => e.id == event.id,
                orElse: () => event,
              );
              return MemberEventDetailDialog(event: updatedEvent);
            },
          );
        },
      ),
    );
  }
}
