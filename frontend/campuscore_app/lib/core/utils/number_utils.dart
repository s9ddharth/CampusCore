class NumberUtils {
  NumberUtils._();

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  static int? toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty) {
        return null;
      }

      return int.tryParse(text) ?? double.tryParse(text)?.toInt();
    }

    return null;
  }

  static double? toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty) {
        return null;
      }

      return double.tryParse(text);
    }

    return null;
  }

  static num? toNum(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value;
    }

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty) {
        return null;
      }

      return num.tryParse(text);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Safe values
  // ---------------------------------------------------------------------------

  static int intOrZero(dynamic value) {
    return toInt(value) ?? 0;
  }

  static double doubleOrZero(dynamic value) {
    return toDouble(value) ?? 0.0;
  }

  static num numOrZero(dynamic value) {
    return toNum(value) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Rounding
  // ---------------------------------------------------------------------------

  static double roundTo(
    num value,
    int decimalPlaces,
  ) {
    if (decimalPlaces < 0) {
      throw ArgumentError(
        'decimalPlaces cannot be negative.',
      );
    }

    final factor = _powerOfTen(decimalPlaces);

    return (value * factor).round() / factor;
  }

  static double floorTo(
    num value,
    int decimalPlaces,
  ) {
    if (decimalPlaces < 0) {
      throw ArgumentError(
        'decimalPlaces cannot be negative.',
      );
    }

    final factor = _powerOfTen(decimalPlaces);

    return (value * factor).floor() / factor;
  }

  static double ceilTo(
    num value,
    int decimalPlaces,
  ) {
    if (decimalPlaces < 0) {
      throw ArgumentError(
        'decimalPlaces cannot be negative.',
      );
    }

    final factor = _powerOfTen(decimalPlaces);

    return (value * factor).ceil() / factor;
  }

  static int _powerOfTen(int exponent) {
    var result = 1;

    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Range helpers
  // ---------------------------------------------------------------------------

  static bool isBetween(
    num value,
    num minimum,
    num maximum, {
    bool inclusive = true,
  }) {
    if (minimum > maximum) {
      throw ArgumentError(
        'minimum cannot be greater than maximum.',
      );
    }

    if (inclusive) {
      return value >= minimum && value <= maximum;
    }

    return value > minimum && value < maximum;
  }

  static bool isValidPercentage(num value) {
    return value >= 0 && value <= 100;
  }

  static bool isValidGpa(num value) {
    return value >= 0 && value <= 10;
  }

  static bool isValidCgpa(num value) {
    return value >= 0 && value <= 10;
  }

  static bool isValidSemester(int value) {
    return value >= 1 && value <= 8;
  }

  static bool isValidMarks(
    num value,
    num maximum,
  ) {
    return maximum >= 0 &&
        value >= 0 &&
        value <= maximum;
  }

  // ---------------------------------------------------------------------------
  // Percentage
  // ---------------------------------------------------------------------------

  static double percentage(
    num obtained,
    num maximum,
  ) {
    if (maximum == 0) {
      return 0;
    }

    return (obtained / maximum) * 100;
  }

  static double percentageOf(
    num value,
    num total,
  ) {
    if (total == 0) {
      return 0;
    }

    return (value / total) * 100;
  }

  static double fromPercentage(
    num percentage,
    num total,
  ) {
    return (percentage / 100) * total;
  }

  // ---------------------------------------------------------------------------
  // Average
  // ---------------------------------------------------------------------------

  static double average(
    Iterable<num> values,
  ) {
    final list = values.toList();

    if (list.isEmpty) {
      return 0;
    }

    final sum = list.fold<double>(
      0,
      (total, value) => total + value.toDouble(),
    );

    return sum / list.length;
  }

  static double weightedAverage(
    Iterable<num> values,
    Iterable<num> weights,
  ) {
    final valueList = values.toList();
    final weightList = weights.toList();

    if (valueList.isEmpty ||
        weightList.isEmpty ||
        valueList.length != weightList.length) {
      return 0;
    }

    var weightedSum = 0.0;
    var totalWeight = 0.0;

    for (var i = 0; i < valueList.length; i++) {
      final value = valueList[i].toDouble();
      final weight = weightList[i].toDouble();

      weightedSum += value * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) {
      return 0;
    }

    return weightedSum / totalWeight;
  }

  // ---------------------------------------------------------------------------
  // Min / Max
  // ---------------------------------------------------------------------------

  static num? minimum(Iterable<num> values) {
    final list = values.toList();

    if (list.isEmpty) {
      return null;
    }

    var minimum = list.first;

    for (final value in list.skip(1)) {
      if (value < minimum) {
        minimum = value;
      }
    }

    return minimum;
  }

  static num? maximum(Iterable<num> values) {
    final list = values.toList();

    if (list.isEmpty) {
      return null;
    }

    var maximum = list.first;

    for (final value in list.skip(1)) {
      if (value > maximum) {
        maximum = value;
      }
    }

    return maximum;
  }

  // ---------------------------------------------------------------------------
  // Clamping
  // ---------------------------------------------------------------------------

  static num clamp(
    num value,
    num minimum,
    num maximum,
  ) {
    if (minimum > maximum) {
      throw ArgumentError(
        'minimum cannot be greater than maximum.',
      );
    }

    if (value < minimum) {
      return minimum;
    }

    if (value > maximum) {
      return maximum;
    }

    return value;
  }

  static double clampDouble(
    double value,
    double minimum,
    double maximum,
  ) {
    return clamp(
      value,
      minimum,
      maximum,
    ).toDouble();
  }

  static int clampInt(
    int value,
    int minimum,
    int maximum,
  ) {
    return clamp(
      value,
      minimum,
      maximum,
    ).toInt();
  }

  // ---------------------------------------------------------------------------
  // Marks / academic helpers
  // ---------------------------------------------------------------------------

  static double normalizedScore(
    num obtained,
    num maximum,
    num targetScale,
  ) {
    if (maximum <= 0 || targetScale < 0) {
      return 0;
    }

    final score =
        (obtained / maximum) * targetScale;

    return clampDouble(
      score.toDouble(),
      0,
      targetScale.toDouble(),
    );
  }

  static double markPercentage(
    num obtained,
    num maximum,
  ) {
    return percentage(
      obtained,
      maximum,
    );
  }

  static double creditWeightedPoints(
    num credits,
    num gradePoint,
  ) {
    return credits.toDouble() *
        gradePoint.toDouble();
  }

  static double calculateGpa({
    required Iterable<num> credits,
    required Iterable<num> gradePoints,
  }) {
    return weightedAverage(
      gradePoints,
      credits,
    );
  }

  // ---------------------------------------------------------------------------
  // Comparison
  // ---------------------------------------------------------------------------

  static int compareNumbers(
    num first,
    num second,
  ) {
    if (first < second) {
      return -1;
    }

    if (first > second) {
      return 1;
    }

    return 0;
  }

  static bool approximatelyEqual(
    num first,
    num second, {
    double tolerance = 0.000001,
  }) {
    return (first - second).abs() <= tolerance;
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  static String removeTrailingZeros(
    num value, {
    int maxDecimalPlaces = 2,
  }) {
    final fixed =
        value.toDouble().toStringAsFixed(maxDecimalPlaces);

    return fixed
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String decimalString(
    num value, {
    int decimalPlaces = 2,
  }) {
    return value.toDouble().toStringAsFixed(
          decimalPlaces,
        );
  }

  static String percentageString(
    num value, {
    int decimalPlaces = 1,
  }) {
    return '${value.toDouble().toStringAsFixed(decimalPlaces)}%';
  }

  // ---------------------------------------------------------------------------
  // Null-safe collection helpers
  // ---------------------------------------------------------------------------

  static double sum(
    Iterable<num>? values,
  ) {
    if (values == null) {
      return 0;
    }

    return values.fold<double>(
      0,
      (total, value) => total + value.toDouble(),
    );
  }

  static int countValid(
    Iterable<num?>? values,
  ) {
    if (values == null) {
      return 0;
    }

    return values.whereType<num>().length;
  }
}