class DateTimeHelpers {
  /// Tarihi göreceli gruplara ayırır
  static String getRelativeDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));
    final nextWeek = today.add(const Duration(days: 7));
    final nextMonth = DateTime(now.year, now.month + 1, now.day);

    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Bugün';
    } else if (targetDate == tomorrow) {
      return 'Yarın';
    } else if (targetDate == dayAfterTomorrow) {
      return 'Öbür Gün';
    } else if (targetDate.isBefore(nextWeek)) {
      return 'Bu Hafta';
    } else if (targetDate.isBefore(nextMonth)) {
      return 'Gelecek Hafta';
    } else {
      return 'Gelecek Ay';
    }
  }

  /// Haftanın 7 gününü döndürür
  static List<DateTime> getWeekDates(DateTime startDate) {
    final weekStart = _getWeekStart(startDate);
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  /// Haftanın başlangıcını (Pazartesi) döndürür
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// İki zaman aralığının çakışıp çakışmadığını kontrol eder
  static bool isTimeOverlapping(
    String start1,
    String end1,
    String start2,
    String end2,
  ) {
    final start1Time = _parseTime(start1);
    final end1Time = _parseTime(end1);
    final start2Time = _parseTime(start2);
    final end2Time = _parseTime(end2);

    // Çakışma kontrolü: (start1 < end2) && (start2 < end1)
    return start1Time.isBefore(end2Time) && start2Time.isBefore(end1Time);
  }

  /// Saat string'ini DateTime'a çevirir (sadece saat:dakika kısmı)
  static DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2024, 1, 1, hour, minute);
  }

  /// Saat string'ini formatlar (HH:mm)
  static String formatTime(String timeString) {
    return timeString;
  }

  /// Tarihi formatlar (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Tarih ve saati formatlar (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime('${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}')}';
  }

  /// Haftanın gün adını döndürür
  static String getDayName(DateTime date) {
    const dayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return dayNames[date.weekday - 1];
  }

  /// Haftanın gün adını İngilizce döndürür (database için)
  static String getDayNameEnglish(DateTime date) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[date.weekday - 1];
  }

  /// İki tarih arasındaki gün sayısını döndürür
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  /// Belirli bir tarihten sonraki haftanın aynı gününü döndürür
  static DateTime getNextWeekSameDay(DateTime date) {
    return date.add(const Duration(days: 7));
  }

  /// Belirli bir tarihten önceki haftanın aynı gününü döndürür
  static DateTime getPreviousWeekSameDay(DateTime date) {
    return date.subtract(const Duration(days: 7));
  }
}
