import 'package:equatable/equatable.dart';

enum ContentType { text, image, video }

class AboutContent extends Equatable {
  final String id;
  final String slug;
  final String title;
  final ContentType type;
  final String? contentText;
  final String? mediaUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const AboutContent({
    required this.id,
    required this.slug,
    required this.title,
    required this.type,
    this.contentText,
    this.mediaUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    slug,
    title,
    type,
    contentText,
    mediaUrl,
    sortOrder,
    isActive,
    createdAt,
  ];

  AboutContent copyWith({
    String? id,
    String? slug,
    String? title,
    ContentType? type,
    String? contentText,
    String? mediaUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AboutContent(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      type: type ?? this.type,
      contentText: contentText ?? this.contentText,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
