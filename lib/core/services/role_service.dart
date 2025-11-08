import 'package:supabase_flutter/supabase_flutter.dart';

/// Role-based access control service
/// Handles Admin/Member role detection and authorization
class RoleService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if current user is Admin or Armin
  static Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'Admin' || role == 'Armin';
    } catch (e) {
      return false;
    }
  }

  /// Check if current user is Member
  static Future<bool> isMember() async {
    try {
      final role = await getUserRole();
      return role == 'Member';
    } catch (e) {
      return false;
    }
  }

  /// Get current user's role
  static Future<String> getUserRole() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'Guest';
      }

      final response = await _supabase
          .from('members')
          .select('roles(name)')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && response['roles'] != null) {
        final roleName = response['roles']['name'] as String;
        return roleName;
      }

      return 'Guest';
    } catch (e) {
      return 'Guest';
    }
  }

  /// Check if user has admin permissions
  static Future<bool> hasAdminPermissions() async {
    return await isAdmin();
  }

  /// Check if user has member permissions
  static Future<bool> hasMemberPermissions() async {
    return await isMember();
  }

  /// Check if user can access a specific screen
  static Future<bool> canAccessScreen(String screenId) async {
    try {
      final isAdminUser = await isAdmin();
      if (isAdminUser) return true;

      final isMemberUser = await isMember();
      if (!isMemberUser) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user can perform CRUD operations
  static Future<bool> canPerformCRUD() async {
    return await isAdmin();
  }

  /// Check if user can only read data
  static Future<bool> canOnlyRead() async {
    return await isMember();
  }

  /// Get role-based form type
  static Future<String> getFormType() async {
    final isAdminUser = await isAdmin();
    return isAdminUser ? 'Admin' : 'Member';
  }

  /// Check if user can access admin features
  static Future<bool> canAccessAdminFeatures() async {
    return await isAdmin();
  }

  /// Check if user can access member features
  static Future<bool> canAccessMemberFeatures() async {
    return await isMember();
  }

  /// Get current user's member ID
  static Future<String?> getCurrentMemberId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('members')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && response['id'] != null) {
        return response['id'] as String;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
