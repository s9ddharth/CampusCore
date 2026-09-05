class CgpaModel {
  final int studentId;
  final double cgpa;
  final double totalCredits;
  final int completedSubjects;

  const CgpaModel({
    required this.studentId,
    required this.cgpa,
    required this.totalCredits,
    required this.completedSubjects,
  });

  factory CgpaModel.fromJson(Map<String, dynamic> json) {
    return CgpaModel(
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      cgpa: _toDouble(json['cgpa']),
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