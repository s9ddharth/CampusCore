class FeeModel {
  final int? id;
  final String name;
  final double amount;
  final double paidAmount;
  final double balance;
  final String status;
  final String? dueDate;
  final int? studentId;

  const FeeModel({
    this.id,
    required this.name,
    required this.amount,
    required this.paidAmount,
    required this.balance,
    required this.status,
    this.dueDate,
    this.studentId,
  });

  bool get isPaid => balance <= 0;

  bool get isPending => balance > 0;

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    final amount = _toDouble(
      json['amount'] ?? json['total_amount'],
    );

    final paid = _toDouble(
      json['paid_amount'] ?? json['paidAmount'],
    );

    final rawBalance =
        json['balance'] ??
        json['remaining_amount'] ??
        (amount - paid);

    return FeeModel(
      id: _toInt(json['id']),
      name:
          json['name']?.toString() ??
          json['fee_name']?.toString() ??
          'Fee',
      amount: amount,
      paidAmount: paid,
      balance: _toDouble(rawBalance),
      status: json['status']?.toString() ?? 'PENDING',
      dueDate:
          json['due_date']?.toString() ??
          json['dueDate']?.toString(),
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']),
    );
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