import 'package:flutter/material.dart';
import '../services/role_service.dart';

/// Role-based form widget that renders different forms based on user role
class RoleBasedForm extends StatefulWidget {
  final Widget adminForm;
  final Widget memberForm;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RoleBasedForm({
    super.key,
    required this.adminForm,
    required this.memberForm,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<RoleBasedForm> createState() => _RoleBasedFormState();
}

class _RoleBasedFormState extends State<RoleBasedForm> {
  String? _userRole;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await RoleService.getUserRole();
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorWidget ?? Center(child: Text('Error: $_error'));
    }

    switch (_userRole) {
      case 'Admin':
      case 'Armin':
        return widget.adminForm;
      case 'Member':
        return widget.memberForm;
      default:
        return widget.memberForm; // Default to member form
    }
  }
}

/// Role-based form builder for more complex scenarios
class RoleBasedFormBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, String role) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RoleBasedFormBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return errorWidget ?? Center(child: Text('Error: ${snapshot.error}'));
        }

        final role = snapshot.data ?? 'Member';
        return builder(context, role);
      },
    );
  }
}

/// Admin-only form widget
class AdminOnlyForm extends StatelessWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const AdminOnlyForm({super.key, required this.child, this.fallbackWidget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return fallbackWidget ??
              const Center(
                child: Text('Access denied. Admin privileges required.'),
              );
        }

        return child;
      },
    );
  }
}

/// Member-only form widget
class MemberOnlyForm extends StatelessWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const MemberOnlyForm({super.key, required this.child, this.fallbackWidget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleService.isMember(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return fallbackWidget ??
              const Center(
                child: Text('Access denied. Member privileges required.'),
              );
        }

        return child;
      },
    );
  }
}

/// Role-based access control widget
class RoleBasedAccess extends StatelessWidget {
  final Widget adminChild;
  final Widget memberChild;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RoleBasedAccess({
    super.key,
    required this.adminChild,
    required this.memberChild,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return errorWidget ?? Center(child: Text('Error: ${snapshot.error}'));
        }

        final role = snapshot.data ?? 'Member';

        switch (role) {
          case 'Admin':
          case 'Armin':
            return adminChild;
          case 'Member':
            return memberChild;
          default:
            return memberChild;
        }
      },
    );
  }
}
