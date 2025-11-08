import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import 'lesson_detail_header.dart';
import 'lesson_detail_tabs.dart';
import 'lesson_detail_content.dart';

class LessonDetailPopup extends ConsumerStatefulWidget {
  final LessonScheduleWithPackage schedule;

  const LessonDetailPopup({super.key, required this.schedule});

  @override
  ConsumerState<LessonDetailPopup> createState() => _LessonDetailPopupState();
}

class _LessonDetailPopupState extends ConsumerState<LessonDetailPopup>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            // Header
            LessonDetailHeader(
              onClose: () => Navigator.of(context).pop(),
              scheduleId: widget.schedule.id,
            ),

            // Tab Bar
            LessonDetailTabs(tabController: _tabController),

            // Content
            Expanded(
              child: LessonDetailContent(
                schedule: widget.schedule,
                selectedTabIndex: _selectedTabIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
