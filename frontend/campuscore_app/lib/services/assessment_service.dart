import '../core/network/api_client.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final ApiClient _apiClient;

  AssessmentService(this._apiClient);

  Future<List<AssessmentModel>> getAssessments({
    int? subjectId,
    int? sectionId,
    int? semester,
    String? academicYear,
  }) async {
    final response = await _apiClient.get(
      '/api/assessments',
      queryParameters: {
        if (subjectId != null) 'subject_id': subjectId,
        if (sectionId != null) 'section_id': sectionId,
        if (semester != null) 'semester': semester,
        if (academicYear != null && academicYear.isNotEmpty)
          'academic_year': academicYear,
      },
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => AssessmentModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map(
            (item) => AssessmentModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<AssessmentModel> getAssessment(int assessmentId) async {
    final response = await _apiClient.get(
      '/api/assessments/$assessmentId',
    );

    return AssessmentModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AssessmentModel> createAssessment({
    required int subjectId,
    required int sectionId,
    required String name,
    required String assessmentType,
    required double maxMarks,
    required int semester,
    required String academicYear,
    DateTime? assessmentDate,
  }) async {
    final response = await _apiClient.post(
      '/api/assessments',
      data: {
        'subject_id': subjectId,
        'section_id': sectionId,
        'name': name,
        'assessment_type': assessmentType,
        'max_marks': maxMarks,
        'semester': semester,
        'academic_year': academicYear,
        if (assessmentDate != null)
          'assessment_date':
              assessmentDate.toIso8601String(),
      },
    );

    return AssessmentModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}