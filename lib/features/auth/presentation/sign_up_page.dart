import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
      final redirectUrl = dotenv.env['SUPABASE_REDIRECT_URL'] ?? (kIsWeb ? Uri.base.origin : null);
      final resp = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        emailRedirectTo: redirectUrl,
      );
      final email = resp.user?.email ?? _emailController.text.trim();
      // If a user is immediately available (e.g., email confirmation not required on some setups), ensure member row
      if (resp.user != null) {
        try {
          await Supabase.instance.client
              .rpc('ensure_member_for_current_user', params: {'p_email': email});
        } catch (_) {
          // ignore to not block navigation
        }
      }
      if (mounted) {
        final msg = Uri.encodeComponent('Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.');
        context.go('/verify-email?email=$email&message=$msg');
      }
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
    if (msg.contains('email rate limit')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    }
    if (msg.contains('invalid email')) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }
    return 'Kayıt olunamadı: ${e.message}';
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
                    Text('Yeni hesap oluştur', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-posta')),
                    const SizedBox(height: 12),
                    TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Şifre'), obscureText: true),
                    const SizedBox(height: 12),
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? '...' : 'Kayıt Ol')),
                    TextButton(onPressed: () => context.go('/signin'), child: const Text('Hesabın var mı? Giriş yap')),
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


