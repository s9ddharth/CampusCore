import 'package:flutter/foundation.dart';

import '../models/result_model.dart';
import '../services/result_service.dart';

class ResultProvider extends ChangeNotifier {
  final ResultService _service;

  ResultProvider(this._service);

  List<ResultModel> _results = [];

  bool _isLoading = false;
  bool _isCalculating = false;
  String? _error;

  List<ResultModel> get results =>
      List.unmodifiable(_results);

  bool get isLoading => _isLoading;

  bool get isCalculating => _isCalculating;

  String? get error => _error;

  bool get hasData => _results.isNotEmpty;

  int get passedCount =>
      _results.where((result) => result.passed).length;

  int get failedCount =>
      _results.where((result) => !result.passed).length;

  Future<void> loadStudentResults(
    int studentId, {
    int? semester,
    String? academicYear,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _service.getStudentResults(
        studentId,
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

  Future<void> loadSubjectResults(
    int subjectId, {
    int? semester,
    String? academicYear,
    int? sectionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _service.getSubjectResults(
        subjectId,
        semester: semester,
        academicYear: academicYear,
        sectionId: sectionId,
      );
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> calculateResults({
    required int subjectId,
    required int sectionId,
    required int semester,
    required String academicYear,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      await _service.calculateSubjectResults(
        subjectId: subjectId,
        sectionId: sectionId,
        semester: semester,
        academicYear: academicYear,
      );

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<bool> recalculateAndReload({
    required int subjectId,
    required int sectionId,
    required int semester,
    required String academicYear,
  }) async {
    final success = await calculateResults(
      subjectId: subjectId,
      sectionId: sectionId,
      semester: semester,
      academicYear: academicYear,
    );

    if (!success) return false;

    await loadSubjectResults(
      subjectId,
      semester: semester,
      academicYear: academicYear,
      sectionId: sectionId,
    );

    return _error == null;
  }

  void clear() {
    _results = [];
    _error = null;
    notifyListeners();
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