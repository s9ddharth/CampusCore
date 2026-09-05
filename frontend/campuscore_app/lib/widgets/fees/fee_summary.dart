import 'package:flutter/material.dart';

class FeeSummary extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final double? overdueAmount;
  final String currency;
  final String title;
  final bool showProgress;
  final bool compact;
  final VoidCallback? onTap;

  const FeeSummary({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.overdueAmount,
    this.currency = '₹',
    this.title = 'Fee Summary',
    this.showProgress = true,
    this.compact = false,
    this.onTap,
  });

  double get _paymentProgress {
    if (totalAmount <= 0) {
      return 0;
    }

    return (paidAmount / totalAmount).clamp(0, 1).toDouble();
  }

  String _formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(2);
    return '$currency$formatted';
  }

  Color _dueColor(BuildContext context) {
    if (overdueAmount != null && overdueAmount! > 0) {
      return Theme.of(context).colorScheme.error;
    }

    if (dueAmount > 0) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Widget _amountItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(compact ? 10 : 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatAmount(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressSection(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _paymentProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Payment Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: compact ? 8 : 10,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueColor = _dueColor(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 42 : 48,
                    height: compact ? 42 : 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: compact ? 21 : 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 430) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            _amountItem(
                              context,
                              label: 'Total',
                              amount: totalAmount,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            _amountItem(
                              context,
                              label: 'Paid',
                              amount: paidAmount,
                              color: Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _amountItem(
                              context,
                              label: 'Due',
                              amount: dueAmount,
                              color: dueColor,
                            ),
                            if (overdueAmount != null) ...[
                              const SizedBox(width: 10),
                              _amountItem(
                                context,
                                label: 'Overdue',
                                amount: overdueAmount!,
                                color: theme.colorScheme.error,
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _amountItem(
                        context,
                        label: 'Total',
                        amount: totalAmount,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      _amountItem(
                        context,
                        label: 'Paid',
                        amount: paidAmount,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _amountItem(
                        context,
                        label: 'Due',
                        amount: dueAmount,
                        color: dueColor,
                      ),
                      if (overdueAmount != null) ...[
                        const SizedBox(width: 10),
                        _amountItem(
                          context,
                          label: 'Overdue',
                          amount: overdueAmount!,
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (showProgress) ...[
                const SizedBox(height: 18),
                _progressSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}