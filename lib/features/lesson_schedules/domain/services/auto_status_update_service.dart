import 'dart:async';
import '../repositories/lesson_schedules_repository.dart';

class AutoStatusUpdateService {
  final LessonSchedulesRepository _repository;
  Timer? _timer;

  AutoStatusUpdateService(this._repository);

  /// Otomatik status güncelleme servisini başlat
  void startAutoUpdate() {
    // Her gün saat 00:01'de çalışacak şekilde ayarla
    _scheduleNextUpdate();
  }

  /// Otomatik status güncelleme servisini durdur
  void stopAutoUpdate() {
    _timer?.cancel();
    _timer = null;
  }

  /// Bir sonraki güncelleme zamanını hesapla ve zamanla
  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 1);
    final duration = tomorrow.difference(now);

    _timer = Timer(duration, () {
      _performAutoUpdate();
      _scheduleNextUpdate(); // Bir sonraki gün için tekrar zamanla
    });
  }

  /// Otomatik status güncellemesini gerçekleştir
  Future<void> _performAutoUpdate() async {
    try {
      await _repository.updateAutoStatusForPastLessons();
    } catch (e) {
      // Error handled silently
    }
  }

  /// Manuel olarak otomatik güncelleme çalıştır
  Future<List<String>> runManualUpdate() async {
    final updatedLessons = await _repository.updateAutoStatusForPastLessons();
    return updatedLessons.map((lesson) => lesson.id).toList();
  }

  /// Servis aktif mi kontrol et
  bool get isActive => _timer?.isActive ?? false;
}
