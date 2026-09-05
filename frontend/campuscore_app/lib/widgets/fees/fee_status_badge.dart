import 'package:flutter/material.dart';

class FeeStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const FeeStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.trim().toLowerCase();

    switch (normalized) {
      case 'paid':
      case 'completed':
      case 'success':
        return Colors.green;

      case 'partial':
      case 'partially paid':
      case 'pending':
        return Colors.orange;

      case 'overdue':
      case 'failed':
      case 'unpaid':
      case 'due':
        return scheme.error;

      case 'refunded':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
        return scheme.onSurfaceVariant;

      default:
        return scheme.primary;
    }
  }

  IconData _statusIcon() {
    final normalized = status.trim().toLowerCase();

    switch (normalized) {
      case 'paid':
      case 'completed':
      case 'success':
        return Icons.check_circle_outline;

      case 'partial':
      case 'partially paid':
      case 'pending':
        return Icons.schedule_outlined;

      case 'overdue':
      case 'failed':
      case 'unpaid':
      case 'due':
        return Icons.warning_amber_rounded;

      case 'refunded':
        return Icons.currency_exchange;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    final text = status.trim().isEmpty ? 'Unknown' : status.trim();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(),
            size: compact ? 14 : 16,
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
}