import '../entities/screen.dart';
import '../repositories/screens_repository_interface.dart';

class GetScreens {
  final ScreensRepositoryInterface repository;

  GetScreens(this.repository);

  Future<List<Screen>> call() async {
    return await repository.getScreens();
  }
}
