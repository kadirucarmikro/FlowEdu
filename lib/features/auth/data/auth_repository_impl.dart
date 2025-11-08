import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) async {
    final resp = await _client.auth.signInWithPassword(email: email, password: password);
    final user = resp.user;
    if (user != null) {
      await _ensureDefaultMember(user: user, email: email);
      await _client.rpc('ensure_member_for_current_user', params: {'p_email': email});
    }
    return resp;
  }

  @override
  Future<AuthResponse> signUpWithEmail({required String email, required String password}) {
    return _client.auth
        .signUp(email: email, password: password)
        .then((resp) async {
      final user = resp.user;
      if (user != null) {
        await _ensureDefaultMember(user: user, email: email);
        await _client.rpc('ensure_member_for_current_user', params: {'p_email': email});
      }
      return resp;
    });
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  User? get currentUser => _client.auth.currentUser;

  Future<void> _ensureDefaultMember({required User user, required String email}) async {
    // Fetch Member role id
    final roleRes = await _client
        .from('roles')
        .select('id')
        .eq('name', 'Member')
        .limit(1)
        .maybeSingle();

    final roleId = roleRes != null ? roleRes['id'] as String? : null;

    // Upsert member row keyed by unique(user_id)
    await _client.from('members').upsert({
      'user_id': user.id,
      if (roleId != null) 'role_id': roleId,
      'email': email,
      'first_name': '',
      'last_name': '',
    }, onConflict: 'user_id');
  }
}


