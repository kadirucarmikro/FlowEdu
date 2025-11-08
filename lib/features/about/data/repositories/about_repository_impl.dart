import '../../domain/entities/about_content.dart';
import '../../domain/repositories/about_repository.dart';
import '../data_sources/about_remote_data_source.dart';
import '../models/about_content_model.dart';

class AboutRepositoryImpl implements AboutRepository {
  final AboutRemoteDataSource _remoteDataSource;

  AboutRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AboutContent>> getAboutContents() async {
    final models = await _remoteDataSource.getAboutContents();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AboutContent> getAboutContentById(String id) async {
    final model = await _remoteDataSource.getAboutContentById(id);
    return model.toEntity();
  }

  @override
  Future<AboutContent> getAboutContentBySlug(String slug) async {
    final model = await _remoteDataSource.getAboutContentBySlug(slug);
    return model.toEntity();
  }

  @override
  Future<AboutContent> createAboutContent(AboutContent content) async {
    final model = AboutContentModel.fromEntity(content);
    final createdModel = await _remoteDataSource.createAboutContent(model);
    return createdModel.toEntity();
  }

  @override
  Future<AboutContent> updateAboutContent(AboutContent content) async {
    final model = AboutContentModel.fromEntity(content);
    final updatedModel = await _remoteDataSource.updateAboutContent(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteAboutContent(String id) async {
    await _remoteDataSource.deleteAboutContent(id);
  }
}
