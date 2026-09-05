class DateUtils {
  DateUtils._();

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  static String formatDate(
    DateTime? date, {
    String fallback = '-',
  }) {
    if (date == null) {
      return fallback;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  static String formatDateLong(
    DateTime? date, {
    String fallback = '-',
  }) {
    if (date == null) {
      return fallback;
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDateShort(
    DateTime? date, {
    String fallback = '-',
  }) {
    if (date == null) {
      return fallback;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDateTime(
    DateTime? dateTime, {
    String fallback = '-',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    final date = formatDate(dateTime);
    final time = formatTime(dateTime);

    return '$date, $time';
  }

  static String formatTime(
    DateTime? time, {
    String fallback = '-',
  }) {
    if (time == null) {
      return fallback;
    }

    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  static DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final input = value.trim();

    try {
      return DateTime.parse(input);
    } catch (_) {
      return _parseCommonDateFormat(input);
    }
  }

  static DateTime? _parseCommonDateFormat(String value) {
    final slashParts = value.split('/');

    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);

      if (day != null && month != null && year != null) {
        return _safeDateTime(year, month, day);
      }
    }

    final dashParts = value.split('-');

    if (dashParts.length == 3) {
      final first = int.tryParse(dashParts[0]);
      final second = int.tryParse(dashParts[1]);
      final third = int.tryParse(dashParts[2]);

      if (first == null || second == null || third == null) {
        return null;
      }

      if (dashParts[0].length == 4) {
        return _safeDateTime(first, second, third);
      }

      return _safeDateTime(third, second, first);
    }

    return null;
  }

  static DateTime? _safeDateTime(
    int year,
    int month,
    int day,
  ) {
    try {
      final date = DateTime(year, month, day);

      if (date.year != year ||
          date.month != month ||
          date.day != day) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Academic year
  // ---------------------------------------------------------------------------

  static String getCurrentAcademicYear() {
    final now = DateTime.now();

    final startYear =
        now.month >= 7 ? now.year : now.year - 1;

    return '$startYear-${startYear + 1}';
  }

  static String getAcademicYearForDate(DateTime date) {
    final startYear =
        date.month >= 7 ? date.year : date.year - 1;

    return '$startYear-${startYear + 1}';
  }

  static String academicYearFromStartYear(int startYear) {
    return '$startYear-${startYear + 1}';
  }

  static bool isValidAcademicYear(String? academicYear) {
    if (academicYear == null) {
      return false;
    }

    final value = academicYear.trim();

    final match = RegExp(
      r'^(\d{4})-(\d{4})$',
    ).firstMatch(value);

    if (match == null) {
      return false;
    }

    final startYear = int.parse(match.group(1)!);
    final endYear = int.parse(match.group(2)!);

    return endYear == startYear + 1;
  }

  // ---------------------------------------------------------------------------
  // Relative dates
  // ---------------------------------------------------------------------------

  static bool isToday(DateTime? date) {
    if (date == null) {
      return false;
    }

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime? date) {
    if (date == null) {
      return false;
    }

    final yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );

    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isTomorrow(DateTime? date) {
    if (date == null) {
      return false;
    }

    final tomorrow = DateTime.now().add(
      const Duration(days: 1),
    );

    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isPast(DateTime? date) {
    if (date == null) {
      return false;
    }

    return date.isBefore(DateTime.now());
  }

  static bool isFuture(DateTime? date) {
    if (date == null) {
      return false;
    }

    return date.isAfter(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // Day boundaries
  // ---------------------------------------------------------------------------

  static DateTime startOfDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    );
  }

  // ---------------------------------------------------------------------------
  // Month boundaries
  // ---------------------------------------------------------------------------

  static DateTime startOfMonth(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      1,
    );
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(
      date.year,
      date.month + 1,
      0,
      23,
      59,
      59,
      999,
    );
  }

  // ---------------------------------------------------------------------------
  // Comparison
  // ---------------------------------------------------------------------------

  static bool isSameDay(
    DateTime? first,
    DateTime? second,
  ) {
    if (first == null || second == null) {
      return false;
    }

    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static int daysBetween(
    DateTime first,
    DateTime second,
  ) {
    final firstDay = startOfDay(first);
    final secondDay = startOfDay(second);

    return secondDay.difference(firstDay).inDays;
  }

  static int ageInYears(DateTime? birthDate) {
    if (birthDate == null) {
      return 0;
    }

    final today = DateTime.now();

    var age = today.year - birthDate.year;

    final birthdayPassed =
        today.month > birthDate.month ||
        (today.month == birthDate.month &&
            today.day >= birthDate.day);

    if (!birthdayPassed) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  // ---------------------------------------------------------------------------
  // API helpers
  // ---------------------------------------------------------------------------

  static String toApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String toApiDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}