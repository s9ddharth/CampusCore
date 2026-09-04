class PaymentModel {
  final int? id;
  final int? studentFeeId;
  final double amount;
  final DateTime? paidOn;
  final String referenceNo;
  final int? recordedBy;
  final String status;

  const PaymentModel({
    this.id,
    this.studentFeeId,
    required this.amount,
    this.paidOn,
    required this.referenceNo,
    this.recordedBy,
    this.status = 'SUCCESS',
  });

  factory PaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentModel(
      id: _toInt(json['id']),
      studentFeeId:
          _toInt(json['student_fee_id']) ??
          _toInt(json['studentFeeId']) ??
          _toInt(json['fee_id']),
      amount: _toDouble(json['amount']),
      paidOn: DateTime.tryParse(
        (
          json['paid_on'] ??
          json['paidOn'] ??
          json['payment_date'] ??
          ''
        ).toString(),
      ),
      referenceNo:
          json['reference_no']?.toString() ??
          json['referenceNo']?.toString() ??
          '',
      recordedBy:
          _toInt(json['recorded_by']) ??
          _toInt(json['recordedBy']),
      status:
          json['status']?.toString() ?? 'SUCCESS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_fee_id': studentFeeId,
      'amount': amount,
      'paid_on': paidOn?.toIso8601String(),
      'reference_no': referenceNo,
      'recorded_by': recordedBy,
      'status': status,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}