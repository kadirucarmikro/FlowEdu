import '../entities/about_content.dart';
import '../repositories/about_repository.dart';

class CreateAboutContent {
  final AboutRepository repository;

  CreateAboutContent(this.repository);

  Future<AboutContent> call(AboutContent content) async {
    return await repository.createAboutContent(content);
  }
}
