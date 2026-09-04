import '../models/student_data.dart';
import 'api_client.dart';

class StudentService {
  final ApiClient _apiClient;

  StudentService(this._apiClient);

  Future<StudentDashboardData> getStudentDashboard() async {
    final response = await _apiClient.get('/api/student/dashboard');
    return StudentDashboardData.fromJson(response.data);
  }
}