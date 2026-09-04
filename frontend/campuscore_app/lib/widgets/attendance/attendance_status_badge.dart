import 'package:flutter/material.dart';

class AttendanceStatusBadge extends StatelessWidget {
  final double percentage;
  final double minimumRequiredPercentage;
  final String? status;
  final bool compact;

  const AttendanceStatusBadge({
    super.key,
    required this.percentage,
    this.minimumRequiredPercentage = 75,
    this.status,
    this.compact = false,
  });

  String _statusText() {
    if (status != null && status!.trim().isNotEmpty) {
      return status!;
    }

    if (percentage < minimumRequiredPercentage) {
      return 'Low Attendance';
    }

    if (percentage < minimumRequiredPercentage + 5) {
      return 'Near Threshold';
    }

    return 'Good Attendance';
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (percentage < minimumRequiredPercentage) {
      return scheme.error;
    }

    if (percentage < minimumRequiredPercentage + 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  IconData _statusIcon() {
    if (percentage < minimumRequiredPercentage) {
      return Icons.warning_amber_rounded;
    }

    if (percentage < minimumRequiredPercentage + 5) {
      return Icons.info_outline;
    }

    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(),
            size: compact ? 15 : 17,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            _statusText(),
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