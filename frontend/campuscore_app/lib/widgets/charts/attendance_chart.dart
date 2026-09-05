import 'package:flutter/material.dart';

class AttendanceChart extends StatelessWidget {
  final List<AttendanceChartPoint> points;
  final String title;
  final String? subtitle;
  final double minimumRequiredPercentage;
  final double height;
  final bool showValues;
  final bool showGrid;
  final bool showLegend;
  final bool compact;

  const AttendanceChart({
    super.key,
    required this.points,
    this.title = 'Attendance',
    this.subtitle,
    this.minimumRequiredPercentage = 75,
    this.height = 280,
    this.showValues = true,
    this.showGrid = true,
    this.showLegend = true,
    this.compact = false,
  });

  double get _maxValue {
    if (points.isEmpty) {
      return 100;
    }

    final highest = points
        .map((point) => point.percentage)
        .fold<double>(
          0,
          (current, value) =>
              value > current ? value : current,
        );

    return highest < 100 ? 100 : highest;
  }

  Color _barColor(
    BuildContext context,
    double percentage,
  ) {
    final scheme = Theme.of(context).colorScheme;

    if (percentage < minimumRequiredPercentage) {
      return scheme.error;
    }

    if (percentage < minimumRequiredPercentage + 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  Widget _legendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'No attendance data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    AttendanceChartPoint point,
    double availableHeight,
  ) {
    final theme = Theme.of(context);
    final color = _barColor(
      context,
      point.percentage,
    );

    final normalizedHeight = _maxValue <= 0
        ? 0.0
        : (point.percentage / _maxValue)
            .clamp(0, 1)
            .toDouble();

    final barHeight =
        (availableHeight * normalizedHeight)
            .clamp(2, availableHeight)
            .toDouble();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showValues)
              Text(
                _formatPercentage(point.percentage),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            if (showValues)
              const SizedBox(height: 5),
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
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

  Widget _chart(BuildContext context) {
    final theme = Theme.of(context);

    const chartTopPadding = 28.0;
    const chartBottomPadding = 44.0;

    final availableHeight = height -
        chartTopPadding -
        chartBottomPadding;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              top: chartTopPadding,
              bottom: chartBottomPadding,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _gridLine(context, '100%'),
                  _gridLine(
                    context,
                    '${(_maxValue * 0.75).toStringAsFixed(0)}%',
                  ),
                  _gridLine(
                    context,
                    '${(_maxValue * 0.50).toStringAsFixed(0)}%',
                  ),
                  _gridLine(
                    context,
                    '${(_maxValue * 0.25).toStringAsFixed(0)}%',
                  ),
                  _gridLine(context, '0%'),
                ],
              ),
            ),
          if (points.isNotEmpty)
            Positioned.fill(
              left: 42,
              right: 8,
              top: chartTopPadding,
              bottom: chartBottomPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points
                    .map(
                      (point) => _bar(
                        context,
                        point,
                        availableHeight,
                      ),
                    )
                    .toList(),
              ),
            ),
          Positioned(
            left: 0,
            top: chartTopPadding,
            bottom: chartBottomPadding,
            child: SizedBox(
              width: 38,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '100',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '75',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '50',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '25',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (minimumRequiredPercentage <= 100)
            Positioned(
              left: 42,
              right: 8,
              bottom: chartBottomPadding +
                  (availableHeight *
                      (minimumRequiredPercentage / 100)),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.error,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${minimumRequiredPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _gridLine(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 42),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outlineVariant,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null &&
                          subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style:
                              theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showLegend)
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _legendItem(
                        context,
                        color: Colors.green,
                        label: 'Good',
                      ),
                      _legendItem(
                        context,
                        color: Colors.orange,
                        label: 'Near Threshold',
                      ),
                      _legendItem(
                        context,
                        color: theme.colorScheme.error,
                        label: 'Low',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (points.isEmpty)
              _emptyState(context)
            else
              _chart(context),
          ],
        ),
      ),
    );
  }
}

class AttendanceChartPoint {
  final String label;
  final double percentage;
  final String? subjectCode;
  final int? subjectId;

  const AttendanceChartPoint({
    required this.label,
    required this.percentage,
    this.subjectCode,
    this.subjectId,
  });
}