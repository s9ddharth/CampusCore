import 'package:flutter/material.dart';

class ResultTable extends StatelessWidget {
  final List<ResultTableRow> rows;
  final String title;
  final bool showStudent;
  final bool showMarks;
  final bool showGradePoint;
  final bool showStatus;
  final bool showActions;
  final bool isLoading;
  final String emptyMessage;
  final void Function(ResultTableRow row)? onTap;
  final void Function(ResultTableRow row)? onView;
  final void Function(ResultTableRow row)? onEdit;

  const ResultTable({
    super.key,
    required this.rows,
    this.title = 'Results',
    this.showStudent = true,
    this.showMarks = true,
    this.showGradePoint = true,
    this.showStatus = true,
    this.showActions = false,
    this.isLoading = false,
    this.emptyMessage = 'No results available.',
    this.onTap,
    this.onView,
    this.onEdit,
  });

  String _formatNumber(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Color _gradeColor(
    BuildContext context,
    String? grade,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (grade?.toUpperCase()) {
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

  Widget _statusBadge(
    BuildContext context,
    ResultTableRow row,
  ) {
    final theme = Theme.of(context);

    if (row.status == null || row.status!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isPass = row.isPassed;
    final isIncomplete = row.status!.toLowerCase() == 'incomplete';

    final color = isIncomplete
        ? Colors.orange
        : isPass
            ? Colors.green
            : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        row.status!,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _studentCell(
    BuildContext context,
    ResultTableRow row,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
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

  Widget _buildDesktopTable(BuildContext context) {
    final theme = Theme.of(context);

    final columns = <DataColumn>[
      if (showStudent)
        const DataColumn(
          label: Text('Student'),
        ),
      if (showMarks)
        const DataColumn(
          label: Text('Normalized Score'),
        ),
      const DataColumn(
        label: Text('Grade'),
      ),
      if (showGradePoint)
        const DataColumn(
          label: Text('Grade Point'),
        ),
      if (showStatus)
        const DataColumn(
          label: Text('Status'),
        ),
      if (showActions)
        const DataColumn(
          label: Text('Actions'),
        ),
    ];

    final dataRows = rows.map((row) {
      return DataRow(
        onSelectChanged: onTap == null || isLoading
            ? null
            : (selected) {
                if (selected == true) {
                  onTap!(row);
                }
              },
        color: row.isPassed
            ? null
            : WidgetStatePropertyAll(
                theme.colorScheme.errorContainer.withValues(
                  alpha: 0.12,
                ),
              ),
        cells: [
          if (showStudent)
            DataCell(
              SizedBox(
                width: 230,
                child: _studentCell(
                  context,
                  row,
                ),
              ),
            ),
          if (showMarks)
            DataCell(
              Text(
                _formatNumber(row.normalizedScore),
              ),
            ),
          DataCell(
            _gradeBadge(
              context,
              row.grade,
            ),
          ),
          if (showGradePoint)
            DataCell(
              Text(
                _formatNumber(row.gradePoint),
              ),
            ),
          if (showStatus)
            DataCell(
              _statusBadge(
                context,
                row,
              ),
            ),
          if (showActions)
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onView != null)
                    IconButton(
                      tooltip: 'View',
                      onPressed: isLoading
                          ? null
                          : () => onView!(row),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                      ),
                    ),
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: isLoading
                          ? null
                          : () => onEdit!(row),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    }).toList();

    return DataTable(
      headingRowColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainerHighest,
      ),
      columns: columns,
      rows: dataRows,
      columnSpacing: 28,
      horizontalMargin: 16,
      dataRowMinHeight: 66,
      dataRowMaxHeight: 82,
    );
  }

  Widget _metricBox(
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    ResultTableRow row,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
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
                  if (showStudent)
                    Expanded(
                      child: _studentCell(
                        context,
                        row,
                      ),
                    ),
                  _gradeBadge(
                    context,
                    row.grade,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (showMarks)
                    _metricBox(
                      context,
                      label: 'Score',
                      value: _formatNumber(
                        row.normalizedScore,
                      ),
                    ),
                  if (showMarks && showGradePoint)
                    const SizedBox(width: 10),
                  if (showGradePoint)
                    _metricBox(
                      context,
                      label: 'Grade Point',
                      value: _formatNumber(
                        row.gradePoint,
                      ),
                    ),
                ],
              ),
              if (showStatus) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _statusBadge(
                        context,
                        row,
                      ),
                    ],
                  ),
                ),
              ],
              if (showActions &&
                  (onView != null || onEdit != null)) ...[
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onView != null)
                      TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => onView!(row),
                        icon: const Icon(
                          Icons.visibility_outlined,
                        ),
                        label: const Text('View'),
                      ),
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => onEdit!(row),
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: const Text('Edit'),
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
                Icons.assignment_outlined,
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

class ResultTableRow {
  final int studentId;
  final String studentName;
  final String rollNo;
  final double? normalizedScore;
  final double? gradePoint;
  final String? grade;
  final String? status;
  final bool isPassed;

  const ResultTableRow({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.normalizedScore,
    this.gradePoint,
    this.grade,
    this.status,
    this.isPassed = true,
  });
}