import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError('Supabase env missing: SUPABASE_URL / SUPABASE_ANON_KEY');
  }

  // HTTP ayarları ile Supabase client oluştur
  return SupabaseClient(url, anonKey);
});
