import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_schedule_with_package.dart';
import 'lesson_detail_details_tab.dart';
import 'lesson_detail_status_tab.dart';

class LessonDetailContent extends ConsumerWidget {
  final LessonScheduleWithPackage schedule;
  final int selectedTabIndex;

  const LessonDetailContent({
    super.key,
    required this.schedule,
    required this.selectedTabIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IndexedStack(
      index: selectedTabIndex,
      children: [
        LessonDetailDetailsTab(schedule: schedule),
        LessonDetailStatusTab(schedule: schedule),
      ],
    );
  }
}
