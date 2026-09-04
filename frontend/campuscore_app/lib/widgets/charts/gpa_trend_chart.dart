import 'package:flutter/material.dart';

class GpaTrendChart extends StatelessWidget {
  final List<GpaTrendPoint> points;
  final String title;
  final String? subtitle;
  final double maxGpa;
  final double height;
  final bool showValues;
  final bool showGrid;
  final bool showTrendLine;
  final bool compact;

  const GpaTrendChart({
    super.key,
    required this.points,
    this.title = 'GPA Trend',
    this.subtitle,
    this.maxGpa = 10,
    this.height = 280,
    this.showValues = true,
    this.showGrid = true,
    this.showTrendLine = true,
    this.compact = false,
  });

  String _formatGpa(double value) {
    return value.toStringAsFixed(2);
  }

  Widget _gridLine(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 38),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No GPA data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _point(
    BuildContext context,
    GpaTrendPoint point,
    double chartHeight,
  ) {
    final theme = Theme.of(context);
    final ratio = maxGpa <= 0
        ? 0.0
        : (point.gpa / maxGpa).clamp(0, 1).toDouble();

    final valueHeight =
        (chartHeight * ratio).clamp(2, chartHeight).toDouble();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showValues)
              Text(
                _formatGpa(point.gpa),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (showValues) const SizedBox(height: 5),
            SizedBox(
              height: chartHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: compact ? 22 : 30,
                  height: valueHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              point.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChart(BuildContext context) {
    const topPadding = 24.0;
    const bottomPadding = 48.0;

    final chartHeight =
        height - topPadding - bottomPadding;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              top: topPadding,
              bottom: bottomPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _gridLine(
                    context,
                    _formatGpa(maxGpa),
                  ),
                  _gridLine(
                    context,
                    _formatGpa(maxGpa * 0.8),
                  ),
                  _gridLine(
                    context,
                    _formatGpa(maxGpa * 0.6),
                  ),
                  _gridLine(
                    context,
                    _formatGpa(maxGpa * 0.4),
                  ),
                  _gridLine(
                    context,
                    _formatGpa(maxGpa * 0.2),
                  ),
                  _gridLine(
                    context,
                    '0',
                  ),
                ],
              ),
            ),
          Positioned.fill(
            left: 38,
            right: 8,
            top: topPadding,
            bottom: bottomPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points
                  .map(
                    (point) => _point(
                      context,
                      point,
                      chartHeight,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendSummary(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final first = points.first.gpa;
    final last = points.last.gpa;
    final difference = last - first;

    final isUp = difference > 0;
    final isDown = difference < 0;

    final color = isUp
        ? Colors.green
        : isDown
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant;

    final icon = isUp
        ? Icons.trending_up_rounded
        : isDown
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    final label = isUp
        ? 'Improved by ${difference.abs().toStringAsFixed(2)}'
        : isDown
            ? 'Decreased by ${difference.abs().toStringAsFixed(2)}'
            : 'No change';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null &&
                          subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _trendSummary(context),
              ],
            ),
            const SizedBox(height: 16),
            if (points.isEmpty)
              _emptyState(context)
            else
              _barChart(context),
          ],
        ),
      ),
    );
  }
}

class GpaTrendPoint {
  final String label;
  final double gpa;
  final int? semester;
  final String? academicYear;

  const GpaTrendPoint({
    required this.label,
    required this.gpa,
    this.semester,
    this.academicYear,
  });
}