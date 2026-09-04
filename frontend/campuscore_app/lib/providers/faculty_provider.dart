import 'package:flutter/material.dart';
import '../models/faculty_data.dart';
import '../services/faculty_service.dart';

enum FacultyState { initial, loading, loaded, error, submitting, success }

class FacultyProvider extends ChangeNotifier {
  final FacultyService _facultyService;
  
  FacultyProvider(this._facultyService);

  FacultyState _state = FacultyState.initial;
  FacultyState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  FacultyDashboardData? _dashboardData;
  FacultyDashboardData? get dashboardData => _dashboardData;

  Future<void> fetchDashboard() async {
    _state = FacultyState.loading;
    notifyListeners();

    try {
      _dashboardData = await _facultyService.getFacultyDashboard();
      _state = FacultyState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = FacultyState.error;
    }
    notifyListeners();
  }

  Future<bool> submitAttendance({
    required String subjectCode,
    required String section,
    required String date,
    required List<String> presentRollNumbers,
  }) async {
    _state = FacultyState.submitting;
    notifyListeners();

    try {
      await _facultyService.submitAttendance(
        subjectCode: subjectCode,
        section: section,
        date: date,
        presentRollNumbers: presentRollNumbers,
      );
      _state = FacultyState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = FacultyState.error;
      notifyListeners();
      return false;
    }
  }
}