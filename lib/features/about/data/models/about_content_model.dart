import '../../domain/entities/about_content.dart';

class AboutContentModel extends AboutContent {
  const AboutContentModel({
    required super.id,
    required super.slug,
    required super.title,
    required super.type,
    super.contentText,
    super.mediaUrl,
    required super.sortOrder,
    required super.isActive,
    required super.createdAt,
  });

  factory AboutContentModel.fromJson(Map<String, dynamic> json) {
    return AboutContentModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      type: ContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContentType.text,
      ),
      contentText: json['content_text'] as String?,
      mediaUrl: json['media_url'] as String?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'type': type.name,
      'content_text': contentText,
      'media_url': mediaUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'slug': slug,
      'title': title,
      'type': type.name,
      'content_text': contentText,
      'media_url': mediaUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'slug': slug,
      'title': title,
      'type': type.name,
      'content_text': contentText,
      'media_url': mediaUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  factory AboutContentModel.fromEntity(AboutContent entity) {
    return AboutContentModel(
      id: entity.id,
      slug: entity.slug,
      title: entity.title,
      type: entity.type,
      contentText: entity.contentText,
      mediaUrl: entity.mediaUrl,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  AboutContent toEntity() {
    return AboutContent(
      id: id,
      slug: slug,
      title: title,
      type: type,
      contentText: contentText,
      mediaUrl: mediaUrl,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
