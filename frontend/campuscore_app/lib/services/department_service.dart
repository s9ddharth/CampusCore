import '../core/network/api_client.dart';
import '../models/department_model.dart';

class DepartmentService {
  final ApiClient _apiClient;

  DepartmentService(this._apiClient);

  Future<List<DepartmentModel>> getAllDepartments() async {
    final response = await _apiClient.get('/api/admin/departments');
    final List<dynamic> data = response.data['departments'] ?? [];
    return data.map((json) => DepartmentModel.fromJson(json)).toList();
  }
}