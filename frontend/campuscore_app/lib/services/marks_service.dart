import '../core/network/api_client.dart';
import '../models/marks_model.dart';

class MarksService {
  final ApiClient _apiClient;

  MarksService(this._apiClient);

  Future<List<MarksModel>> getMarks({
    int? studentId,
    int? assessmentId,
    int? subjectId,
  }) async {
    final response = await _apiClient.get(
      '/api/marks',
      queryParameters: {
        if (studentId != null) 'student_id': studentId,
        if (assessmentId != null)
          'assessment_id': assessmentId,
        if (subjectId != null) 'subject_id': subjectId,
      },
    );

    final data = response.data;

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => MarksModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<MarksModel>> markBulk({
    required int subjectId,
    required int sectionId,
    required int assessmentId,
    required List<MarkInput> records,
  }) async {
    final response = await _apiClient.post(
      '/api/marks/bulk',
      data: {
        'subject_id': subjectId,
        'section_id': sectionId,
        'assessment_id': assessmentId,
        'records': records
            .map(
              (record) => {
                'student_id': record.studentId,
                'marks': record.marks,
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
          (item) => MarksModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<MarksModel> updateMarks({
    required int markId,
    required double marks,
  }) async {
    final response = await _apiClient.put(
      '/api/marks/$markId',
      data: {
        'marks': marks,
      },
    );

    return MarksModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}

class MarkInput {
  final int studentId;
  final double marks;

  const MarkInput({
    required this.studentId,
    required this.marks,
  });
}