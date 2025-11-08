import '../entities/about_content.dart';
import '../repositories/about_repository.dart';

class UpdateAboutContent {
  final AboutRepository repository;

  UpdateAboutContent(this.repository);

  Future<AboutContent> call(AboutContent content) async {
    return await repository.updateAboutContent(content);
  }
}
