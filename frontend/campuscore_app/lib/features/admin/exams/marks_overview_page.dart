import 'package:flutter/material.dart';

class MarksOverviewPage extends StatefulWidget {
  final List<MarksOverviewItem> records;
  final List<MarksOverviewSubject> subjects;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final void Function(MarksOverviewItem item)? onView;
  final void Function(MarksOverviewItem item)? onEdit;
  final void Function(MarksOverviewItem item)? onCalculate;

  const MarksOverviewPage({
    super.key,
    this.records = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onView,
    this.onEdit,
    this.onCalculate,
  });

  @override
  State<MarksOverviewPage> createState() =>
      _MarksOverviewPageState();
}

class _MarksOverviewPageState
    extends State<MarksOverviewPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';
  String _subjectFilter = 'All';
  String _assessmentFilter = 'All';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
    });
  }

  List<String> get _subjectOptions {
    final values = widget.records
        .map((item) => item.subjectName.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...values];
  }

  List<MarksOverviewItem> get _filteredRecords {
    return widget.records.where((item) {
      final queryMatches =
          _query.isEmpty ||
          item.studentName.toLowerCase().contains(_query) ||
          item.rollNo.toLowerCase().contains(_query) ||
          item.subjectName.toLowerCase().contains(_query) ||
          item.subjectCode.toLowerCase().contains(_query);

      final subjectMatches =
          _subjectFilter == 'All' ||
          item.subjectName == _subjectFilter;

      final assessmentMatches =
          _assessmentFilter == 'All' ||
          item.assessmentType.toLowerCase() ==
              _assessmentFilter.toLowerCase();

      final statusMatches =
          _statusFilter == 'All' ||
          item.status.toLowerCase() ==
              _statusFilter.toLowerCase();

      return queryMatches &&
          subjectMatches &&
          assessmentMatches &&
          statusMatches;
    }).toList();
  }

  String _assessmentLabel(String value) {
    switch (value.toUpperCase()) {
      case 'CAT1':
        return 'CAT 1';
      case 'CAT2':
        return 'CAT 2';
      case 'TEE':
        return 'TEE';
      case 'INTERNAL':
        return 'Internal';
      default:
        return value;
    }
  }

  Color _assessmentColor(
    BuildContext context,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (value.toUpperCase()) {
      case 'CAT1':
        return scheme.primary;
      case 'CAT2':
        return Colors.blue;
      case 'TEE':
        return Colors.deepOrange;
      case 'INTERNAL':
        return Colors.purple;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  Color _statusColor(
    BuildContext context,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (value.toLowerCase()) {
      case 'complete':
      case 'completed':
      case 'entered':
      case 'published':
        return Colors.green;
      case 'pending':
      case 'incomplete':
      case 'missing':
        return Colors.orange;
      case 'locked':
        return scheme.primary;
      case 'error':
      case 'rejected':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  Widget _assessmentBadge(
    BuildContext context,
    String value,
  ) {
    final theme = Theme.of(context);
    final color = _assessmentColor(context, value);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _assessmentLabel(value),
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusBadge(
    BuildContext context,
    String value,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, value);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        value.trim().isEmpty ? 'Unknown' : value,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatMark(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Widget _studentInfo(
    BuildContext context,
    MarksOverviewItem item,
  ) {
    final theme = Theme.of(context);

    String initials = '?';
    final name = item.studentName.trim();

    if (name.isNotEmpty) {
      final parts = name
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      initials = parts.length == 1
          ? parts.first.substring(0, 1).toUpperCase()
          : '${parts.first.substring(0, 1)}'
                '${parts.last.substring(0, 1)}'
                .toUpperCase();
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              theme.colorScheme.primaryContainer,
          foregroundColor:
              theme.colorScheme.primary,
          child: Text(
            initials,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Unknown Student' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.rollNo.isNotEmpty)
                Text(
                  item.rollNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subjectInfo(
    BuildContext context,
    MarksOverviewItem item,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          item.subjectName.isEmpty
              ? 'Unknown Subject'
              : item.subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (item.subjectCode.isNotEmpty)
          Text(
            item.subjectCode,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _markMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileCard(
    BuildContext context,
    MarksOverviewItem item,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onView == null
            ? null
            : () => widget.onView!(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _studentInfo(
                      context,
                      item,
                    ),
                  ),
                  _statusBadge(
                    context,
                    item.status,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _subjectInfo(
                        context,
                        item,
                      ),
                    ),
                    _assessmentBadge(
                      context,
                      item.assessmentType,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _markMetric(
                    context,
                    label: 'Marks',
                    value:
                        '${_formatMark(item.marks)} / '
                        '${_formatMark(item.maxMarks)}',
                  ),
                  const SizedBox(width: 8),
                  _markMetric(
                    context,
                    label: 'Percentage',
                    value: item.maxMarks <= 0
                        ? '-'
                        : '${((item.marks ?? 0) / item.maxMarks * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
              if (item.enteredAt != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Entered: ${_formatDateTime(item.enteredAt!)}',
                    style:
                        theme.textTheme.bodySmall?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (widget.onEdit != null ||
                  widget.onCalculate != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    if (widget.onEdit != null)
                      TextButton.icon(
                        onPressed: () =>
                            widget.onEdit!(item),
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: const Text('Edit'),
                      ),
                    if (widget.onCalculate != null)
                      TextButton.icon(
                        onPressed: () =>
                            widget.onCalculate!(item),
                        icon: const Icon(
                          Icons.calculate_outlined,
                        ),
                        label: const Text('Calculate'),
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

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day =
        local.day.toString().padLeft(2, '0');
    final month =
        local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final suffix =
        local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year $hour:$minute $suffix';
  }

  Widget _desktopTable(
    BuildContext context,
    List<MarksOverviewItem> items,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest,
          ),
          columns: const [
            DataColumn(
              label: Text('Student'),
            ),
            DataColumn(
              label: Text('Subject'),
            ),
            DataColumn(
              label: Text('Assessment'),
            ),
            DataColumn(
              label: Text('Marks'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Entered At'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: items.map(
            (item) {
              return DataRow(
                onSelectChanged: widget.onView == null
                    ? null
                    : (selected) {
                        if (selected == true) {
                          widget.onView!(item);
                        }
                      },
                cells: [
                  DataCell(
                    SizedBox(
                      width: 230,
                      child: _studentInfo(
                        context,
                        item,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: _subjectInfo(
                        context,
                        item,
                      ),
                    ),
                  ),
                  DataCell(
                    _assessmentBadge(
                      context,
                      item.assessmentType,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${_formatMark(item.marks)} / '
                      '${_formatMark(item.maxMarks)}',
                    ),
                  ),
                  DataCell(
                    _statusBadge(
                      context,
                      item.status,
                    ),
                  ),
                  DataCell(
                    Text(
                      item.enteredAt == null
                          ? '-'
                          : _formatDateTime(
                              item.enteredAt!,
                            ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        if (widget.onView != null)
                          IconButton(
                            tooltip: 'View',
                            onPressed: () =>
                                widget.onView!(
                              item,
                            ),
                            icon: const Icon(
                              Icons
                                  .visibility_outlined,
                              size: 20,
                            ),
                          ),
                        if (widget.onEdit != null)
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () =>
                                widget.onEdit!(
                              item,
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                          ),
                        if (widget.onCalculate != null)
                          IconButton(
                            tooltip: 'Calculate',
                            onPressed: () =>
                                widget.onCalculate!(
                              item,
                            ),
                            icon: const Icon(
                              Icons
                                  .calculate_outlined,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ).toList(),
          columnSpacing: 26,
          horizontalMargin: 14,
          dataRowMinHeight: 66,
          dataRowMaxHeight: 82,
        ),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 850;

            final search = TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search student, roll number or subject',
                prefixIcon: const Icon(
                  Icons.search_outlined,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            );

            final subject =
                DropdownButtonFormField<String>(
              initialValue: _subjectFilter,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: _subjectOptions
                  .map(
                    (value) =>
                        DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'All'
                            ? 'All Subjects'
                            : value,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _subjectFilter = value;
                });
              },
            );

            final assessment =
                DropdownButtonFormField<String>(
              initialValue: _assessmentFilter,
              decoration: const InputDecoration(
                labelText: 'Assessment',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'CAT1',
                  child: Text('CAT 1'),
                ),
                DropdownMenuItem(
                  value: 'CAT2',
                  child: Text('CAT 2'),
                ),
                DropdownMenuItem(
                  value: 'TEE',
                  child: Text('TEE'),
                ),
                DropdownMenuItem(
                  value: 'INTERNAL',
                  child: Text('Internal'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _assessmentFilter = value;
                });
              },
            );

            final status =
                DropdownButtonFormField<String>(
              initialValue: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Complete',
                  child: Text('Complete'),
                ),
                DropdownMenuItem(
                  value: 'Incomplete',
                  child: Text('Incomplete'),
                ),
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'Locked',
                  child: Text('Locked'),
                ),
                DropdownMenuItem(
                  value: 'Published',
                  child: Text('Published'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _statusFilter = value;
                });
              },
            );

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: subject,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: assessment,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  status,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: search,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: subject,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 165,
                  child: assessment,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 165,
                  child: status,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final theme = Theme.of(context);
    final records = _filteredRecords;

    final complete = records
        .where(
          (item) =>
              item.status.toLowerCase() ==
              'complete',
        )
        .length;

    final incomplete = records
        .where(
          (item) =>
              item.status.toLowerCase() ==
                  'incomplete' ||
              item.status.toLowerCase() ==
                  'pending',
        )
        .length;

    final enteredMarks = records
        .where((item) => item.marks != null)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 650 ? 2 : 4;

        final cards = [
          _summaryCard(
            context,
            title: 'Records',
            value: '${records.length}',
            icon: Icons.fact_check_outlined,
            color: theme.colorScheme.primary,
          ),
          _summaryCard(
            context,
            title: 'Marks Entered',
            value: '$enteredMarks',
            icon: Icons.edit_note_outlined,
            color: Colors.blue,
          ),
          _summaryCard(
            context,
            title: 'Complete',
            value: '$complete',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _summaryCard(
            context,
            title: 'Incomplete',
            value: '$incomplete',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 84,
          ),
          itemBuilder: (context, index) =>
              cards[index],
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _query.isNotEmpty ||
                      _subjectFilter != 'All' ||
                      _assessmentFilter != 'All' ||
                      _statusFilter != 'All'
                  ? Icons.search_off_outlined
                  : Icons.assignment_outlined,
              size: 48,
              color:
                  theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              widget.records.isEmpty
                  ? 'No marks available.'
                  : 'No marks match the selected filters.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.records.isEmpty
                  ? 'Marks will appear here after faculty enter assessment scores.'
                  : 'Try changing the search or filters.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
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
    final filtered = _filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Overview'),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed: widget.isLoading
                  ? null
                  : widget.onRefresh,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marks Overview',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Review assessment marks before calculating final results.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.errorMessage != null &&
                      widget.errorMessage!
                          .trim()
                          .isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color: theme
                            .colorScheme
                            .errorContainer
                            .withValues(
                          alpha: 0.55,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        border: Border.all(
                          color: theme
                              .colorScheme
                              .error
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme
                                .colorScheme
                                .error,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              widget
                                  .errorMessage!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _summary(context),
                  const SizedBox(height: 18),
                  _filters(context),
                  const SizedBox(height: 18),
                  Expanded(
                    child: widget.isLoading &&
                            widget.records.isEmpty
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : filtered.isEmpty
                            ? _emptyState(context)
                            : LayoutBuilder(
                                builder: (
                                  context,
                                  constraints,
                                ) {
                                  if (constraints
                                          .maxWidth <
                                      850) {
                                    return ListView.builder(
                                      padding:
                                          const EdgeInsets
                                              .only(
                                        bottom: 24,
                                      ),
                                      itemCount:
                                          filtered.length,
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        return _mobileCard(
                                          context,
                                          filtered[index],
                                        );
                                      },
                                    );
                                  }

                                  return SingleChildScrollView(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      bottom: 24,
                                    ),
                                    child:
                                        _desktopTable(
                                      context,
                                      filtered,
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarksOverviewItem {
  final int id;
  final int? studentId;
  final String studentName;
  final String rollNo;
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final String assessmentType;
  final double? marks;
  final double maxMarks;
  final String status;
  final DateTime? enteredAt;

  const MarksOverviewItem({
    required this.id,
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    this.subjectId,
    this.subjectName = '',
    this.subjectCode = '',
    this.assessmentType = 'CAT1',
    this.marks,
    this.maxMarks = 0,
    this.status = 'Incomplete',
    this.enteredAt,
  });
}

class MarksOverviewSubject {
  final int id;
  final String name;
  final String code;
  final int semester;

  const MarksOverviewSubject({
    required this.id,
    required this.name,
    this.code = '',
    this.semester = 0,
  });
}