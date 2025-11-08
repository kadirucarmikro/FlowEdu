import '../repositories/about_repository.dart';

class DeleteAboutContent {
  final AboutRepository repository;

  DeleteAboutContent(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAboutContent(id);
  }
}
