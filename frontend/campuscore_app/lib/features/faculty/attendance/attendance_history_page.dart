import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final List<FacultyAttendanceHistoryItem> records;
  final List<FacultyAttendanceSubjectOption> subjects;
  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;

  final void Function(
    FacultyAttendanceHistoryItem record,
  )? onViewRecord;

  final VoidCallback? onBack;

  const AttendanceHistoryPage({
    super.key,
    this.records = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onViewRecord,
    this.onBack,
  });

  @override
  State<AttendanceHistoryPage> createState() =>
      _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState
    extends State<AttendanceHistoryPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _subjectFilter = 'ALL';
  String _statusFilter = 'ALL';

  DateTime? _fromDate;
  DateTime? _toDate;

  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _handleSearchChanged,
    );
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(
        _handleSearchChanged,
      )
      ..dispose();

    super.dispose();
  }

  void _handleSearchChanged() {
    final query =
        _searchController.text.trim();

    if (_searchQuery == query) {
      return;
    }

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  List<FacultyAttendanceHistoryItem>
      get _filteredRecords {
    final query =
        _searchQuery.toLowerCase();

    return widget.records.where(
      (record) {
        final matchesSearch =
            query.isEmpty ||
                record.studentName
                    .toLowerCase()
                    .contains(query) ||
                record.rollNo
                    .toLowerCase()
                    .contains(query) ||
                record.subjectName
                    .toLowerCase()
                    .contains(query) ||
                record.subjectCode
                    .toLowerCase()
                    .contains(query) ||
                record.sectionName
                    .toLowerCase()
                    .contains(query);

        final matchesSubject =
            _subjectFilter == 'ALL' ||
                record.subjectId.toString() ==
                    _subjectFilter;

        final matchesStatus =
            _statusFilter == 'ALL' ||
                record.status.toUpperCase() ==
                    _statusFilter;

        final matchesFromDate =
            _fromDate == null ||
                !_dateOnly(record.date)
                    .isBefore(
                  _dateOnly(_fromDate!),
                );

        final matchesToDate =
            _toDate == null ||
                !_dateOnly(record.date)
                    .isAfter(
                  _dateOnly(_toDate!),
                );

        return matchesSearch &&
            matchesSubject &&
            matchesStatus &&
            matchesFromDate &&
            matchesToDate;
      },
    ).toList();
  }

  List<FacultyAttendanceHistoryItem>
      get _visibleRecords {
    final filtered =
        _filteredRecords;

    final start =
        (_currentPage - 1) * _pageSize;

    if (start >= filtered.length) {
      return const [];
    }

    final end =
        (start + _pageSize)
            .clamp(
      0,
      filtered.length,
    );

    return filtered.sublist(
      start,
      end,
    );
  }

  int get _totalPages {
    final total =
        _filteredRecords.length;

    if (total == 0) {
      return 1;
    }

    return (total + _pageSize - 1) ~/
        _pageSize;
  }

  DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _changePage(
    int page,
  ) {
    if (page < 1 ||
        page > _totalPages ||
        page == _currentPage) {
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _subjectFilter = 'ALL';
      _statusFilter = 'ALL';
      _fromDate = null;
      _toDate = null;
      _currentPage = 1;
    });
  }

  Future<void> _refresh() async {
    if (widget.isLoading ||
        widget.onRefresh == null) {
      return;
    }

    await widget.onRefresh!();
  }

  Future<void> _pickFromDate() async {
    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          _fromDate ?? DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fromDate = picked;

      if (_toDate != null &&
          _dateOnly(_toDate!)
              .isBefore(
            _dateOnly(picked),
          )) {
        _toDate = picked;
      }

      _currentPage = 1;
    });
  }

  Future<void> _pickToDate() async {
    final initial =
        _toDate ??
            _fromDate ??
            DateTime.now();

    final picked =
        await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    if (_fromDate != null &&
        _dateOnly(picked)
            .isBefore(
          _dateOnly(_fromDate!),
        )) {
      _showMessage(
        'To date cannot be before from date.',
      );
      return;
    }

    setState(() {
      _toDate = picked;
      _currentPage = 1;
    });
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
        ),
      );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    final theme =
        Theme.of(context);

    return OutlinedButton.icon(
      onPressed:
          widget.isLoading
              ? null
              : onPressed,
      icon: Icon(icon),
      label: Text(
        value == null
            ? label
            : _formatDate(value),
      ),
      style:
          OutlinedButton.styleFrom(
        minimumSize:
            const Size(150, 48),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth <
                    950;

            final search =
                TextField(
              controller:
                  _searchController,
              enabled:
                  !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search student, roll number, subject or section',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip:
                                'Clear search',
                            onPressed: () {
                              _searchController
                                  .clear();
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          ),
                border:
                    const OutlineInputBorder(),
              ),
            );

            final subject =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _subjectFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Subject',
                prefixIcon:
                    Icon(
                  Icons
                      .menu_book_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'ALL',
                  child:
                      Text(
                    'All subjects',
                  ),
                ),
                ...widget.subjects.map(
                  (item) =>
                      DropdownMenuItem(
                    value:
                        item.id.toString(),
                    child:
                        Text(
                      '${item.code} - ${item.name}',
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged:
                  widget.isLoading
                      ? null
                      : (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            _subjectFilter =
                                value;
                            _currentPage =
                                1;
                          });
                        },
            );

            final status =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _statusFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Attendance',
                prefixIcon:
                    Icon(
                  Icons.fact_check_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ALL',
                  child:
                      Text(
                    'All statuses',
                  ),
                ),
                DropdownMenuItem(
                  value: 'PRESENT',
                  child:
                      Text(
                    'Present',
                  ),
                ),
                DropdownMenuItem(
                  value: 'ABSENT',
                  child:
                      Text(
                    'Absent',
                  ),
                ),
                DropdownMenuItem(
                  value: 'LATE',
                  child:
                      Text(
                    'Late',
                  ),
                ),
                DropdownMenuItem(
                  value: 'EXCUSED',
                  child:
                      Text(
                    'Excused',
                  ),
                ),
              ],
              onChanged:
                  widget.isLoading
                      ? null
                      : (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            _statusFilter =
                                value;
                            _currentPage =
                                1;
                          });
                        },
            );

            final fromDate =
                _buildDateButton(
              label: 'From date',
              value: _fromDate,
              onPressed:
                  _pickFromDate,
              icon: Icons
                  .calendar_today_outlined,
            );

            final toDate =
                _buildDateButton(
              label: 'To date',
              value: _toDate,
              onPressed:
                  _pickToDate,
              icon: Icons
                  .calendar_today_outlined,
            );

            final clear =
                OutlinedButton.icon(
              onPressed:
                  widget.isLoading
                      ? null
                      : _clearFilters,
              icon:
                  const Icon(
                Icons
                    .filter_alt_off_outlined,
              ),
              label:
                  const Text(
                'Clear',
              ),
            );

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(
                    height: 12,
                  ),
                  subject,
                  const SizedBox(
                    height: 12,
                  ),
                  status,
                  const SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      fromDate,
                      toDate,
                      clear,
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                search,
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: subject,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: status,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    fromDate,
                    const SizedBox(
                      width: 8,
                    ),
                    toDate,
                    const SizedBox(
                      width: 8,
                    ),
                    clear,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
  ) {
    final theme =
        Theme.of(context);

    final normalized =
        status.toUpperCase();

    final Color foreground;
    final Color background;

    switch (normalized) {
      case 'PRESENT':
        foreground =
            Colors.green.shade700;
        background =
            Colors.green.withValues(
          alpha: 0.10,
        );
        break;
      case 'ABSENT':
        foreground =
            theme.colorScheme.error;
        background =
            theme.colorScheme.errorContainer
                .withValues(
          alpha: 0.50,
        );
        break;
      case 'LATE':
        foreground =
            Colors.orange.shade800;
        background =
            Colors.orange.withValues(
          alpha: 0.10,
        );
        break;
      case 'EXCUSED':
        foreground =
            theme.colorScheme.primary;
        background =
            theme.colorScheme.primaryContainer;
        break;
      default:
        foreground = theme
            .colorScheme
            .onSurfaceVariant;
        background = theme.colorScheme
            .surfaceContainerHighest;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          999,
        ),
      ),
      child: Text(
        status,
        style: theme
            .textTheme
            .labelSmall
            ?.copyWith(
          color: foreground,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (_visibleRecords.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 44,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons
                      .history_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No attendance records found',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _hasActiveFilters
                      ? 'Try changing the search or filters.'
                      : 'Attendance history will appear here.',
                  textAlign:
                      TextAlign.center,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(
                    height: 14,
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        _clearFilters,
                    icon:
                        const Icon(
                      Icons.refresh,
                    ),
                    label:
                        const Text(
                      'Clear filters',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior:
          Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStatePropertyAll(
            theme.colorScheme
                .surfaceContainerHighest
                .withValues(
              alpha: 0.55,
            ),
          ),
          horizontalMargin: 18,
          columnSpacing: 28,
          columns: const [
            DataColumn(
              label:
                  Text('Date'),
            ),
            DataColumn(
              label:
                  Text('Student'),
            ),
            DataColumn(
              label:
                  Text('Subject'),
            ),
            DataColumn(
              label:
                  Text('Section'),
            ),
            DataColumn(
              label:
                  Text('Status'),
            ),
          ],
          rows: _visibleRecords
              .map(
                (record) {
                  return DataRow(
                    onSelectChanged:
                        widget.onViewRecord ==
                                null
                            ? null
                            : (_) =>
                                widget
                                    .onViewRecord!(
                                  record,
                                ),
                    cells: [
                      DataCell(
                        Text(
                          _formatDate(
                            record.date,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                record
                                    .studentName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              Text(
                                record.rollNo,
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                record
                                    .subjectName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                              Text(
                                record
                                    .subjectCode,
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          record
                              .sectionName,
                        ),
                      ),
                      DataCell(
                        _buildStatusBadge(
                          context,
                          record.status,
                        ),
                      ),
                    ],
                  );
                },
              )
              .toList(),
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _subjectFilter != 'ALL' ||
        _statusFilter != 'ALL' ||
        _fromDate != null ||
        _toDate != null;
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final records =
        _filteredRecords;

    final present = records
        .where(
          (record) =>
              record.status
                  .toUpperCase() ==
              'PRESENT',
        )
        .length;

    final absent = records
        .where(
          (record) =>
              record.status
                  .toUpperCase() ==
              'ABSENT',
        )
        .length;

    final late = records
        .where(
          (record) =>
              record.status
                  .toUpperCase() ==
              'LATE',
        )
        .length;

    final attendancePercentage =
        records.isEmpty
            ? 0.0
            : ((present + late) /
                    records.length) *
                100;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth < 700;

        final cards = [
          _buildSummaryCard(
            context,
            title: 'Total',
            value:
                records.length.toString(),
            icon:
                Icons.fact_check_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Present',
            value:
                present.toString(),
            icon:
                Icons.check_circle_outline,
          ),
          _buildSummaryCard(
            context,
            title: 'Absent',
            value:
                absent.toString(),
            icon:
                Icons.cancel_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Late',
            value:
                late.toString(),
            icon:
                Icons.schedule_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Attendance',
            value:
                '${attendancePercentage.toStringAsFixed(1)}%',
            icon:
                Icons.percent_outlined,
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map(
                  (card) =>
                      SizedBox(
                    width:
                        (constraints.maxWidth -
                                10) /
                            2,
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            for (var i = 0;
                i < cards.length;
                i++) ...[
              Expanded(
                child: cards[i],
              ),
              if (i < cards.length - 1)
                const SizedBox(
                  width: 10,
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color: theme.colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme
                    .primary,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    value,
                    style: theme
                        .textTheme
                        .titleMedium
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

  Widget _buildPagination(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final total =
        _filteredRecords.length;

    final start =
        total == 0
            ? 0
            : ((_currentPage - 1) *
                    _pageSize) +
                1;

    final end =
        total == 0
            ? 0
            : (_currentPage * _pageSize)
                .clamp(
                0,
                total,
              );

    return Row(
      children: [
        Text(
          total == 0
              ? '0 records'
              : '$start-$end of $total',
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip:
              'Previous page',
          onPressed:
              _currentPage > 1
                  ? () => _changePage(
                        _currentPage - 1,
                      )
                  : null,
          icon:
              const Icon(
            Icons.chevron_left,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration:
              BoxDecoration(
            color: theme.colorScheme
                .primaryContainer,
            borderRadius:
                BorderRadius.circular(
              8,
            ),
          ),
          child: Text(
            '$_currentPage / $_totalPages',
            style: theme.textTheme
                .labelMedium
                ?.copyWith(
              color: theme.colorScheme
                  .primary,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip:
              'Next page',
          onPressed:
              _currentPage <
                      _totalPages
                  ? () => _changePage(
                        _currentPage + 1,
                      )
                  : null,
          icon:
              const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance History',
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed:
              widget.onBack ??
                  () =>
                      Navigator.of(
                        context,
                      ).maybePop(),
          icon:
              const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh attendance',
            onPressed:
                widget.isLoading
                    ? null
                    : _refresh,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                  ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Attendance History',
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Review historical attendance records for your assigned classes.',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildSummary(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildFilters(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (widget.errorMessage !=
                      null) ...[
                    _buildError(
                      context,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                  _buildTable(
                    context,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildPagination(
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Icon(
              Icons.error_outline,
              color:
                  theme.colorScheme.error,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            OutlinedButton(
              onPressed: _refresh,
              child:
                  const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacultyAttendanceHistoryItem {
  final int id;
  final int studentId;
  final int subjectId;

  final DateTime date;
  final String status;

  final String studentName;
  final String rollNo;

  final String subjectName;
  final String subjectCode;

  final String sectionName;

  final int? markedBy;

  const FacultyAttendanceHistoryItem({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.status,
    required this.studentName,
    required this.rollNo,
    required this.subjectName,
    required this.subjectCode,
    required this.sectionName,
    this.markedBy,
  });

  factory FacultyAttendanceHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final student =
        json['student'];

    final subject =
        json['subject'];

    final section =
        json['section'];

    return FacultyAttendanceHistoryItem(
      id:
          _toInt(json['id']) ?? 0,
      studentId:
          _toInt(json['student_id']) ??
              0,
      subjectId:
          _toInt(json['subject_id']) ??
              0,
      date:
          _toDate(json['date']) ??
              DateTime.now(),
      status:
          json['status']?.toString() ??
              'UNKNOWN',
      studentName:
          student is Map
              ? student['name']
                      ?.toString() ??
                  ''
              : json['student_name']
                      ?.toString() ??
                  '',
      rollNo:
          student is Map
              ? student['roll_no']
                      ?.toString() ??
                  ''
              : json['roll_no']
                      ?.toString() ??
                  '',
      subjectName:
          subject is Map
              ? subject['name']
                      ?.toString() ??
                  ''
              : json['subject_name']
                      ?.toString() ??
                  '',
      subjectCode:
          subject is Map
              ? subject['code']
                      ?.toString() ??
                  ''
              : json['subject_code']
                      ?.toString() ??
                  '',
      sectionName:
          section is Map
              ? section['name']
                      ?.toString() ??
                  ''
              : json['section_name']
                      ?.toString() ??
                  '',
      markedBy:
          _toInt(
        json['marked_by'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'date': date.toIso8601String(),
      'status': status,
      'student_name': studentName,
      'roll_no': rollNo,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'section_name': sectionName,
      'marked_by': markedBy,
    };
  }

  static int? _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static DateTime? _toDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}

class FacultyAttendanceSubjectOption {
  final int id;
  final String code;
  final String name;

  const FacultyAttendanceSubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });
}