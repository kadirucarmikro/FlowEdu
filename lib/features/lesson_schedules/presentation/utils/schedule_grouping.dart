import '../../domain/entities/lesson_schedule_with_package.dart';
import '../../../../core/utils/date_time_helpers.dart';

class ScheduleGrouping {
  /// Dersleri paket ID'ye göre gruplar
  static Map<String, List<LessonScheduleWithPackage>> groupByPackage(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final packageId = schedule.packageId;
      if (!grouped.containsKey(packageId)) {
        grouped[packageId] = [];
      }
      grouped[packageId]!.add(schedule);
    }

    return grouped;
  }

  /// Dersleri tarihe göre gruplar (Bugün, Bu Hafta, vb.)
  static Map<String, List<LessonScheduleWithPackage>> groupByDate(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      // Dersin tarihini hesapla (dayOfWeek'ten)
      final scheduleDate = _getScheduleDate(schedule);
      final dateGroup = DateTimeHelpers.getRelativeDateGroup(scheduleDate);

      if (!grouped.containsKey(dateGroup)) {
        grouped[dateGroup] = [];
      }
      grouped[dateGroup]!.add(schedule);
    }

    // Her grup içindeki dersleri tarih ve saate göre sırala
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final dateA = _getScheduleDate(a);
        final dateB = _getScheduleDate(b);

        if (dateA.isAtSameMomentAs(dateB)) {
          return a.startTime.compareTo(b.startTime);
        }
        return dateA.compareTo(dateB);
      });
    }

    return grouped;
  }

  /// Dersleri güne göre gruplar (takvim için)
  static Map<DateTime, List<LessonScheduleWithPackage>> groupByDay(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<DateTime, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final scheduleDate = _getScheduleDate(schedule);
      final dayKey = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
      );

      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(schedule);
    }

    // Her gün içindeki dersleri saate göre sırala
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  /// Dersleri haftaya göre gruplar
  static Map<DateTime, List<LessonScheduleWithPackage>> groupByWeek(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<DateTime, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final scheduleDate = _getScheduleDate(schedule);
      final weekStart = _getWeekStart(scheduleDate);

      if (!grouped.containsKey(weekStart)) {
        grouped[weekStart] = [];
      }
      grouped[weekStart]!.add(schedule);
    }

    // Her hafta içindeki dersleri tarih ve saate göre sırala
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final dateA = _getScheduleDate(a);
        final dateB = _getScheduleDate(b);

        if (dateA.isAtSameMomentAs(dateB)) {
          return a.startTime.compareTo(b.startTime);
        }
        return dateA.compareTo(dateB);
      });
    }

    return grouped;
  }

  /// Dersleri eğitmene göre gruplar
  static Map<String, List<LessonScheduleWithPackage>> groupByInstructor(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final instructorId = schedule.instructorId ?? 'no_instructor';
      if (!grouped.containsKey(instructorId)) {
        grouped[instructorId] = [];
      }
      grouped[instructorId]!.add(schedule);
    }

    return grouped;
  }

  /// Dersleri odaya göre gruplar
  static Map<String, List<LessonScheduleWithPackage>> groupByRoom(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final Map<String, List<LessonScheduleWithPackage>> grouped = {};

    for (final schedule in schedules) {
      final roomId = schedule.roomId ?? 'no_room';
      if (!grouped.containsKey(roomId)) {
        grouped[roomId] = [];
      }
      grouped[roomId]!.add(schedule);
    }

    return grouped;
  }

  /// Dersleri duruma göre filtreler (geçmiş, bugün, gelecek)
  static Map<String, List<LessonScheduleWithPackage>> groupByStatus(
    List<LessonScheduleWithPackage> schedules,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<String, List<LessonScheduleWithPackage>> grouped = {
      'past': [],
      'today': [],
      'upcoming': [],
    };

    for (final schedule in schedules) {
      final scheduleDate = _getScheduleDate(schedule);
      final scheduleDay = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
      );

      if (scheduleDay.isBefore(today)) {
        grouped['past']!.add(schedule);
      } else if (scheduleDay.isAtSameMomentAs(today)) {
        grouped['today']!.add(schedule);
      } else {
        grouped['upcoming']!.add(schedule);
      }
    }

    return grouped;
  }

  /// Dersin gerçek tarihini hesaplar (dayOfWeek'ten)
  static DateTime _getScheduleDate(LessonScheduleWithPackage schedule) {
    // Bu metod, dayOfWeek bilgisini kullanarak dersin gerçek tarihini hesaplar
    // Şu an için basit bir implementasyon - gelecekte daha gelişmiş olabilir

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Haftanın günlerini İngilizce olarak map'le
    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final targetWeekday = dayMap[schedule.dayOfWeek] ?? 1;
    final currentWeekday = now.weekday;

    // Bu hafta içinde hedef günü bul
    int daysToAdd = targetWeekday - currentWeekday;
    if (daysToAdd < 0) {
      daysToAdd += 7; // Gelecek haftaya geç
    }

    return today.add(Duration(days: daysToAdd));
  }

  /// Haftanın başlangıcını (Pazartesi) döndürür
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Paket bazlı gruplamada paket bilgilerini özetler
  static Map<String, dynamic> getPackageSummary(
    String packageId,
    List<LessonScheduleWithPackage> schedules,
  ) {
    if (schedules.isEmpty) {
      return {
        'packageId': packageId,
        'packageName': 'Bilinmeyen Paket',
        'totalLessons': 0,
        'completedLessons': 0,
        'upcomingLessons': 0,
        'instructors': <String>[],
        'totalAttendees': 0,
        'rooms': <String>[],
      };
    }

    final firstSchedule = schedules.first;
    final packageName = firstSchedule.packageName;

    final instructors = schedules
        .map((s) => s.instructorName)
        .where((name) => name != null && name.isNotEmpty)
        .toSet()
        .toList();

    final rooms = schedules
        .map((s) => s.roomName)
        .where((name) => name != null && name.isNotEmpty)
        .toSet()
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int completedLessons = 0;
    int upcomingLessons = 0;
    int totalAttendees = 0;

    for (final schedule in schedules) {
      final scheduleDate = _getScheduleDate(schedule);
      final scheduleDay = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
      );

      if (scheduleDay.isBefore(today)) {
        completedLessons++;
      } else {
        upcomingLessons++;
      }

      totalAttendees += schedule.attendeeIds.length;
    }

    return {
      'packageId': packageId,
      'packageName': packageName,
      'totalLessons': schedules.length,
      'completedLessons': completedLessons,
      'upcomingLessons': upcomingLessons,
      'instructors': instructors,
      'totalAttendees': totalAttendees,
      'rooms': rooms,
    };
  }
}
