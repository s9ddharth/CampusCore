import 'package:flutter/foundation.dart';

import '../models/assessment_model.dart';
import '../services/assessment_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final AssessmentService _service;

  AssessmentProvider(this._service);

  List<AssessmentModel> _assessments = [];
  bool _isLoading = false;
  String? _error;

  List<AssessmentModel> get assessments =>
      List.unmodifiable(_assessments);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasData => _assessments.isNotEmpty;

  Future<void> loadAssessments({
    int? subjectId,
    int? sectionId,
    int? semester,
    String? academicYear,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assessments = await _service.getAssessments(
        subjectId: subjectId,
        sectionId: sectionId,
        semester: semester,
        academicYear: academicYear,
      );
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssessment({
    required int subjectId,
    required int sectionId,
    required String name,
    required String assessmentType,
    required double maxMarks,
    required int semester,
    required String academicYear,
    DateTime? assessmentDate,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createAssessment(
        subjectId: subjectId,
        sectionId: sectionId,
        name: name,
        assessmentType: assessmentType,
        maxMarks: maxMarks,
        semester: semester,
        academicYear: academicYear,
        assessmentDate: assessmentDate,
      );

      _assessments = [
        ..._assessments,
        created,
      ];

      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<AssessmentModel?> getAssessment(
    int assessmentId,
  ) async {
    try {
      return await _service.getAssessment(assessmentId);
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
          'Exception: ',
          '',
        );
  }
}