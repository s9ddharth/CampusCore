import 'package:flutter/material.dart';

class RankingTable extends StatelessWidget {
  final List<RankingTableRow> rows;
  final String title;
  final bool showGrade;
  final bool showScore;
  final bool showRawMarks;
  final bool highlightTopStudents;
  final int topCount;
  final bool isLoading;
  final String emptyMessage;
  final void Function(RankingTableRow row)? onTap;

  const RankingTable({
    super.key,
    required this.rows,
    this.title = 'Student Ranking',
    this.showGrade = true,
    this.showScore = true,
    this.showRawMarks = true,
    this.highlightTopStudents = true,
    this.topCount = 5,
    this.isLoading = false,
    this.emptyMessage = 'No ranking data available.',
    this.onTap,
  });

  Color _gradeColor(
    BuildContext context,
    String? grade,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (grade?.toUpperCase()) {
      case 'S':
        return colorScheme.primary;
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
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _formatNumber(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _gradeBadge(
    BuildContext context,
    String? grade,
  ) {
    final theme = Theme.of(context);

    if (grade == null || grade.trim().isEmpty) {
      return Text(
        '-',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final color = _gradeColor(context, grade);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        grade,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rankBadge(
    BuildContext context,
    int rank,
  ) {
    final theme = Theme.of(context);

    IconData? icon;

    if (rank == 1) {
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      icon = Icons.military_tech;
    } else if (rank == 3) {
      icon = Icons.workspace_premium;
    }

    if (icon == null) {
      return Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          '$rank',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
      ),
      child: Icon(
        icon,
        size: 20,
        color: theme.colorScheme.primary,
      ),
    );
  }

  bool _isTopStudent(int rank) {
    return highlightTopStudents &&
        rank > 0 &&
        rank <= topCount;
  }

  Widget _studentInfo(
    BuildContext context,
    RankingTableRow row,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          child: Text(
            row.studentName.isEmpty
                ? '?'
                : row.studentName[0].toUpperCase(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.studentName.isEmpty
                    ? 'Unknown Student'
                    : row.studentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (row.rollNo.isNotEmpty)
                Text(
                  row.rollNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return DataTable(
      headingRowColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainerHighest,
      ),
      columns: [
        const DataColumn(
          label: Text('Rank'),
        ),
        const DataColumn(
          label: Text('Student'),
        ),
        if (showRawMarks)
          const DataColumn(
            label: Text('Raw Total'),
          ),
        if (showScore)
          const DataColumn(
            label: Text('Normalized Score'),
          ),
        if (showGrade)
          const DataColumn(
            label: Text('Grade'),
          ),
      ],
      rows: rows.map((row) {
        final topStudent = _isTopStudent(row.rank);

        return DataRow(
          color: topStudent
              ? WidgetStatePropertyAll(
                  theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                )
              : null,
          onSelectChanged: onTap == null
              ? null
              : (selected) {
                  if (selected == true && !isLoading) {
                    onTap!(row);
                  }
                },
          cells: [
            DataCell(
              _rankBadge(
                context,
                row.rank,
              ),
            ),
            DataCell(
              SizedBox(
                width: 240,
                child: _studentInfo(
                  context,
                  row,
                ),
              ),
            ),
            if (showRawMarks)
              DataCell(
                Text(
                  _formatNumber(row.rawTotal),
                ),
              ),
            if (showScore)
              DataCell(
                Text(
                  _formatNumber(row.normalizedScore),
                ),
              ),
            if (showGrade)
              DataCell(
                _gradeBadge(
                  context,
                  row.grade,
                ),
              ),
          ],
        );
      }).toList(),
      columnSpacing: 28,
      horizontalMargin: 16,
      dataRowMinHeight: 68,
      dataRowMaxHeight: 82,
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    RankingTableRow row,
  ) {
    final theme = Theme.of(context);
    final topStudent = _isTopStudent(row.rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: topStudent ? 2 : 1,
      color: topStudent
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      child: InkWell(
        onTap: onTap == null || isLoading
            ? null
            : () => onTap!(row),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _rankBadge(
                    context,
                    row.rank,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _studentInfo(
                      context,
                      row,
                    ),
                  ),
                  if (showGrade)
                    _gradeBadge(
                      context,
                      row.grade,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (showRawMarks)
                    _metricCard(
                      context,
                      label: 'Raw Total',
                      value: _formatNumber(row.rawTotal),
                    ),
                  if (showRawMarks && showScore)
                    const SizedBox(width: 10),
                  if (showScore)
                    _metricCard(
                      context,
                      label: 'Normalized',
                      value: _formatNumber(
                        row.normalizedScore,
                      ),
                    ),
                ],
              ),
              if (row.tee != null ||
                  row.qualifying ||
                  row.eligible) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (row.tee != null)
                      _metricCard(
                        context,
                        label: 'TEE',
                        value: _formatNumber(row.tee),
                      ),
                    if (row.tee != null)
                      const SizedBox(width: 10),
                    _metricCard(
                      context,
                      label: 'Eligibility',
                      value: row.eligible
                          ? 'Eligible'
                          : 'Not Eligible',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 42,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: rows
                        .map(
                          (row) => _buildMobileCard(
                            context,
                            row,
                          ),
                        )
                        .toList(),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDesktopTable(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RankingTableRow {
  final int studentId;
  final int rank;
  final String studentName;
  final String rollNo;
  final double? rawTotal;
  final double? normalizedScore;
  final double? tee;
  final String? grade;
  final bool qualifying;
  final bool eligible;

  const RankingTableRow({
    required this.studentId,
    required this.rank,
    required this.studentName,
    required this.rollNo,
    this.rawTotal,
    this.normalizedScore,
    this.tee,
    this.grade,
    this.qualifying = true,
    this.eligible = true,
  });
}