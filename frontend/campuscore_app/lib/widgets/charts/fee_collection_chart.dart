import 'package:flutter/material.dart';

class FeeCollectionChart extends StatelessWidget {
  final List<FeeCollectionPoint> points;
  final String title;
  final String? subtitle;
  final String currency;
  final double height;
  final bool showValues;
  final bool showLegend;
  final bool compact;

  const FeeCollectionChart({
    super.key,
    required this.points,
    this.title = 'Fee Collection',
    this.subtitle,
    this.currency = '₹',
    this.height = 280,
    this.showValues = true,
    this.showLegend = true,
    this.compact = false,
  });

  double get _maxValue {
    if (points.isEmpty) {
      return 0;
    }

    final highest = points
        .map((point) => point.collected)
        .fold<double>(
          0,
          (current, value) =>
              value > current ? value : current,
        );

    return highest;
  }

  double _chartMax() {
    final max = _maxValue;

    if (max <= 0) {
      return 100;
    }

    final magnitude = max >= 1000 ? 1000.0 : 100.0;
    final rounded = (max / magnitude).ceil() * magnitude;

    if (rounded <= max) {
      return max * 1.1;
    }

    return rounded;
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      return '$currency${value.toInt()}';
    }

    return '$currency${value.toStringAsFixed(2)}';
  }

  String _formatCompactAmount(double value) {
    if (value >= 10000000) {
      return '$currency${(value / 10000000).toStringAsFixed(1)}Cr';
    }

    if (value >= 100000) {
      return '$currency${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return '$currency${(value / 1000).toStringAsFixed(1)}K';
    }

    return _formatAmount(value);
  }

  Color _collectedColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _dueColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
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

  Widget _gridLine(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 50),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
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

  Widget _barGroup(
    BuildContext context,
    FeeCollectionPoint point,
    double chartMax,
    double availableHeight,
  ) {
    final theme = Theme.of(context);
    final collectedColor = _collectedColor(context);
    final dueColor = _dueColor(context);

    final collectedRatio = chartMax <= 0
        ? 0.0
        : (point.collected / chartMax)
            .clamp(0, 1)
            .toDouble();

    final dueRatio = chartMax <= 0
        ? 0.0
        : (point.due / chartMax)
            .clamp(0, 1)
            .toDouble();

    final collectedHeight =
        (availableHeight * collectedRatio)
            .clamp(2, availableHeight)
            .toDouble();

    final dueHeight =
        (availableHeight * dueRatio)
            .clamp(2, availableHeight)
            .toDouble();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showValues)
              Text(
                _formatCompactAmount(point.collected),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: collectedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (showValues)
              const SizedBox(height: 5),
            SizedBox(
              height: availableHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      height: collectedHeight,
                      decoration: BoxDecoration(
                        color: collectedColor,
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: dueHeight,
                      decoration: BoxDecoration(
                        color: dueColor,
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
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
    final chartMax = _chartMax();

    const topPadding = 24.0;
    const bottomPadding = 46.0;

    final availableHeight =
        height - topPadding - bottomPadding;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (points.isNotEmpty)
            Positioned.fill(
              top: topPadding,
              bottom: bottomPadding,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _gridLine(
                    context,
                    _formatCompactAmount(chartMax),
                  ),
                  _gridLine(
                    context,
                    _formatCompactAmount(chartMax * 0.75),
                  ),
                  _gridLine(
                    context,
                    _formatCompactAmount(chartMax * 0.50),
                  ),
                  _gridLine(
                    context,
                    _formatCompactAmount(chartMax * 0.25),
                  ),
                  _gridLine(
                    context,
                    _formatCompactAmount(0),
                  ),
                ],
              ),
            ),
          Positioned.fill(
            left: 50,
            right: 8,
            top: topPadding,
            bottom: bottomPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points
                  .map(
                    (point) => _barGroup(
                      context,
                      point,
                      chartMax,
                      availableHeight,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
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
              Icons.payments_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No fee collection data available',
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
                        color: _collectedColor(context),
                        label: 'Collected',
                      ),
                      _legendItem(
                        context,
                        color: _dueColor(context),
                        label: 'Due',
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

class FeeCollectionPoint {
  final String label;
  final double collected;
  final double due;
  final String? period;
  final DateTime? date;

  const FeeCollectionPoint({
    required this.label,
    required this.collected,
    required this.due,
    this.period,
    this.date,
  });

  double get total => collected + due;

  double get collectionRate {
    if (total <= 0) {
      return 0;
    }

    return collected / total;
  }
}