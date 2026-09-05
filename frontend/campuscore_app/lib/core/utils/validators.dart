class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Required
  // ---------------------------------------------------------------------------

  static String? required(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // General text
  // ---------------------------------------------------------------------------

  static String? text(
    String? value, {
    required String fieldName,
    int? minLength,
    int? maxLength,
  }) {
    final requiredError = required(
      value,
      fieldName: fieldName,
    );

    if (requiredError != null) {
      return requiredError;
    }

    final text = value!.trim();

    if (minLength != null &&
        text.length < minLength) {
      return '$fieldName must contain at least '
          '$minLength characters.';
    }

    if (maxLength != null &&
        text.length > maxLength) {
      return '$fieldName must not exceed '
          '$maxLength characters.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Name
  // ---------------------------------------------------------------------------

  static String? name(
    String? value, {
    String fieldName = 'Name',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    if (text.length < 2) {
      return '$fieldName must contain at least 2 characters.';
    }

    if (text.length > 100) {
      return '$fieldName must not exceed 100 characters.';
    }

    final valid = RegExp(
      r"^[A-Za-z][A-Za-z .'-]*$",
    ).hasMatch(text);

    if (!valid) {
      return '$fieldName contains invalid characters.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  static String? email(
    String? value, {
    String fieldName = 'Email',
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$fieldName is required.' : null;
    }

    final text = value.trim();

    final valid = RegExp(
      r'^[A-Za-z0-9.!#$%&?^_`{|}~-]+@'
      r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}'
      r'[A-Za-z0-9])?(?:\.[A-Za-z0-9]'
      r'(?:[A-Za-z0-9-]{0,61}'
      r'[A-Za-z0-9])?)+$',
    ).hasMatch(text);

    if (!valid) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  static String? phone(
    String? value, {
    String fieldName = 'Phone number',
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$fieldName is required.' : null;
    }

    final text = value.trim();

    final normalized = text.replaceAll(
      RegExp(r'[\s()-]'),
      '',
    );

    final valid = RegExp(
      r'^\+?[0-9]{10,15}$',
    ).hasMatch(normalized);

    if (!valid) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  static String? password(
    String? value, {
    int minimumLength = 8,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < minimumLength) {
      return 'Password must contain at least '
          '$minimumLength characters.';
    }

    return null;
  }

  static String? strongPassword(
    String? value, {
    int minimumLength = 8,
  }) {
    final basicError = password(
      value,
      minimumLength: minimumLength,
    );

    if (basicError != null) {
      return basicError;
    }

    final password = value!;

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Roll number
  // ---------------------------------------------------------------------------

  static String? rollNumber(
    String? value, {
    String fieldName = 'Roll number',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    if (text.length > 30) {
      return '$fieldName must not exceed 30 characters.';
    }

    final valid = RegExp(
      r'^[A-Za-z0-9/_-]+$',
    ).hasMatch(text);

    if (!valid) {
      return '$fieldName contains invalid characters.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Employee ID
  // ---------------------------------------------------------------------------

  static String? employeeId(
    String? value, {
    String fieldName = 'Employee ID',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    if (text.length > 30) {
      return '$fieldName must not exceed 30 characters.';
    }

    final valid = RegExp(
      r'^[A-Za-z0-9/_-]+$',
    ).hasMatch(text);

    if (!valid) {
      return '$fieldName contains invalid characters.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Department / subject codes
  // ---------------------------------------------------------------------------

  static String? departmentCode(
    String? value, {
    String fieldName = 'Department code',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    if (text.length > 20) {
      return '$fieldName must not exceed 20 characters.';
    }

    final valid = RegExp(
      r'^[A-Za-z0-9_-]+$',
    ).hasMatch(text);

    if (!valid) {
      return '$fieldName contains invalid characters.';
    }

    return null;
  }

  static String? subjectCode(
    String? value, {
    String fieldName = 'Subject code',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    if (text.length > 30) {
      return '$fieldName must not exceed 30 characters.';
    }

    final valid = RegExp(
      r'^[A-Za-z0-9_-]+$',
    ).hasMatch(text);

    if (!valid) {
      return '$fieldName contains invalid characters.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Numeric
  // ---------------------------------------------------------------------------

  static String? integer(
    String? value, {
    required String fieldName,
    int? minimum,
    int? maximum,
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$fieldName is required.' : null;
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return '$fieldName must be a whole number.';
    }

    if (minimum != null && number < minimum) {
      return '$fieldName must be at least $minimum.';
    }

    if (maximum != null && number > maximum) {
      return '$fieldName must not exceed $maximum.';
    }

    return null;
  }

  static String? decimal(
    String? value, {
    required String fieldName,
    double? minimum,
    double? maximum,
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$fieldName is required.' : null;
    }

    final number = double.tryParse(value.trim());

    if (number == null || number.isNaN || number.isInfinite) {
      return '$fieldName must be a valid number.';
    }

    if (minimum != null && number < minimum) {
      return '$fieldName must be at least $minimum.';
    }

    if (maximum != null && number > maximum) {
      return '$fieldName must not exceed $maximum.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Academic validation
  // ---------------------------------------------------------------------------

  static String? semester(
    String? value, {
    String fieldName = 'Semester',
  }) {
    return integer(
      value,
      fieldName: fieldName,
      minimum: 1,
      maximum: 8,
    );
  }

  static String? academicYear(
    String? value, {
    String fieldName = 'Academic year',
  }) {
    final error = required(
      value,
      fieldName: fieldName,
    );

    if (error != null) {
      return error;
    }

    final text = value!.trim();

    final match = RegExp(
      r'^(\d{4})-(\d{4})$',
    ).firstMatch(text);

    if (match == null) {
      return '$fieldName must use the format YYYY-YYYY.';
    }

    final startYear = int.parse(match.group(1)!);
    final endYear = int.parse(match.group(2)!);

    if (endYear != startYear + 1) {
      return '$fieldName must contain consecutive years.';
    }

    return null;
  }

  static String? marks(
    String? value, {
    required double maximum,
    String fieldName = 'Marks',
    bool isRequired = true,
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      maximum: maximum,
      isRequired: isRequired,
    );
  }

  static String? percentage(
    String? value, {
    String fieldName = 'Percentage',
    bool isRequired = true,
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      maximum: 100,
      isRequired: isRequired,
    );
  }

  static String? gpa(
    String? value, {
    String fieldName = 'GPA',
    bool isRequired = true,
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      maximum: 10,
      isRequired: isRequired,
    );
  }

  static String? cgpa(
    String? value, {
    String fieldName = 'CGPA',
    bool isRequired = true,
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      maximum: 10,
      isRequired: isRequired,
    );
  }

  static String? credits(
    String? value, {
    String fieldName = 'Credits',
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      maximum: 100,
    );
  }

  // ---------------------------------------------------------------------------
  // Fee validation
  // ---------------------------------------------------------------------------

  static String? amount(
    String? value, {
    String fieldName = 'Amount',
    bool isRequired = true,
  }) {
    return decimal(
      value,
      fieldName: fieldName,
      minimum: 0,
      isRequired: isRequired,
    );
  }

  // ---------------------------------------------------------------------------
  // Date
  // ---------------------------------------------------------------------------

  static String? date(
    String? value, {
    String fieldName = 'Date',
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$fieldName is required.' : null;
    }

    final text = value.trim();

    try {
      DateTime.parse(text);
      return null;
    } catch (_) {
      final parts = text.split('/');

      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);

        if (day != null &&
            month != null &&
            year != null &&
            _isValidDate(year, month, day)) {
          return null;
        }
      }

      return 'Enter a valid $fieldName.';
    }
  }

  static bool _isValidDate(
    int year,
    int month,
    int day,
  ) {
    if (month < 1 || month > 12 || day < 1) {
      return false;
    }

    final date = DateTime(
      year,
      month,
      day,
    );

    return date.year == year &&
        date.month == month &&
        date.day == day;
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  static bool isEmail(String? value) {
    return email(
          value,
          isRequired: false,
        ) ==
        null;
  }

  static bool isPhone(String? value) {
    return phone(
          value,
          isRequired: false,
        ) ==
        null;
  }

  static bool isNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    return double.tryParse(value.trim()) != null;
  }
}