import '../entities/about_content.dart';
import '../repositories/about_repository.dart';

class GetAboutContents {
  final AboutRepository repository;

  GetAboutContents(this.repository);

  Future<List<AboutContent>> call() async {
    return await repository.getAboutContents();
  }
}
