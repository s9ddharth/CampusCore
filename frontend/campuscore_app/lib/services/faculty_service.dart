import '../models/faculty_data.dart';
// import 'api_client.dart';

class FacultyService {
  final ApiClient _apiClient;

  FacultyService(this._apiClient);

  Future<FacultyDashboardData> getFacultyDashboard() async {
    final response = await _apiClient.get('/api/faculty/dashboard');
    return FacultyDashboardData.fromJson(response.data);
  }

  Future<void> submitAttendance({
    required String subjectCode,
    required String section,
    required String date,
    required List<String> presentRollNumbers,
  }) async {
    await _apiClient.post('/api/faculty/attendance', data: {
      'subjectCode': subjectCode,
      'section': section,
      'date': date,
      'presentRollNumbers': presentRollNumbers,
    });
  }
}