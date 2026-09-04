import 'result_model.dart';

class SemesterResultModel {
  final int studentId;
  final int semester;
  final String academicYear;
  final List<ResultModel> results;
  final double gpa;
  final double totalCredits;

  const SemesterResultModel({
    required this.studentId,
    required this.semester,
    required this.academicYear,
    required this.results,
    required this.gpa,
    required this.totalCredits,
  });

  factory SemesterResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResults = json['results'];

    return SemesterResultModel(
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      semester: _toInt(json['semester']) ?? 0,
      academicYear:
          json['academic_year']?.toString() ??
          json['academicYear']?.toString() ??
          '',
      results: rawResults is List
          ? rawResults
              .whereType<Map>()
              .map(
                (item) => ResultModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      gpa: _toDouble(json['gpa']),
      totalCredits:
          _toDouble(
            json['total_credits'] ??
                json['totalCredits'],
          ),
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