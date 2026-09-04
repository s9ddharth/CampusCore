import 'package:flutter/material.dart';

class AttendanceOverviewPage extends StatefulWidget {
  final List<AttendanceOverviewItem> records;
  final bool isLoading;
  final String? errorMessage;
  final double minimumRequiredPercentage;
  final VoidCallback? onRefresh;
  final void Function(AttendanceOverviewItem item)? onView;
  final void Function(AttendanceOverviewItem item)? onEdit;

  const AttendanceOverviewPage({
    super.key,
    this.records = const [],
    this.isLoading = false,
    this.errorMessage,
    this.minimumRequiredPercentage = 75,
    this.onRefresh,
    this.onView,
    this.onEdit,
  });

  @override
  State<AttendanceOverviewPage> createState() =>
      _AttendanceOverviewPageState();
}

class _AttendanceOverviewPageState
    extends State<AttendanceOverviewPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';
  String _statusFilter = 'All';
  String _semesterFilter = 'All';
  String _subjectFilter = 'All';

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

  List<String> get _semesterOptions {
    final values = widget.records
        .map((item) => item.semester)
        .where((value) => value > 0)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...values.map((value) => value.toString()),
    ];
  }

  List<String> get _subjectOptions {
    final values = widget.records
        .map((item) => item.subjectName.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...values,
    ];
  }

  List<AttendanceOverviewItem> get _filteredRecords {
    return widget.records.where((item) {
      final queryMatches =
          _query.isEmpty ||
          item.studentName.toLowerCase().contains(_query) ||
          item.rollNo.toLowerCase().contains(_query) ||
          item.subjectName.toLowerCase().contains(_query) ||
          item.subjectCode.toLowerCase().contains(_query);

      final statusMatches =
          _statusFilter == 'All' ||
          _statusFor(item) == _statusFilter;

      final semesterMatches =
          _semesterFilter == 'All' ||
          item.semester.toString() == _semesterFilter;

      final subjectMatches =
          _subjectFilter == 'All' ||
          item.subjectName == _subjectFilter;

      return queryMatches &&
          statusMatches &&
          semesterMatches &&
          subjectMatches;
    }).toList();
  }

  String _statusFor(AttendanceOverviewItem item) {
    if (item.status != null &&
        item.status!.trim().isNotEmpty) {
      return item.status!;
    }

    if (item.percentage <
        widget.minimumRequiredPercentage) {
      return 'Low';
    }

    if (item.percentage <
        widget.minimumRequiredPercentage + 5) {
      return 'Near Threshold';
    }

    return 'Good';
  }

  Color _statusColor(
    BuildContext context,
    AttendanceOverviewItem item,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (_statusFor(item).toLowerCase()) {
      case 'low':
      case 'critical':
        return scheme.error;

      case 'near threshold':
      case 'warning':
        return Colors.orange;

      case 'good':
      case 'excellent':
        return Colors.green;

      default:
        return scheme.onSurfaceVariant;
    }
  }

  Widget _statusBadge(
    BuildContext context,
    AttendanceOverviewItem item,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, item);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        _statusFor(item),
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  Widget _studentInfo(
    BuildContext context,
    AttendanceOverviewItem item,
  ) {
    final theme = Theme.of(context);

    final name = item.studentName.trim();
    String initials = '?';

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
              const SizedBox(height: 2),
              Text(
                item.rollNo.isEmpty
                    ? 'No roll number'
                    : item.rollNo,
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
    AttendanceOverviewItem item,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.subjectCode,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _attendanceBar(
    BuildContext context,
    AttendanceOverviewItem item,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, item);

    final progress =
        (item.percentage.clamp(0, 100) / 100).toDouble();

    return SizedBox(
      width: 165,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPercentage(item.percentage),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
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
    );
  }

  Widget _mobileCard(
    BuildContext context,
    AttendanceOverviewItem item,
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
                    item,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _subjectInfo(
                  context,
                  item,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _detailMetric(
                      context,
                      label: 'Present',
                      value: '${item.present}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _detailMetric(
                      context,
                      label: 'Absent',
                      value: '${item.absent}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _detailMetric(
                      context,
                      label: 'Total',
                      value: '${item.totalClasses}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _attendanceBar(
                context,
                item,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Minimum required: '
                  '${_formatPercentage(widget.minimumRequiredPercentage)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (widget.onEdit != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        widget.onEdit!(item),
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

  Widget _desktopTable(
    BuildContext context,
    List<AttendanceOverviewItem> records,
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
              label: Text('Semester'),
            ),
            DataColumn(
              label: Text('Present'),
            ),
            DataColumn(
              label: Text('Absent'),
            ),
            DataColumn(
              label: Text('Attendance'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: records.map((item) {
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
                  Text(
                    item.semester.toString(),
                  ),
                ),
                DataCell(
                  Text('${item.present}'),
                ),
                DataCell(
                  Text('${item.absent}'),
                ),
                DataCell(
                  _attendanceBar(
                    context,
                    item,
                  ),
                ),
                DataCell(
                  _statusBadge(
                    context,
                    item,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onView != null)
                        IconButton(
                          tooltip: 'View',
                          onPressed: () =>
                              widget.onView!(item),
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      if (widget.onEdit != null)
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              widget.onEdit!(item),
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
          }).toList(),
          columnSpacing: 24,
          horizontalMargin: 14,
          dataRowMinHeight: 68,
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
                        icon:
                            const Icon(Icons.close),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
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
                  value: 'Good',
                  child: Text('Good'),
                ),
                DropdownMenuItem(
                  value: 'Near Threshold',
                  child: Text('Near Threshold'),
                ),
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
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

            final semester =
                DropdownButtonFormField<String>(
              initialValue: _semesterFilter,
              decoration: const InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              items: _semesterOptions
                  .map(
                    (value) =>
                        DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'All'
                            ? 'All Semesters'
                            : 'Semester $value',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _semesterFilter = value;
                });
              },
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

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 10),
                      Expanded(child: semester),
                    ],
                  ),
                  const SizedBox(height: 10),
                  subject,
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
                SizedBox(
                  width: 160,
                  child: status,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 160,
                  child: semester,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: subject,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredRecords;

    final hasFilters =
        _query.isNotEmpty ||
        _statusFilter != 'All' ||
        _semesterFilter != 'All' ||
        _subjectFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_outlined
                  : Icons.fact_check_outlined,
              size: 48,
              color:
                  theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'No attendance records match your filters.'
                  : 'No attendance records available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try changing the search or filter options.'
                  : 'Attendance data will appear here once records are available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon:
                    const Icon(Icons.clear_all),
                label:
                    const Text('Clear Filters'),
              ),
            ],
            if (filtered.isEmpty &&
                widget.records.isNotEmpty &&
                hasFilters)
              const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = 'All';
      _semesterFilter = 'All';
      _subjectFilter = 'All';
    });
  }

  Widget _summaryStats(BuildContext context) {
    final theme = Theme.of(context);

    final records = _filteredRecords;

    final lowCount = records
        .where(
          (item) =>
              item.percentage <
              widget.minimumRequiredPercentage,
        )
        .length;

    final average = records.isEmpty
        ? 0.0
        : records
                .map((item) => item.percentage)
                .reduce((a, b) => a + b) /
            records.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 650 ? 2 : 4;

        final cards = [
          _stat(
            context,
            title: 'Records',
            value: '${records.length}',
            icon: Icons.fact_check_outlined,
            color: theme.colorScheme.primary,
          ),
          _stat(
            context,
            title: 'Average',
            value: _formatPercentage(average),
            icon: Icons.analytics_outlined,
            color: Colors.blue,
          ),
          _stat(
            context,
            title: 'Low Attendance',
            value: '$lowCount',
            icon: Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
          _stat(
            context,
            title: 'Threshold',
            value: _formatPercentage(
              widget.minimumRequiredPercentage,
            ),
            icon: Icons.flag_outlined,
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
            mainAxisExtent: 86,
          ),
          itemBuilder: (context, index) =>
              cards[index],
        );
      },
    );
  }

  Widget _stat(
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
                borderRadius: BorderRadius.circular(10),
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
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Overview'),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed:
                  widget.isLoading ? null : widget.onRefresh,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Overview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Monitor attendance across students, subjects and semesters.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
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
                          const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme
                            .colorScheme
                            .errorContainer
                            .withValues(alpha: 0.55),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.error
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                theme.colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.errorMessage!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _summaryStats(context),
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
                                builder:
                                    (context, constraints) {
                                  if (constraints.maxWidth <
                                      850) {
                                    return ListView.builder(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      itemCount:
                                          filtered.length,
                                      itemBuilder:
                                          (context, index) {
                                        return _mobileCard(
                                          context,
                                          filtered[index],
                                        );
                                      },
                                    );
                                  }

                                  return SingleChildScrollView(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 24,
                                    ),
                                    child: _desktopTable(
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

class AttendanceOverviewItem {
  final int id;
  final int? studentId;
  final String studentName;
  final String rollNo;
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final int semester;
  final int present;
  final int absent;
  final int totalClasses;
  final double percentage;
  final String? status;

  const AttendanceOverviewItem({
    required this.id,
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    this.subjectId,
    this.subjectName = '',
    this.subjectCode = '',
    this.semester = 0,
    this.present = 0,
    this.absent = 0,
    this.totalClasses = 0,
    this.percentage = 0,
    this.status,
  });
}