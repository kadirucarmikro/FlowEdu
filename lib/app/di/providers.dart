import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final envLoadedProvider = FutureProvider<void>((ref) async {
  await dotenv.load(fileName: '.env');
});

final supabaseProvider = Provider<Supabase>((ref) => Supabase.instance);


