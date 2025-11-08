import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Ensure a corresponding member row exists for the current user
      final email = _emailController.text.trim();
      try {
        await Supabase.instance.client
            .rpc('ensure_member_for_current_user', params: {'p_email': email});
      } catch (_) {
        // no-op: do not block navigation on RPC failure
      }
      if (mounted) context.go('/members');
    } on AuthException catch (e) {
      setState(() => _error = _trAuthError(e));
    } catch (e) {
      setState(() => _error = 'Beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _trAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('email not confirmed')) {
      return 'E-posta adresiniz doğrulanmamış. Lütfen gelen kutunuzu kontrol edin.';
    }
    return 'Giriş yapılamadı: ${e.message}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('FlowEdu', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Hesabınıza giriş yapın', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-posta')),
                    const SizedBox(height: 12),
                    TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Şifre'), obscureText: true),
                    const SizedBox(height: 12),
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? '...' : 'Giriş Yap')),
                    TextButton(onPressed: () => context.go('/signup'), child: const Text('Hesabın yok mu? Kayıt ol')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


