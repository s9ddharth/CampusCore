import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final List<double>? columnWidths;
  final bool bordered;
  final bool compact;
  final bool zebra;
  final bool stickyHeader;
  final String emptyMessage;
  final EdgeInsetsGeometry cellPadding;
  final Widget? headerTrailing;

  const AppTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
    this.bordered = true,
    this.compact = false,
    this.zebra = false,
    this.stickyHeader = false,
    this.emptyMessage = 'No data available.',
    this.cellPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    this.headerTrailing,
  });

  TableBorder _tableBorder(BuildContext context) {
    if (!bordered) {
      return TableBorder.symmetric(
        inside: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      );
    }

    return TableBorder.all(
      color: Theme.of(context)
          .colorScheme
          .outlineVariant,
      width: 1,
    );
  }

  TableRow _headerRow(BuildContext context) {
    final theme = Theme.of(context);

    return TableRow(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      children: headers.map(
        (header) {
          return Padding(
            padding: cellPadding,
            child: Text(
              header,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  List<TableRow> _buildRows(BuildContext context) {
    final theme = Theme.of(context);

    return List.generate(
      rows.length,
      (index) {
        final row = rows[index];

        return TableRow(
          decoration: zebra && index.isOdd
              ? BoxDecoration(
                  color: theme.colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.35),
                )
              : null,
          children: List.generate(
            headers.length,
            (columnIndex) {
              final child = columnIndex < row.length
                  ? row[columnIndex]
                  : const SizedBox.shrink();

              return Padding(
                padding: compact
                    ? const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      )
                    : cellPadding,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);

    final children = <TableRow>[
      _headerRow(context),
      ..._buildRows(context),
    ];

    final table = Table(
      border: _tableBorder(context),
      defaultVerticalAlignment:
          TableCellVerticalAlignment.middle,
      columnWidths: columnWidths == null
          ? null
          : {
              for (
                var i = 0;
                i < columnWidths!.length;
                i++
              )
                i: FixedColumnWidth(columnWidths![i]),
            },
      children: children,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: table,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) {
      return _buildEmpty(context);
    }

    if (rows.isEmpty) {
      return _buildEmpty(context);
    }

    final table = _buildTable(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headerTrailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: headerTrailing,
            ),
          ),
        if (stickyHeader)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
      ],
    );
  }
}