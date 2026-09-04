class AssessmentService {
  final ApiClient _apiClient;

  AssessmentService(this._apiClient);

  Future<List<dynamic>> getAssessments(String subjectCode) async {
    final response = await _apiClient.get('/api/assessments/$subjectCode');
    return response.data['assessments'] ?? [];
  }
}