import 'package:flutter/material.dart';

class LowAttendanceAlert extends StatelessWidget {
  final double percentage;
  final double minimumRequiredPercentage;
  final String? studentName;
  final String? subjectName;
  final String? message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool compact;

  const LowAttendanceAlert({
    super.key,
    required this.percentage,
    this.minimumRequiredPercentage = 75,
    this.studentName,
    this.subjectName,
    this.message,
    this.onTap,
    this.onDismiss,
    this.compact = false,
  });

  String _defaultMessage() {
    if (studentName != null && subjectName != null) {
      return '$studentName has attendance of '
          '${percentage.toStringAsFixed(1)}% in $subjectName, '
          'which is below the required '
          '${minimumRequiredPercentage.toStringAsFixed(1)}%.';
    }

    if (subjectName != null) {
      return 'Attendance in $subjectName is '
          '${percentage.toStringAsFixed(1)}%, below the required '
          '${minimumRequiredPercentage.toStringAsFixed(1)}%.';
    }

    return 'Attendance is ${percentage.toStringAsFixed(1)}%, '
        'below the required '
        '${minimumRequiredPercentage.toStringAsFixed(1)}%.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 36 : 42,
                height: compact ? 36 : 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: compact ? 20 : 23,
                  color: color,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Low Attendance',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message ?? _defaultMessage(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tap to view attendance details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Dismiss',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  color: theme.colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}