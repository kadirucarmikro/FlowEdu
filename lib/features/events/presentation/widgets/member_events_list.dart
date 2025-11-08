import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import 'member_event_card.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class MemberEventsList extends ConsumerWidget {
  const MemberEventsList({
    super.key,
    required this.events,
    required this.onEventRespond,
    this.onViewResponses,
  });

  final List<Event> events;
  final Function(Event) onEventRespond;
  final Function(Event)? onViewResponses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveGridList<Event>(
      items: events,
      itemBuilder: (context, event, index) => MemberEventCard(
        event: event,
        onRespond: () => onEventRespond(event),
        onViewResponses: onViewResponses != null
            ? () => onViewResponses!(event)
            : null,
      ),
      aspectRatio: 1.2,
      maxColumns: 3,
      emptyWidget: _buildEmptyWidget(),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Henüz etkinlik bulunmuyor',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Size atanmış etkinlikler burada görünecek',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
