import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../widgets/event_detail_general_info.dart';
import '../widgets/event_detail_datetime.dart';
import '../widgets/event_detail_organizers.dart';
import '../widgets/event_detail_instructors.dart';
import '../widgets/event_detail_questions.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: Text(widget.event.title),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Genel Bilgiler'),
            Tab(icon: Icon(Icons.schedule), text: 'Tarih & Saat'),
            Tab(icon: Icon(Icons.people), text: 'Organizatörler'),
            Tab(icon: Icon(Icons.school), text: 'Eğitmenler'),
            Tab(icon: Icon(Icons.quiz), text: 'Sorular'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EventDetailGeneralInfo(event: widget.event),
          EventDetailDateTime(event: widget.event),
          EventDetailOrganizers(event: widget.event),
          EventDetailInstructors(event: widget.event),
          EventDetailQuestions(event: widget.event),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareEvent,
                icon: const Icon(Icons.share),
                label: const Text('Paylaş'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _joinEvent,
                icon: const Icon(Icons.event_available),
                label: const Text('Katıl'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paylaşım özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _joinEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinliğe Katıl'),
        content: const Text(
          'Bu etkinliğe katılmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Etkinliğe başarıyla katıldınız!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Katıl'),
          ),
        ],
      ),
    );
  }
}
