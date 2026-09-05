import 'package:flutter/material.dart';

class AttendancePercentage extends StatelessWidget {
  final double percentage;
  final double minimumRequiredPercentage;
  final String? label;
  final bool showValue;
  final bool showThreshold;
  final bool compact;

  const AttendancePercentage({
    super.key,
    required this.percentage,
    this.minimumRequiredPercentage = 75,
    this.label,
    this.showValue = true,
    this.showThreshold = false,
    this.compact = false,
  });

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (percentage < minimumRequiredPercentage) {
      return colorScheme.error;
    }

    if (percentage < minimumRequiredPercentage + 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(context);
    final progress = (percentage.clamp(0, 100) / 100).toDouble();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color,
                ),
              ),
            ),
          ),
          if (showValue) ...[
            const SizedBox(width: 8),
            Text(
              _formatPercentage(percentage),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showValue)
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (showValue)
                Text(
                  _formatPercentage(percentage),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        if (label != null || showValue)
          const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
        if (showThreshold) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatPercentage(
                  minimumRequiredPercentage,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}