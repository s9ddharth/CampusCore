class GpaModel {
  final int studentId;
  final int semester;
  final String academicYear;
  final double gpa;
  final double totalCredits;
  final int completedSubjects;

  const GpaModel({
    required this.studentId,
    required this.semester,
    required this.academicYear,
    required this.gpa,
    required this.totalCredits,
    required this.completedSubjects,
  });

  factory GpaModel.fromJson(Map<String, dynamic> json) {
    return GpaModel(
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      semester: _toInt(json['semester']) ?? 0,
      academicYear:
          json['academic_year']?.toString() ??
          json['academicYear']?.toString() ??
          '',
      gpa: _toDouble(json['gpa']),
      totalCredits:
          _toDouble(
            json['total_credits'] ??
                json['totalCredits'],
          ),
      completedSubjects:
          _toInt(json['completed_subjects']) ??
          _toInt(json['completedSubjects']) ??
          0,
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