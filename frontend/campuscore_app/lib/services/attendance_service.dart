import '../core/network/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService(this._apiClient);

  Future<List<AttendanceRecordModel>> getAttendance({
    int? studentId,
    int? subjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiClient.get(
      '/api/attendance',
      queryParameters: {
        if (studentId != null) 'student_id': studentId,
        if (subjectId != null) 'subject_id': subjectId,
        if (startDate != null)
          'start_date': _formatDate(startDate),
        if (endDate != null)
          'end_date': _formatDate(endDate),
      },
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => AttendanceRecordModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<AttendanceRecordModel>> markBulkAttendance({
    required int subjectId,
    required int sectionId,
    required DateTime date,
    required List<AttendanceRecordInput> records,
  }) async {
    final response = await _apiClient.post(
      '/api/attendance/bulk',
      data: {
        'subject_id': subjectId,
        'section_id': sectionId,
        'date': _formatDate(date),
        'records': records
            .map(
              (record) => {
                'student_id': record.studentId,
                'status': record.status,
              },
            )
            .toList(),
      },
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => AttendanceRecordModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<AttendanceRecordModel> markAttendance({
    required int studentId,
    required int subjectId,
    required DateTime date,
    required String status,
  }) async {
    final response = await _apiClient.post(
      '/api/attendance',
      data: {
        'student_id': studentId,
        'subject_id': subjectId,
        'date': _formatDate(date),
        'status': status,
      },
    );

    return AttendanceRecordModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<AttendanceRecordModel> updateAttendance({
    required int attendanceId,
    required String status,
  }) async {
    final response = await _apiClient.put(
      '/api/attendance/$attendanceId',
      data: {
        'status': status,
      },
    );

    return AttendanceRecordModel.fromJson(
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

class AttendanceRecordInput {
  final int studentId;
  final String status;

  const AttendanceRecordInput({
    required this.studentId,
    required this.status,
  });
}