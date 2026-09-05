import 'package:flutter/foundation.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  AttendanceProvider(this._service);

  List<AttendanceRecordModel> _records = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<AttendanceRecordModel> get records =>
      List.unmodifiable(_records);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get error => _error;

  int get totalClasses => _records.length;

  int get presentClasses =>
      _records.where((e) => e.isPresent).length;

  int get absentClasses =>
      _records.where((e) => !e.isPresent).length;

  double get percentage {
    if (totalClasses == 0) return 0;

    return (presentClasses / totalClasses) * 100;
  }

  Future<void> loadAttendance({
    int? studentId,
    int? subjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getAttendance(
        studentId: studentId,
        subjectId: subjectId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveBulkAttendance({
    required int subjectId,
    required int sectionId,
    required DateTime date,
    required List<AttendanceRecordInput> records,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final saved = await _service.markBulkAttendance(
        subjectId: subjectId,
        sectionId: sectionId,
        date: date,
        records: records,
      );

      _records = saved;
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance({
    required int studentId,
    required int subjectId,
    required DateTime date,
    required String status,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final record = await _service.markAttendance(
        studentId: studentId,
        subjectId: subjectId,
        date: date,
        status: status,
      );

      _records = [
        ..._records,
        record,
      ];

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAttendance({
    required int attendanceId,
    required String status,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _service.updateAttendance(
        attendanceId: attendanceId,
        status: status,
      );

      final index = _records.indexWhere(
        (record) => record.id == attendanceId,
      );

      if (index != -1) {
        final updatedRecords = [
          ..._records,
        ];

        updatedRecords[index] = updated;

        _records = updatedRecords;
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