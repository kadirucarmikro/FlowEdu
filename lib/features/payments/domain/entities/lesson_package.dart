import 'package:equatable/equatable.dart';

class LessonPackage extends Equatable {
  final String id;
  final String name;
  final int lessonCount;
  final double price; // Paket toplam tutarı
  final bool isActive;
  final DateTime createdAt;

  const LessonPackage({
    required this.id,
    required this.name,
    required this.lessonCount,
    required this.price,
    required this.isActive,
    required this.createdAt,
  });

  /// Ders başına tutarı hesaplar
  double get pricePerLesson {
    if (lessonCount <= 0) return 0.0;
    return price / lessonCount;
  }

  @override
  List<Object?> get props => [id, name, lessonCount, price, isActive, createdAt];
}
