import '../core/network/api_client.dart';
import '../models/fee_model.dart';
import '../models/payment_model.dart';

class FeeService {
  final ApiClient _apiClient;

  FeeService(this._apiClient);

  Future<List<FeeModel>> getStudentFees(
    int studentId,
  ) async {
    final response = await _apiClient.get(
      '/api/fees/student/$studentId',
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => FeeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<FeeModel>> getFeeStructures() async {
    final response = await _apiClient.get(
      '/api/fees/structures',
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => FeeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<PaymentModel> recordPayment({
    required int studentFeeId,
    required double amount,
    required DateTime paidOn,
    required String referenceNo,
  }) async {
    final response = await _apiClient.post(
      '/api/fees/payment',
      data: {
        'student_fee_id': studentFeeId,
        'amount': amount,
        'paid_on': _formatDate(paidOn),
        'reference_no': referenceNo,
      },
    );

    return PaymentModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}