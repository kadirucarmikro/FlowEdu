import '../entities/about_content.dart';

abstract class AboutRepository {
  Future<List<AboutContent>> getAboutContents();
  Future<AboutContent> getAboutContentById(String id);
  Future<AboutContent> getAboutContentBySlug(String slug);
  Future<AboutContent> createAboutContent(AboutContent content);
  Future<AboutContent> updateAboutContent(AboutContent content);
  Future<void> deleteAboutContent(String id);
}
