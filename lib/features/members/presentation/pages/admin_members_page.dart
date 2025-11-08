import 'package:flutter/material.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../members_page.dart';

/// Admin Members Page - Role-based form for admin users
class AdminMembersPage extends StatelessWidget {
  const AdminMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleBasedForm(
      adminForm: const AdminMembersForm(),
      memberForm: const MemberMembersForm(),
    );
  }
}

/// Admin form for managing all members
class AdminMembersForm extends StatefulWidget {
  const AdminMembersForm({super.key});

  @override
  State<AdminMembersForm> createState() => _AdminMembersFormState();
}

class _AdminMembersFormState extends State<AdminMembersForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Üye Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add member functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin filter widget
          AdminFilterWidget(
            filterOptions: CommonFilterOptions.getMemberFilters(),
            onFilterChanged: (filters) {
              // Apply filters to member list
            },
          ),
          // Member list
          Expanded(
            child: const MembersPage(), // Reuse existing members page
          ),
        ],
      ),
    );
  }
}

/// Member form for viewing own data
class MemberMembersForm extends StatelessWidget {
  const MemberMembersForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Profilim'),
      ),
      body: const MembersPage(), // Reuse existing members page
    );
  }
}
