import 'package:flutter/foundation.dart';

import '../models/fee_model.dart';
import '../models/payment_model.dart';
import '../services/fee_service.dart';

class FeeProvider extends ChangeNotifier {
  final FeeService _service;

  FeeProvider(this._service);

  List<FeeModel> _fees = [];
  List<FeeModel> _feeStructures = [];

  bool _isLoading = false;
  bool _isSaving = false;

  String? _error;

  List<FeeModel> get fees =>
      List.unmodifiable(_fees);

  List<FeeModel> get feeStructures =>
      List.unmodifiable(_feeStructures);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get error => _error;

  double get totalAmount =>
      _fees.fold(
        0,
        (sum, fee) => sum + fee.amount,
      );

  double get totalPaid =>
      _fees.fold(
        0,
        (sum, fee) => sum + fee.paidAmount,
      );

  double get totalBalance =>
      _fees.fold(
        0,
        (sum, fee) => sum + fee.balance,
      );

  int get paidFeeCount =>
      _fees.where((fee) => fee.isPaid).length;

  int get pendingFeeCount =>
      _fees.where((fee) => fee.isPending).length;

  Future<void> loadStudentFees(
    int studentId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fees =
          await _service.getStudentFees(studentId);
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeeStructures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feeStructures =
          await _service.getFeeStructures();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentModel?> recordPayment({
    required int studentFeeId,
    required double amount,
    required DateTime paidOn,
    required String referenceNo,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final payment =
          await _service.recordPayment(
        studentFeeId: studentFeeId,
        amount: amount,
        paidOn: paidOn,
        referenceNo: referenceNo,
      );

      return payment;
    } catch (e) {
      _error = _cleanError(e);
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  FeeModel? findFee(int feeId) {
    try {
      return _fees.firstWhere(
        (fee) => fee.id == feeId,
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