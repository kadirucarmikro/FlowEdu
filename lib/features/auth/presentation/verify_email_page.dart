import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, this.email, this.message});

  final String? email;
  final String? message;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _sending = false;
  String? _message;

  Future<void> _resend() async {
    final email = widget.email ?? Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;
    setState(() {
      _sending = true;
      _message = null;
    });
    try {
      final redirectUrl = dotenv.env['SUPABASE_REDIRECT_URL'] ?? (kIsWeb ? Uri.base.origin : null);
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: redirectUrl,
      );
      setState(() => _message = 'Doğrulama e-postası tekrar gönderildi.');
    } on AuthException catch (e) {
      setState(() => _message = 'Gönderilemedi: ${e.message}');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email ?? Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('E-postanı Doğrula')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Hesabınız oluşturuldu', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Lütfen $email adresine gönderilen e-postadaki bağlantıyla hesabınızı doğrulayın.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    if (widget.message != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFFAF1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(widget.message!, textAlign: TextAlign.left)),
                          ],
                        ),
                      ),
                    if (_message != null) ...[
                      const SizedBox(height: 8),
                      Text(_message!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _sending ? null : _resend, child: Text(_sending ? 'Gönderiliyor…' : 'E-postayı Tekrar Gönder')),
                    TextButton(onPressed: () => context.go('/signin'), child: const Text('Giriş sayfasına dön')),
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


