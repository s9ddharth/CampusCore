import 'package:flutter/material.dart';

class PaymentHistory extends StatelessWidget {
  final List<PaymentHistoryItem> payments;
  final String title;
  final String currency;
  final bool showStudent;
  final bool showActions;
  final bool isLoading;
  final String emptyMessage;
  final void Function(PaymentHistoryItem payment)? onTap;
  final void Function(PaymentHistoryItem payment)? onView;
  final void Function(PaymentHistoryItem payment)? onDelete;

  const PaymentHistory({
    super.key,
    required this.payments,
    this.title = 'Payment History',
    this.currency = '₹',
    this.showStudent = false,
    this.showActions = false,
    this.isLoading = false,
    this.emptyMessage = 'No payments recorded.',
    this.onTap,
    this.onView,
    this.onDelete,
  });

  String _formatAmount(double amount) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day/$month/$year';
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
        return Colors.green;

      case 'pending':
      case 'partial':
      case 'partially paid':
        return Colors.orange;

      case 'failed':
      case 'overdue':
      case 'cancelled':
      case 'canceled':
        return scheme.error;

      case 'refunded':
        return Colors.blue;

      default:
        return scheme.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
        return Icons.check_circle_outline;

      case 'pending':
      case 'partial':
      case 'partially paid':
        return Icons.schedule_outlined;

      case 'failed':
      case 'overdue':
        return Icons.warning_amber_rounded;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;

      case 'refunded':
        return Icons.currency_exchange;

      default:
        return Icons.info_outline;
    }
  }

  Widget _statusBadge(
    BuildContext context,
    String status,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, status);

    final text =
        status.trim().isEmpty ? 'Unknown' : status.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCell(
    BuildContext context,
    PaymentHistoryItem payment,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          child: Text(
            payment.studentName.isEmpty
                ? '?'
                : payment.studentName[0].toUpperCase(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                payment.studentName.isEmpty
                    ? 'Unknown Student'
                    : payment.studentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (payment.rollNo.isNotEmpty)
                Text(
                  payment.rollNo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    PaymentHistoryItem payment,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          IconButton(
            tooltip: 'View',
            onPressed: isLoading
                ? null
                : () => onView!(payment),
            icon: const Icon(
              Icons.visibility_outlined,
              size: 20,
            ),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete',
            onPressed: isLoading
                ? null
                : () => _confirmDelete(
                      context,
                      payment,
                    ),
            color: theme.colorScheme.error,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PaymentHistoryItem payment,
  ) async {
    if (onDelete == null || isLoading) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Delete Payment?'),
          content: Text(
            'This will remove the payment of '
            '${_formatAmount(payment.amount)} recorded on '
            '${_formatDate(payment.paymentDate)}.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor:
                    theme.colorScheme.onError,
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete!(payment);
    }
  }

  Widget _buildDesktopTable(BuildContext context) {
    final theme = Theme.of(context);

    final columns = <DataColumn>[
      const DataColumn(
        label: Text('Date'),
      ),
      if (showStudent)
        const DataColumn(
          label: Text('Student'),
        ),
      const DataColumn(
        label: Text('Amount'),
      ),
      const DataColumn(
        label: Text('Method'),
      ),
      const DataColumn(
        label: Text('Reference'),
      ),
      const DataColumn(
        label: Text('Status'),
      ),
      if (showActions)
        const DataColumn(
          label: Text('Actions'),
        ),
    ];

    final dataRows = payments.map((payment) {
      return DataRow(
        onSelectChanged: onTap == null || isLoading
            ? null
            : (selected) {
                if (selected == true) {
                  onTap!(payment);
                }
              },
        cells: [
          DataCell(
            Text(
              _formatDate(payment.paymentDate),
            ),
          ),
          if (showStudent)
            DataCell(
              SizedBox(
                width: 220,
                child: _studentCell(
                  context,
                  payment,
                ),
              ),
            ),
          DataCell(
            Text(
              _formatAmount(payment.amount),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataCell(
            Text(
              payment.paymentMethod.isEmpty
                  ? '-'
                  : payment.paymentMethod,
            ),
          ),
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                payment.referenceNumber ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(
            _statusBadge(
              context,
              payment.status,
            ),
          ),
          if (showActions)
            DataCell(
              _buildActions(
                context,
                payment,
              ),
            ),
        ],
      );
    }).toList();

    return DataTable(
      headingRowColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainerHighest,
      ),
      columns: columns,
      rows: dataRows,
      columnSpacing: 26,
      horizontalMargin: 14,
      dataRowMinHeight: 64,
      dataRowMaxHeight: 82,
    );
  }

  Widget _metricBox(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    PaymentHistoryItem payment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: onTap == null || isLoading
            ? null
            : () => onTap!(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showStudent)
                    Expanded(
                      child: _studentCell(
                        context,
                        payment,
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        _formatDate(
                          payment.paymentDate,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                      ),
                    ),
                  _statusBadge(
                    context,
                    payment.status,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _metricBox(
                    context,
                    label: 'Amount',
                    value: _formatAmount(
                      payment.amount,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _metricBox(
                    context,
                    label: 'Date',
                    value: _formatDate(
                      payment.paymentDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _metricBox(
                    context,
                    label: 'Method',
                    value: payment.paymentMethod.isEmpty
                        ? '-'
                        : payment.paymentMethod,
                  ),
                  if (payment.referenceNumber != null) ...[
                    const SizedBox(width: 10),
                    _metricBox(
                      context,
                      label: 'Reference',
                      value: payment.referenceNumber!,
                    ),
                  ],
                ],
              ),
              if (showActions &&
                  (onView != null || onDelete != null)) ...[
                const SizedBox(height: 10),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActions(
                    context,
                    payment,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (payments.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: payments
                        .map(
                          (payment) => _buildMobileCard(
                            context,
                            payment,
                          ),
                        )
                        .toList(),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDesktopTable(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryItem {
  final int id;
  final int? studentId;
  final String studentName;
  final String rollNo;
  final double amount;
  final String paymentMethod;
  final DateTime? paymentDate;
  final String? referenceNumber;
  final String status;
  final String? remarks;

  const PaymentHistoryItem({
    required this.id,
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    required this.amount,
    this.paymentMethod = '',
    this.paymentDate,
    this.referenceNumber,
    this.status = 'Completed',
    this.remarks,
  });
}