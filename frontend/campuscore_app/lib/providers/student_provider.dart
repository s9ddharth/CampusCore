import 'package:flutter/material.dart';
import '../models/student_data.dart';
import '../services/student_service.dart';

enum ProviderState { initial, loading, loaded, error }

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService;
  
  StudentProvider(this._studentService);

  ProviderState _state = ProviderState.initial;
  ProviderState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  StudentDashboardData? _dashboardData;
  StudentDashboardData? get dashboardData => _dashboardData;

  Future<void> fetchDashboard() async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      _dashboardData = await _studentService.getStudentDashboard();
      _state = ProviderState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProviderState.error;
    }
    notifyListeners();
  }
}