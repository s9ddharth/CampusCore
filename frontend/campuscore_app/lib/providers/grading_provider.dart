import 'package:flutter/foundation.dart';

import '../models/grade_policy_model.dart';
import '../services/grading_service.dart';

class GradingProvider extends ChangeNotifier {
  final GradingService _service;

  GradingProvider(this._service);

  List<GradePolicyModel> _policies = [];
  GradePolicyModel? _activePolicy;
  GradePolicyModel? _selectedPolicy;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<GradePolicyModel> get policies =>
      List.unmodifiable(_policies);

  GradePolicyModel? get activePolicy =>
      _activePolicy;

  GradePolicyModel? get selectedPolicy =>
      _selectedPolicy;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get error => _error;

  Future<void> loadPolicies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _policies = await _service.getPolicies();

      _activePolicy =
          _findActivePolicy(_policies);

      _selectedPolicy ??= _activePolicy;
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActivePolicy() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activePolicy =
          await _service.getActivePolicy();

      _selectedPolicy = _activePolicy;
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPolicy(int policyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPolicy =
          await _service.getPolicy(policyId);
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPolicy(
    Map<String, dynamic> payload,
  ) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final policy =
          await _service.createPolicy(payload);

      _policies = [
        ..._policies,
        policy,
      ];

      if (policy.isActive) {
        _activePolicy = policy;
        _selectedPolicy = policy;
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

  Future<bool> activatePolicy(int policyId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final policy =
          await _service.activatePolicy(policyId);

      _activePolicy = policy;
      _selectedPolicy = policy;

      _policies = _policies.map((item) {
        if (item.id == policy.id) {
          return policy;
        }

        return GradePolicyModel(
          id: item.id,
          name: item.name,
          version: item.version,
          rawScale: item.rawScale,
          qualifyingThreshold:
              item.qualifyingThreshold,
          teePassMark: item.teePassMark,
          topSCount: item.topSCount,
          isActive: false,
          bands: item.bands,
        );
      }).toList();

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void selectPolicy(GradePolicyModel policy) {
    _selectedPolicy = policy;
    notifyListeners();
  }

  GradePolicyModel? _findActivePolicy(
    List<GradePolicyModel> policies,
  ) {
    try {
      return policies.firstWhere(
        (policy) => policy.isActive,
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