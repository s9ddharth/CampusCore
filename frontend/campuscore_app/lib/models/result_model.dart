class ResultModel {
  final int? id;
  final int studentId;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final double credits;
  final double rawTotal;
  final double normalizedScore;
  final String grade;
  final double gradePoint;
  final bool passed;
  final int semester;
  final String academicYear;
  final String? policyVersion;

  const ResultModel({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.credits,
    required this.rawTotal,
    required this.normalizedScore,
    required this.grade,
    required this.gradePoint,
    required this.passed,
    required this.semester,
    required this.academicYear,
    this.policyVersion,
  });

  factory ResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResultModel(
      id: _toInt(json['id']),
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      subjectId:
          _toInt(json['subject_id']) ??
          _toInt(json['subjectId']) ??
          0,
      subjectCode:
          json['subject_code']?.toString() ??
          json['subjectCode']?.toString() ??
          '',
      subjectName:
          json['subject_name']?.toString() ??
          json['subjectName']?.toString() ??
          '',
      credits: _toDouble(json['credits']),
      rawTotal:
          _toDouble(
            json['raw_total'] ??
                json['rawTotal'],
          ),
      normalizedScore:
          _toDouble(
            json['normalized_score'] ??
                json['normalizedScore'],
          ),
      grade: json['grade']?.toString() ?? '',
      gradePoint:
          _toDouble(
            json['grade_point'] ??
                json['gradePoint'],
          ),
      passed: json['passed'] ?? false,
      semester: _toInt(json['semester']) ?? 0,
      academicYear:
          json['academic_year']?.toString() ??
          json['academicYear']?.toString() ??
          '',
      policyVersion:
          json['policy_version']?.toString() ??
          json['policyVersion']?.toString(),
    );
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