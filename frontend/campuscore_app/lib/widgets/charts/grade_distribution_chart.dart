import 'package:flutter/material.dart';

class GradeDistributionChart extends StatelessWidget {
  final Map<String, int> distribution;
  final String title;
  final String? subtitle;
  final double height;
  final bool showValues;
  final bool showPercentages;
  final bool compact;

  const GradeDistributionChart({
    super.key,
    required this.distribution,
    this.title = 'Grade Distribution',
    this.subtitle,
    this.height = 300,
    this.showValues = true,
    this.showPercentages = true,
    this.compact = false,
  });

  static const List<String> _gradeOrder = [
    'S',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
  ];

  List<MapEntry<String, int>> get _entries {
    final ordered = <MapEntry<String, int>>[];

    for (final grade in _gradeOrder) {
      if (distribution.containsKey(grade)) {
        ordered.add(
          MapEntry(
            grade,
            distribution[grade] ?? 0,
          ),
        );
      }
    }

    final additional = distribution.entries.where(
      (entry) => !_gradeOrder.contains(
        entry.key.toUpperCase(),
      ),
    );

    ordered.addAll(additional);

    return ordered;
  }

  int get _total {
    return distribution.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
  }

  int get _maximum {
    if (distribution.isEmpty) {
      return 0;
    }

    return distribution.values.fold<int>(
      0,
      (current, value) =>
          value > current ? value : current,
    );
  }

  Color _gradeColor(
    BuildContext context,
    String grade,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (grade.toUpperCase()) {
      case 'S':
        return scheme.primary;
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen.shade700;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.amber.shade800;
      case 'F':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _percentage(int value) {
    if (_total <= 0) {
      return '0.0%';
    }

    return '${((value / _total) * 100).toStringAsFixed(1)}%';
  }

  Widget _legendItem(
    BuildContext context,
    String grade,
    int count,
  ) {
    final theme = Theme.of(context);
    final color = _gradeColor(context, grade);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            grade,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (showValues) ...[
            const SizedBox(width: 5),
            Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    String grade,
    int count,
    double availableHeight,
  ) {
    final theme = Theme.of(context);
    final color = _gradeColor(context, grade);

    final ratio = _maximum <= 0
        ? 0.0
        : (count / _maximum).clamp(0, 1).toDouble();

    final barHeight = count == 0
        ? 2.0
        : (availableHeight * ratio)
            .clamp(2, availableHeight)
            .toDouble();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 7,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showValues)
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (showPercentages) ...[
              const SizedBox(height: 2),
              Text(
                _percentage(count),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
            const SizedBox(height: 5),
            SizedBox(
              height: availableHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 350,
                  ),
                  width: compact ? 24 : 34,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Text(
                grade,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
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
              Icons.bar_chart_outlined,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No grade data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = _entries;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          compact ? 14 : 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '$_total Students',
                      style:
                          theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty || _total == 0)
              _emptyState(context)
            else
              Column(
                children: [
                  SizedBox(
                    height: height,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final chartHeight =
                            height - 62;

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: entries
                              .map(
                                (entry) => _bar(
                                  context,
                                  entry.key,
                                  entry.value,
                                  chartHeight,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries
                        .map(
                          (entry) => _legendItem(
                            context,
                            entry.key,
                            entry.value,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}