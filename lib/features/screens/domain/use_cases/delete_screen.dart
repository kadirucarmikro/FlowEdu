import '../repositories/screens_repository_interface.dart';

class DeleteScreen {
  final ScreensRepositoryInterface repository;

  DeleteScreen(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Ekran ID boş olamaz');
    }

    await repository.deleteScreen(id);
  }
}
