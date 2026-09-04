import 'package:flutter/material.dart';

class PerformanceChart extends StatelessWidget {
  final List<PerformancePoint> points;
  final String title;
  final String? subtitle;
  final double maxValue;
  final double height;
  final bool showValues;
  final bool showGrid;
  final bool compact;
  final Color? lineColor;

  const PerformanceChart({
    super.key,
    required this.points,
    this.title = 'Performance',
    this.subtitle,
    this.maxValue = 100,
    this.height = 280,
    this.showValues = true,
    this.showGrid = true,
    this.compact = false,
    this.lineColor,
  });

  String _formatValue(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Widget _gridLine(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
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
              Icons.insights_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No performance data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final chartColor =
        lineColor ?? theme.colorScheme.primary;

    const topPadding = 24.0;
    const bottomPadding = 48.0;
    const leftPadding = 40.0;
    const rightPadding = 12.0;

    final chartHeight =
        height - topPadding - bottomPadding;

    final safeMax =
        maxValue <= 0 ? 100.0 : maxValue;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              top: topPadding,
              bottom: bottomPadding,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _gridLine(
                    context,
                    _formatValue(safeMax),
                  ),
                  _gridLine(
                    context,
                    _formatValue(safeMax * 0.75),
                  ),
                  _gridLine(
                    context,
                    _formatValue(safeMax * 0.50),
                  ),
                  _gridLine(
                    context,
                    _formatValue(safeMax * 0.25),
                  ),
                  _gridLine(
                    context,
                    '0',
                  ),
                ],
              ),
            ),
          Positioned.fill(
            left: leftPadding,
            right: rightPadding,
            top: topPadding,
            bottom: bottomPadding,
            child: CustomPaint(
              painter: _PerformanceChartPainter(
                points: points,
                maxValue: safeMax,
                color: chartColor,
                showGrid: false,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: List.generate(
                    points.length,
                    (index) {
                      final point = points[index];

                      return Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: -40,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          Alignment.topCenter,
                                      child: _pointMarker(
                                        context,
                                        point,
                                        chartHeight,
                                        safeMax,
                                        chartColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    point.label,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    textAlign:
                                        TextAlign.center,
                                    style: theme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: theme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointMarker(
    BuildContext context,
    PerformancePoint point,
    double chartHeight,
    double safeMax,
    Color color,
  ) {
    final theme = Theme.of(context);

    final ratio = (point.value / safeMax)
        .clamp(0, 1)
        .toDouble();

    final topPosition =
        chartHeight * (1 - ratio);

    return Transform.translate(
      offset: Offset(
        0,
        topPosition - 9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showValues)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                _formatValue(point.value),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 5),
          Container(
            width: compact ? 10 : 12,
            height: compact ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2,
              ),
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
        padding: EdgeInsets.all(
          compact ? 14 : 18,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                if (points.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${points.length} ${points.length == 1 ? 'Point' : 'Points'}',
                      style:
                          theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (points.isEmpty)
              _emptyState(context)
            else
              _buildChart(context),
          ],
        ),
      ),
    );
  }
}

class PerformancePoint {
  final String label;
  final double value;
  final String? category;
  final String? description;
  final DateTime? date;

  const PerformancePoint({
    required this.label,
    required this.value,
    this.category,
    this.description,
    this.date,
  });
}

class _PerformanceChartPainter extends CustomPainter {
  final List<PerformancePoint> points;
  final double maxValue;
  final Color color;
  final bool showGrid;

  const _PerformanceChartPainter({
    required this.points,
    required this.maxValue,
    required this.color,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    final chartPoints = <Offset>[];

    final horizontalStep = points.length == 1
        ? 0.0
        : size.width / (points.length - 1);

    for (var index = 0; index < points.length; index++) {
      final point = points[index];

      final ratio = (point.value / maxValue)
          .clamp(0, 1)
          .toDouble();

      final x = points.length == 1
          ? size.width / 2
          : index * horizontalStep;

      final y = size.height * (1 - ratio);

      chartPoints.add(
        Offset(x, y),
      );
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (var index = 0; index < chartPoints.length; index++) {
      final point = chartPoints[index];

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
        continue;
      }

      final previous = chartPoints[index - 1];

      final controlPoint1 = Offset(
        previous.dx +
            (point.dx - previous.dx) * 0.5,
        previous.dy,
      );

      final controlPoint2 = Offset(
        previous.dx +
            (point.dx - previous.dx) * 0.5,
        point.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        point.dx,
        point.dy,
      );
    }

    canvas.drawPath(
      path,
      linePaint,
    );

    if (showGrid) {
      final gridPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..strokeWidth = 1;

      for (var index = 1; index < 5; index++) {
        final y = size.height *
            (index / 5);

        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _PerformanceChartPainter oldDelegate,
  ) {
    return oldDelegate.points != points ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.color != color ||
        oldDelegate.showGrid != showGrid;
  }
}