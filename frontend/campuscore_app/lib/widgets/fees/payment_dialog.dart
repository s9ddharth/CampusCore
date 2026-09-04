import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentDialog extends StatefulWidget {
  final String studentName;
  final String? studentRollNo;
  final double totalDue;
  final double minimumPayment;
  final String currency;
  final bool isLoading;
  final String submitLabel;
  final Future<void> Function(PaymentDialogData data)? onSubmit;

  const PaymentDialog({
    super.key,
    required this.studentName,
    this.studentRollNo,
    required this.totalDue,
    this.minimumPayment = 0,
    this.currency = '₹',
    this.isLoading = false,
    this.submitLabel = 'Record Payment',
    this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String studentName,
    String? studentRollNo,
    required double totalDue,
    double minimumPayment = 0,
    String currency = '₹',
    bool isLoading = false,
    String submitLabel = 'Record Payment',
    Future<void> Function(PaymentDialogData data)? onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (_) => PaymentDialog(
        studentName: studentName,
        studentRollNo: studentRollNo,
        totalDue: totalDue,
        minimumPayment: minimumPayment,
        currency: currency,
        isLoading: isLoading,
        submitLabel: submitLabel,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _remarksController;

  String _paymentMethod = 'UPI';
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _referenceController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  double? _parseAmount(String value) {
    return double.tryParse(value.trim());
  }

  String _formatAmount(double amount) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  String get currency => widget.currency;

  Future<void> _pickPaymentDate() async {
    if (widget.isLoading) {
      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _paymentDate = selected;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _submit() async {
    if (widget.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = _parseAmount(_amountController.text)!;

    final data = PaymentDialogData(
      amount: amount,
      paymentMethod: _paymentMethod,
      paymentDate: _paymentDate,
      referenceNumber:
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(data);
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.payments_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Record Payment'),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        context,
                        label: 'Student',
                        value: widget.studentName,
                      ),
                      if (widget.studentRollNo != null &&
                          widget.studentRollNo!.trim().isNotEmpty)
                        _summaryRow(
                          context,
                          label: 'Roll No.',
                          value: widget.studentRollNo!,
                        ),
                      _summaryRow(
                        context,
                        label: 'Outstanding Due',
                        value: _formatAmount(widget.totalDue),
                        valueColor: widget.totalDue > 0
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  enabled: !widget.isLoading,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Payment Amount',
                    prefixText: '$currency ',
                    border: const OutlineInputBorder(),
                    helperText: widget.minimumPayment > 0
                        ? 'Minimum payment: '
                            '${_formatAmount(widget.minimumPayment)}'
                        : null,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Payment amount is required';
                    }

                    final amount = _parseAmount(value);

                    if (amount == null) {
                      return 'Enter a valid amount';
                    }

                    if (amount <= 0) {
                      return 'Payment amount must be greater than 0';
                    }

                    if (amount < widget.minimumPayment) {
                      return 'Minimum payment is '
                          '${_formatAmount(widget.minimumPayment)}';
                    }

                    if (widget.totalDue > 0 &&
                        amount > widget.totalDue) {
                      return 'Payment cannot exceed '
                          'the outstanding due';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text('Cash'),
                    ),
                    DropdownMenuItem(
                      value: 'Card',
                      child: Text('Card'),
                    ),
                    DropdownMenuItem(
                      value: 'UPI',
                      child: Text('UPI'),
                    ),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('Bank Transfer'),
                    ),
                    DropdownMenuItem(
                      value: 'Cheque',
                      child: Text('Cheque'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _paymentMethod = value;
                          });
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  enabled: !widget.isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    hintText: 'Transaction / receipt number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: widget.isLoading
                      ? null
                      : _pickPaymentDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                      ),
                    ),
                    child: Text(
                      _formatDate(_paymentDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksController,
                  enabled: !widget.isLoading,
                  maxLines: 3,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    labelText: 'Remarks',
                    hintText: 'Optional notes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: widget.isLoading ? null : _submit,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(
            widget.isLoading
                ? 'Saving...'
                : widget.submitLabel,
          ),
        ),
      ],
    );
  }
}

class PaymentDialogData {
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? remarks;

  const PaymentDialogData({
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.referenceNumber,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date':
          paymentDate.toIso8601String().split('T').first,
      'reference_number': referenceNumber,
      'remarks': remarks,
    };
  }
}