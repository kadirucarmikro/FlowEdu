import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/about_providers.dart' as data;
import '../../domain/use_cases/get_about_contents.dart';
import '../../domain/use_cases/get_about_content_by_slug.dart';
import '../../domain/use_cases/create_about_content.dart';
import '../../domain/use_cases/update_about_content.dart';
import '../../domain/use_cases/delete_about_content.dart';
import '../../domain/entities/about_content.dart';

// Use Cases
final getAboutContentsProvider = Provider<GetAboutContents>((ref) {
  final repository = ref.watch(data.aboutRepositoryProvider);
  return GetAboutContents(repository);
});

final getAboutContentBySlugProvider = Provider<GetAboutContentBySlug>((ref) {
  final repository = ref.watch(data.aboutRepositoryProvider);
  return GetAboutContentBySlug(repository);
});

final createAboutContentProvider = Provider<CreateAboutContent>((ref) {
  final repository = ref.watch(data.aboutRepositoryProvider);
  return CreateAboutContent(repository);
});

final updateAboutContentProvider = Provider<UpdateAboutContent>((ref) {
  final repository = ref.watch(data.aboutRepositoryProvider);
  return UpdateAboutContent(repository);
});

final deleteAboutContentProvider = Provider<DeleteAboutContent>((ref) {
  final repository = ref.watch(data.aboutRepositoryProvider);
  return DeleteAboutContent(repository);
});

// Data Providers
final aboutContentsProvider = FutureProvider<List<AboutContent>>((ref) async {
  final getAboutContents = ref.watch(getAboutContentsProvider);
  return await getAboutContents();
});

final aboutContentBySlugProvider = FutureProvider.family<AboutContent, String>((
  ref,
  slug,
) async {
  final getAboutContentBySlug = ref.watch(getAboutContentBySlugProvider);
  return await getAboutContentBySlug(slug);
});
