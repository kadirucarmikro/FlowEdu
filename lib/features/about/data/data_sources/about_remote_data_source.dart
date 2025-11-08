import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/about_content_model.dart';

abstract class AboutRemoteDataSource {
  Future<List<AboutContentModel>> getAboutContents();
  Future<AboutContentModel> getAboutContentById(String id);
  Future<AboutContentModel> getAboutContentBySlug(String slug);
  Future<AboutContentModel> createAboutContent(AboutContentModel content);
  Future<AboutContentModel> updateAboutContent(AboutContentModel content);
  Future<void> deleteAboutContent(String id);
}

class AboutRemoteDataSourceImpl implements AboutRemoteDataSource {
  final SupabaseClient _supabase;

  AboutRemoteDataSourceImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<AboutContentModel>> getAboutContents() async {
    try {
      final response = await _supabase
          .from('about_contents')
          .select('*')
          .eq('is_active', true)
          .order('sort_order');

      return response
          .map<AboutContentModel>((json) => AboutContentModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to get about contents: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AboutContentModel> getAboutContentById(String id) async {
    try {
      final response = await _supabase
          .from('about_contents')
          .select('*')
          .eq('id', id)
          .single();

      return AboutContentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to get about content: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AboutContentModel> getAboutContentBySlug(String slug) async {
    try {
      final response = await _supabase
          .from('about_contents')
          .select('*')
          .eq('slug', slug)
          .eq('is_active', true)
          .single();

      return AboutContentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to get about content by slug: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AboutContentModel> createAboutContent(
    AboutContentModel content,
  ) async {
    try {
      final response = await _supabase
          .from('about_contents')
          .insert(content.toCreateJson())
          .select()
          .single();

      return AboutContentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to create about content: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AboutContentModel> updateAboutContent(
    AboutContentModel content,
  ) async {
    try {
      final response = await _supabase
          .from('about_contents')
          .update(content.toUpdateJson())
          .eq('id', content.id)
          .select()
          .single();

      return AboutContentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update about content: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAboutContent(String id) async {
    try {
      await _supabase.from('about_contents').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete about content: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
