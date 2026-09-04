import 'dart:typed_data';

import '../core/network/api_client.dart';

class ReportService {
  final ApiClient _apiClient;

  ReportService(this._apiClient);

  Future<Uint8List> downloadStudentResultPdf(
    int studentId, {
    int? semester,
    String? academicYear,
  }) async {
    final response = await _apiClient.download(
      '/api/reports/results/$studentId/pdf',
      queryParameters: {
        if (semester != null) 'semester': semester,
        if (academicYear != null &&
            academicYear.trim().isNotEmpty)
          'academic_year': academicYear,
      },
    );

    return _extractBytes(response.data);
  }

  Future<Uint8List> downloadStudentResultExcel(
    int studentId, {
    int? semester,
    String? academicYear,
  }) async {
    final response = await _apiClient.download(
      '/api/reports/results/$studentId/excel',
      queryParameters: {
        if (semester != null) 'semester': semester,
        if (academicYear != null &&
            academicYear.trim().isNotEmpty)
          'academic_year': academicYear,
      },
    );

    return _extractBytes(response.data);
  }

  Uint8List _extractBytes(dynamic data) {
    if (data is Uint8List) {
      return data;
    }

    if (data is List<int>) {
      return Uint8List.fromList(data);
    }

    throw Exception(
      'Report API returned an unsupported response.',
    );
  }
}