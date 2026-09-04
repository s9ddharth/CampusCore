import 'package:flutter/foundation.dart';

import '../models/marks_model.dart';
import '../services/marks_service.dart';

class MarksProvider extends ChangeNotifier {
  final MarksService _service;

  MarksProvider(this._service);

  List<MarksModel> _marks = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<MarksModel> get marks =>
      List.unmodifiable(_marks);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get error => _error;

  bool get hasData => _marks.isNotEmpty;

  Future<void> loadMarks({
    int? studentId,
    int? assessmentId,
    int? subjectId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marks = await _service.getMarks(
        studentId: studentId,
        assessmentId: assessmentId,
        subjectId: subjectId,
      );
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveBulkMarks({
    required int subjectId,
    required int sectionId,
    required int assessmentId,
    required List<MarkInput> records,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _marks = await _service.markBulk(
        subjectId: subjectId,
        sectionId: sectionId,
        assessmentId: assessmentId,
        records: records,
      );

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateMarks({
    required int markId,
    required double marks,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateMarks(
        markId: markId,
        marks: marks,
      );

      final index = _marks.indexWhere(
        (item) => item.id == markId,
      );

      if (index != -1) {
        final updatedMarks = [
          ..._marks,
        ];

        updatedMarks[index] = updated;
        _marks = updatedMarks;
      }

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  MarksModel? findMark({
    required int studentId,
    required int assessmentId,
  }) {
    try {
      return _marks.firstWhere(
        (mark) =>
            mark.studentId == studentId &&
            mark.assessmentId == assessmentId,
      );
    } catch (_) {
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