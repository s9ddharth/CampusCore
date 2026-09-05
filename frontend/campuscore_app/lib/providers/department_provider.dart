import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';

enum ProviderState { initial, loading, loaded, error }

class DepartmentProvider extends ChangeNotifier {
  final DepartmentService _service;
  
  DepartmentProvider(this._service);

  ProviderState _state = ProviderState.initial;
  ProviderState get state => _state;

  List<DepartmentModel> _departments = [];
  List<DepartmentModel> get departments => _departments;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchDepartments() async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      _departments = await _service.getAllDepartments();
      _state = ProviderState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProviderState.error;
    }
    notifyListeners();
  }
}