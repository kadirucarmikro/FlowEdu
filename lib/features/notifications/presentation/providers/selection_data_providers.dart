import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Grup verileri
final groupsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('groups')
      .select('id, name')
      .order('name');

  return (response as List).cast<Map<String, dynamic>>();
});

// Rol verileri
final rolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('roles')
      .select('id, name')
      .order('name');

  return (response as List).cast<Map<String, dynamic>>();
});

// Üye verileri
final membersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('members')
      .select('id, first_name, last_name, email')
      .order('first_name');

  return (response as List).cast<Map<String, dynamic>>();
});
