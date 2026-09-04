import 'package:flutter/material.dart';

class AttendanceGrid extends StatelessWidget {
  final List<AttendanceGridRow> rows;
  final String title;
  final bool showSubject;
  final bool showStatus;
  final bool showActions;
  final bool isLoading;
  final String emptyMessage;
  final void Function(AttendanceGridRow row)? onTap;
  final void Function(AttendanceGridRow row)? onEdit;

  const AttendanceGrid({
    super.key,
    required this.rows,
    this.title = 'Attendance',
    this.showSubject = true,
    this.showStatus = true,
    this.showActions = false,
    this.isLoading = false,
    this.emptyMessage = 'No attendance records available.',
    this.onTap,
    this.onEdit,
  });

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  Color _statusColor(
    BuildContext context,
    AttendanceGridRow row,
  ) {
    final scheme = Theme.of(context).colorScheme;

    if (row.percentage < row.minimumRequiredPercentage) {
      return scheme.error;
    }

    if (row.percentage < row.minimumRequiredPercentage + 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _statusText(
    AttendanceGridRow row,
  ) {
    if (row.status != null && row.status!.trim().isNotEmpty) {
      return row.status!;
    }

    if (row.percentage < row.minimumRequiredPercentage) {
      return 'Low';
    }

    return 'Good';
  }

  Widget _statusBadge(
    BuildContext context,
    AttendanceGridRow row,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, row);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _statusText(row),
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _percentageIndicator(
    BuildContext context,
    AttendanceGridRow row,
  ) {
    final theme = Theme.of(context);
    final percentage = row.percentage.clamp(0, 100) / 100;
    final color = _statusColor(context, row);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage.toDouble(),
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatPercentage(row.percentage),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentCell(
    BuildContext context,
    AttendanceGridRow row,
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

  Widget _subjectCell(
    BuildContext context,
    AttendanceGridRow row,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.subjectName.isEmpty
              ? 'Unknown Subject'
              : row.subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (row.subjectCode.isNotEmpty)
          Text(
            row.subjectCode,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    final theme = Theme.of(context);

    final columns = <DataColumn>[
      const DataColumn(
        label: Text('Student'),
      ),
      if (showSubject)
        const DataColumn(
          label: Text('Subject'),
        ),
      const DataColumn(
        label: Text('Present'),
      ),
      const DataColumn(
        label: Text('Absent'),
      ),
      const DataColumn(
        label: Text('Total'),
      ),
      const DataColumn(
        label: Text('Attendance'),
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
      final isLow = row.percentage <
          row.minimumRequiredPercentage;

      return DataRow(
        color: isLow
            ? WidgetStatePropertyAll(
                theme.colorScheme.errorContainer.withValues(
                  alpha: 0.10,
                ),
              )
            : null,
        onSelectChanged: onTap == null || isLoading
            ? null
            : (selected) {
                if (selected == true) {
                  onTap!(row);
                }
              },
        cells: [
          DataCell(
            SizedBox(
              width: 210,
              child: _studentCell(
                context,
                row,
              ),
            ),
          ),
          if (showSubject)
            DataCell(
              SizedBox(
                width: 190,
                child: _subjectCell(
                  context,
                  row,
                ),
              ),
            ),
          DataCell(
            Text(
              '${row.present}',
            ),
          ),
          DataCell(
            Text(
              '${row.absent}',
            ),
          ),
          DataCell(
            Text(
              '${row.totalClasses}',
            ),
          ),
          DataCell(
            _percentageIndicator(
              context,
              row,
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
      columnSpacing: 24,
      horizontalMargin: 14,
      dataRowMinHeight: 68,
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
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
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

  Widget _buildMobileCard(
    BuildContext context,
    AttendanceGridRow row,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _studentCell(
                      context,
                      row,
                    ),
                  ),
                  if (showStatus)
                    _statusBadge(
                      context,
                      row,
                    ),
                ],
              ),
              if (showSubject) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _subjectCell(
                    context,
                    row,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _metricBox(
                    context,
                    label: 'Present',
                    value: '${row.present}',
                  ),
                  const SizedBox(width: 10),
                  _metricBox(
                    context,
                    label: 'Absent',
                    value: '${row.absent}',
                  ),
                  const SizedBox(width: 10),
                  _metricBox(
                    context,
                    label: 'Total',
                    value: '${row.totalClasses}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _percentageIndicator(
                      context,
                      row,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Min ${_formatPercentage(row.minimumRequiredPercentage)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (showActions && onEdit != null) ...[
                const SizedBox(height: 10),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => onEdit!(row),
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text('Edit'),
                  ),
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
                Icons.fact_check_outlined,
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
                if (constraints.maxWidth < 850) {
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

class AttendanceGridRow {
  final int? studentId;
  final String studentName;
  final String rollNo;
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final int present;
  final int absent;
  final int totalClasses;
  final double percentage;
  final double minimumRequiredPercentage;
  final String? status;

  const AttendanceGridRow({
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    this.subjectId,
    this.subjectName = '',
    this.subjectCode = '',
    this.present = 0,
    this.absent = 0,
    this.totalClasses = 0,
    this.percentage = 0,
    this.minimumRequiredPercentage = 75,
    this.status,
  });
}