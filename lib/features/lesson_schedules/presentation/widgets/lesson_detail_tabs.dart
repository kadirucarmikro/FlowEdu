import 'package:flutter/material.dart';

class LessonDetailTabs extends StatelessWidget {
  final TabController tabController;

  const LessonDetailTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: 'Detaylar'),
          Tab(icon: Icon(Icons.assignment), text: 'Ders Durumu'),
        ],
      ),
    );
  }
}
