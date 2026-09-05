import 'package:flutter/material.dart';

class MarksTable extends StatelessWidget {
  final List<MarksTableRow> rows;
  final bool showStudent;
  final bool showTotal;
  final bool showGrade;
  final bool showActions;
  final bool isLoading;
  final String emptyMessage;
  final void Function(MarksTableRow row)? onEdit;
  final void Function(MarksTableRow row)? onView;

  const MarksTable({
    super.key,
    required this.rows,
    this.showStudent = true,
    this.showTotal = true,
    this.showGrade = true,
    this.showActions = false,
    this.isLoading = false,
    this.emptyMessage = 'No marks available.',
    this.onEdit,
    this.onView,
  });

  String _formatMark(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _formatTotal(double total) {
    if (total % 1 == 0) {
      return total.toInt().toString();
    }

    return total.toStringAsFixed(1);
  }

  Color _gradeColor(BuildContext context, String? grade) {
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

  Widget _header(
    BuildContext context,
    String text, {
    TextAlign alignment = TextAlign.center,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        text,
        textAlign: alignment,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    TextAlign alignment = TextAlign.center,
    FontWeight? fontWeight,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Text(
        text,
        textAlign: alignment,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _studentCell(
    BuildContext context,
    MarksTableRow row,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
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
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final columns = <DataColumn>[];

    if (showStudent) {
      columns.add(const DataColumn(label: Text('Student')));
    }

    columns.addAll([
      const DataColumn(label: Text('CAT 1 / 50')),
      const DataColumn(label: Text('CAT 2 / 50')),
      const DataColumn(label: Text('TEE / 100')),
      const DataColumn(label: Text('Internals / 20')),
    ]);

    if (showTotal) {
      columns.add(const DataColumn(label: Text('Total')));
    }

    if (showGrade) {
      columns.add(const DataColumn(label: Text('Grade')));
    }

    if (showActions) {
      columns.add(const DataColumn(label: Text('Actions')));
    }

    return columns;
  }

  DataRow _buildRow(
    BuildContext context,
    MarksTableRow row,
  ) {
    final cells = <DataCell>[];

    if (showStudent) {
      cells.add(
        DataCell(
          SizedBox(
            width: 210,
            child: _studentCell(context, row),
          ),
        ),
      );
    }

    cells.addAll([
      DataCell(
        Text(_formatMark(row.cat1)),
      ),
      DataCell(
        Text(_formatMark(row.cat2)),
      ),
      DataCell(
        Text(_formatMark(row.tee)),
      ),
      DataCell(
        Text(_formatMark(row.internals)),
      ),
    ]);

    if (showTotal) {
      cells.add(
        DataCell(
          Text(
            _formatTotal(row.total),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (showGrade) {
      cells.add(
        DataCell(
          _gradeBadge(context, row.grade),
        ),
      );
    }

    if (showActions) {
      cells.add(
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
      );
    }

    return DataRow(cells: cells);
  }

  Widget _buildMobileCard(
    BuildContext context,
    MarksTableRow row,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (showStudent)
              Row(
                children: [
                  Expanded(
                    child: _studentCell(context, row),
                  ),
                  if (showGrade) _gradeBadge(context, row.grade),
                ],
              )
            else if (showGrade)
              Align(
                alignment: Alignment.centerRight,
                child: _gradeBadge(context, row.grade),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;

                final fields = [
                  _MobileMark(
                    label: 'CAT 1',
                    value: _formatMark(row.cat1),
                  ),
                  _MobileMark(
                    label: 'CAT 2',
                    value: _formatMark(row.cat2),
                  ),
                  _MobileMark(
                    label: 'TEE',
                    value: _formatMark(row.tee),
                  ),
                  _MobileMark(
                    label: 'Internals',
                    value: _formatMark(row.internals),
                  ),
                ];

                if (compact) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _markBox(
                              context,
                              fields[0],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _markBox(
                              context,
                              fields[1],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _markBox(
                              context,
                              fields[2],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _markBox(
                              context,
                              fields[3],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: fields
                      .map(
                        (field) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: _markBox(
                              context,
                              field,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            if (showTotal) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTotal(row.total),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showActions &&
                (onView != null || onEdit != null)) ...[
              const SizedBox(height: 12),
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
    );
  }

  Widget _markBox(
    BuildContext context,
    _MobileMark mark,
  ) {
    final theme = Theme.of(context);

    return Container(
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
            mark.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            mark.value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          child: Center(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useMobileLayout = constraints.maxWidth < 850;

        if (useMobileLayout) {
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

        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _buildColumns(),
              rows: rows
                  .map(
                    (row) => _buildRow(
                      context,
                      row,
                    ),
                  )
                  .toList(),
              headingRowHeight: 52,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 78,
              columnSpacing: 22,
              horizontalMargin: 12,
            ),
          ),
        );
      },
    );
  }
}

class MarksTableRow {
  final int? studentId;
  final String studentName;
  final String rollNo;
  final double? cat1;
  final double? cat2;
  final double? tee;
  final double? internals;
  final double total;
  final String? grade;

  const MarksTableRow({
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    this.cat1,
    this.cat2,
    this.tee,
    this.internals,
    this.total = 0,
    this.grade,
  });

  bool get hasMissingMarks {
    return cat1 == null ||
        cat2 == null ||
        tee == null ||
        internals == null;
  }
}

class _MobileMark {
  final String label;
  final String value;

  const _MobileMark({
    required this.label,
    required this.value,
  });
}