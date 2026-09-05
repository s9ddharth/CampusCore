// Assumes ApiClient handles token storage internally upon login
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiClient.post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _apiClient.post('/api/auth/logout');
  }
}