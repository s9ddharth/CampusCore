import '../core/network/api_client.dart';
import '../models/cgpa_model.dart';
import '../models/gpa_model.dart';
import '../models/result_model.dart';
import '../models/semester_result_model.dart';

class ResultService {
  final ApiClient _apiClient;

  ResultService(this._apiClient);

  Future<List<ResultModel>> getStudentResults(
    int studentId, {
    int? semester,
    String? academicYear,
  }) async {
    final response = await _apiClient.get(
      '/api/academic/results/student/$studentId',
      queryParameters: {
        if (semester != null) 'semester': semester,
        if (academicYear != null &&
            academicYear.trim().isNotEmpty)
          'academic_year': academicYear,
      },
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => ResultModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map>()
          .map(
            (item) => ResultModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<List<ResultModel>> getSubjectResults(
    int subjectId, {
    int? semester,
    String? academicYear,
    int? sectionId,
  }) async {
    final response = await _apiClient.get(
      '/api/academic/results/subject/$subjectId',
      queryParameters: {
        if (semester != null) 'semester': semester,
        if (academicYear != null &&
            academicYear.trim().isNotEmpty)
          'academic_year': academicYear,
        if (sectionId != null) 'section_id': sectionId,
      },
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => ResultModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<void> calculateSubjectResults({
    required int subjectId,
    required int sectionId,
    required int semester,
    required String academicYear,
  }) async {
    await _apiClient.post(
      '/api/academic/results/calculate',
      data: {
        'subject_id': subjectId,
        'section_id': sectionId,
        'semester': semester,
        'academic_year': academicYear,
      },
    );
  }

  Future<GpaModel> calculateGpa({
    required int studentId,
    required int semester,
    required String academicYear,
  }) async {
    final response = await _apiClient.post(
      '/api/academic/gpa/calculate',
      data: {
        'student_id': studentId,
        'semester': semester,
        'academic_year': academicYear,
      },
    );

    return GpaModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<GpaModel> getGpa(int studentId) async {
    final response = await _apiClient.get(
      '/api/academic/gpa/$studentId',
    );

    return GpaModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<CgpaModel> getCgpa(int studentId) async {
    final response = await _apiClient.get(
      '/api/academic/cgpa/$studentId',
    );

    return CgpaModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<SemesterResultModel> getSemesterResult({
    required int studentId,
    required int semester,
    required String academicYear,
  }) async {
    final response = await _apiClient.get(
      '/api/academic/gpa/$studentId',
      queryParameters: {
        'semester': semester,
        'academic_year': academicYear,
      },
    );

    return SemesterResultModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> calculateAllGpas({
    required int semester,
    required String academicYear,
  }) async {
    await _apiClient.post(
      '/api/academic/gpa/calculate-all',
      data: {
        'semester': semester,
        'academic_year': academicYear,
      },
    );
  }
}