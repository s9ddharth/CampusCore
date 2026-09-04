import 'package:flutter/material.dart';

class Formatters {
  Formatters._();

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static String capitalize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final text = value.trim();

    return text[0].toUpperCase() +
        (text.length > 1 ? text.substring(1).toLowerCase() : '');
  }

  static String capitalizeWords(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map(capitalize)
        .join(' ');
  }

  static String titleCase(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return value
        .trim()
        .split(RegExp(r'[\s_-]+'))
        .where((word) => word.isNotEmpty)
        .map(capitalize)
        .join(' ');
  }

  static String snakeToTitle(String? value) {
    return titleCase(value);
  }

  static String camelToTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final spaced = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return titleCase(spaced);
  }

  static String truncate(
    String? value,
    int maxLength, {
    String suffix = '...',
  }) {
    if (value == null) {
      return '';
    }

    final text = value.trim();

    if (text.length <= maxLength) {
      return text;
    }

    if (maxLength <= suffix.length) {
      return suffix.substring(0, maxLength);
    }

    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  // ---------------------------------------------------------------------------
  // Numbers
  // ---------------------------------------------------------------------------

  static String number(
    num? value, {
    int decimalPlaces = 0,
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    return value.toStringAsFixed(decimalPlaces);
  }

  static String decimal(
    num? value, {
    int decimalPlaces = 2,
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    return value.toStringAsFixed(decimalPlaces);
  }

  static String percentage(
    num? value, {
    int decimalPlaces = 1,
    bool includeSymbol = true,
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    final formatted = value.toStringAsFixed(decimalPlaces);

    return includeSymbol ? '$formatted%' : formatted;
  }

  static String currency(
    num? value, {
    String symbol = '₹',
    int decimalPlaces = 2,
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    return '$symbol${value.toStringAsFixed(decimalPlaces)}';
  }

  static String compactNumber(
    num? value, {
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    final number = value.toDouble();

    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    }

    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }

  // ---------------------------------------------------------------------------
  // GPA / CGPA
  // ---------------------------------------------------------------------------

  static String gpa(
    num? value, {
    int decimalPlaces = 2,
    String fallback = '-',
  }) {
    return decimal(
      value,
      decimalPlaces: decimalPlaces,
      fallback: fallback,
    );
  }

  static String cgpa(
    num? value, {
    int decimalPlaces = 2,
    String fallback = '-',
  }) {
    return decimal(
      value,
      decimalPlaces: decimalPlaces,
      fallback: fallback,
    );
  }

  static String gradePoint(
    num? value, {
    int decimalPlaces = 1,
    String fallback = '-',
  }) {
    return decimal(
      value,
      decimalPlaces: decimalPlaces,
      fallback: fallback,
    );
  }

  // ---------------------------------------------------------------------------
  // Marks
  // ---------------------------------------------------------------------------

  static String marks(
    num? obtained,
    num? maximum, {
    int decimalPlaces = 1,
  }) {
    if (obtained == null || maximum == null) {
      return '-';
    }

    return '${decimal(obtained, decimalPlaces: decimalPlaces)} / '
        '${decimal(maximum, decimalPlaces: decimalPlaces)}';
  }

  static String markPercentage(
    num? obtained,
    num? maximum, {
    int decimalPlaces = 1,
  }) {
    if (obtained == null ||
        maximum == null ||
        maximum == 0) {
      return '-';
    }

    return percentage(
      (obtained / maximum) * 100,
      decimalPlaces: decimalPlaces,
    );
  }

  // ---------------------------------------------------------------------------
  // Academic status
  // ---------------------------------------------------------------------------

  static String gradeLabel(String? grade) {
    if (grade == null || grade.trim().isEmpty) {
      return '-';
    }

    switch (grade.trim().toUpperCase()) {
      case 'S':
        return 'S';
      case 'A':
        return 'A';
      case 'B':
        return 'B';
      case 'C':
        return 'C';
      case 'D':
        return 'D';
      case 'E':
        return 'E';
      case 'F':
        return 'F';
      default:
        return grade.trim().toUpperCase();
    }
  }

  static String attendanceStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return '-';
    }

    return titleCase(status);
  }

  static String resultStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return '-';
    }

    return titleCase(status);
  }

  // ---------------------------------------------------------------------------
  // Role
  // ---------------------------------------------------------------------------

  static String role(String? role) {
    if (role == null || role.trim().isEmpty) {
      return '-';
    }

    switch (role.trim().toUpperCase()) {
      case 'ADMIN':
        return 'Administrator';
      case 'FACULTY':
        return 'Faculty';
      case 'STUDENT':
        return 'Student';
      default:
        return titleCase(role);
    }
  }

  // ---------------------------------------------------------------------------
  // IDs / codes
  // ---------------------------------------------------------------------------

  static String rollNumber(String? value) {
    return value?.trim().isNotEmpty == true ? value!.trim() : '-';
  }

  static String subjectCode(String? value) {
    return value?.trim().isNotEmpty == true
        ? value!.trim().toUpperCase()
        : '-';
  }

  static String departmentCode(String? value) {
    return value?.trim().isNotEmpty == true
        ? value!.trim().toUpperCase()
        : '-';
  }

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  static String phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    final cleaned = value.trim();

    if (cleaned.length <= 10) {
      return cleaned;
    }

    if (cleaned.startsWith('+91') &&
        cleaned.length == 13) {
      return '+91 ${cleaned.substring(3, 8)} '
          '${cleaned.substring(8)}';
    }

    return cleaned;
  }

  // ---------------------------------------------------------------------------
  // File sizes
  // ---------------------------------------------------------------------------

  static String fileSize(
    int? bytes, {
    int decimalPlaces = 1,
    String fallback = '-',
  }) {
    if (bytes == null || bytes < 0) {
      return fallback;
    }

    if (bytes < 1024) {
      return '$bytes B';
    }

    final kb = bytes / 1024;

    if (kb < 1024) {
      return '${kb.toStringAsFixed(decimalPlaces)} KB';
    }

    final mb = kb / 1024;

    if (mb < 1024) {
      return '${mb.toStringAsFixed(decimalPlaces)} MB';
    }

    final gb = mb / 1024;

    return '${gb.toStringAsFixed(decimalPlaces)} GB';
  }

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  static String initials(
    String? name, {
    int maxLetters = 2,
  }) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      final word = parts.first;

      return word
          .substring(
            0,
            word.length < maxLetters
                ? word.length
                : maxLetters,
          )
          .toUpperCase();
    }

    return parts
        .take(maxLetters)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }

  static String listCount(
    int? count,
    String singular,
    String plural,
  ) {
    if (count == null) {
      return '0 $plural';
    }

    return '$count ${count == 1 ? singular : plural}';
  }

  static String semester(int? value) {
    if (value == null || value <= 0) {
      return '-';
    }

    return 'Semester $value';
  }

  static String credits(
    num? value, {
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();

    return '$formatted ${value == 1 ? 'Credit' : 'Credits'}';
  }

  // ---------------------------------------------------------------------------
  // Color helpers
  // ---------------------------------------------------------------------------

  static Color statusColor(
    BuildContext context,
    String? status,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status?.trim().toUpperCase();

    switch (normalized) {
      case 'ACTIVE':
      case 'PRESENT':
      case 'PAID':
      case 'COMPLETED':
      case 'PASS':
        return Colors.green;

      case 'INACTIVE':
      case 'ABSENT':
      case 'OVERDUE':
      case 'FAILED':
      case 'F':
        return scheme.error;

      case 'LATE':
      case 'PENDING':
      case 'PARTIAL':
      case 'INCOMPLETE':
        return Colors.orange;

      case 'EXCUSED':
        return Colors.blue;

      default:
        return scheme.onSurfaceVariant;
    }
  }
}