import '../core/network/api_client.dart';
import '../models/grade_policy_model.dart';

class GradingService {
  final ApiClient _apiClient;

  GradingService(this._apiClient);

  Future<List<GradePolicyModel>> getPolicies() async {
    final response = await _apiClient.get(
      '/api/grade-policies',
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => GradePolicyModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<GradePolicyModel> getActivePolicy() async {
    final response = await _apiClient.get(
      '/api/grade-policies/active',
    );

    return GradePolicyModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<GradePolicyModel> getPolicy(
    int policyId,
  ) async {
    final response = await _apiClient.get(
      '/api/grade-policies/$policyId',
    );

    return GradePolicyModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<GradePolicyModel> createPolicy(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      '/api/grade-policies',
      data: payload,
    );

    return GradePolicyModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<GradePolicyModel> activatePolicy(
    int policyId,
  ) async {
    final response = await _apiClient.post(
      '/api/grade-policies/$policyId/activate',
    );

    return GradePolicyModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}