import '../entities/about_content.dart';
import '../repositories/about_repository.dart';

class GetAboutContentBySlug {
  final AboutRepository repository;

  GetAboutContentBySlug(this.repository);

  Future<AboutContent> call(String slug) async {
    return await repository.getAboutContentBySlug(slug);
  }
}
