class GradeBandModel {
  final int? id;
  final String grade;
  final double minScore;
  final double maxScore;
  final double gradePoint;

  const GradeBandModel({
    this.id,
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.gradePoint,
  });

  factory GradeBandModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GradeBandModel(
      id: _toInt(json['id']),
      grade: json['grade']?.toString() ?? '',
      minScore:
          _toDouble(
            json['min_score'] ?? json['minScore'],
          ),
      maxScore:
          _toDouble(
            json['max_score'] ?? json['maxScore'],
          ),
      gradePoint:
          _toDouble(
            json['grade_point'] ?? json['gradePoint'],
          ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade': grade,
      'min_score': minScore,
      'max_score': maxScore,
      'grade_point': gradePoint,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}