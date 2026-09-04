import 'package:flutter/material.dart';

class MarksHistoryPage extends StatefulWidget {
  final List<MarksHistoryItem> records;
  final List<MarksHistorySubjectOption> subjects;
  final List<MarksHistoryAssessmentOption> assessments;

  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;

  final void Function(
    MarksHistoryItem record,
  )? onViewRecord;

  final VoidCallback? onBack;

  const MarksHistoryPage({
    super.key,
    this.records = const [],
    this.subjects = const [],
    this.assessments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onViewRecord,
    this.onBack,
  });

  @override
  State<MarksHistoryPage> createState() =>
      _MarksHistoryPageState();
}

class _MarksHistoryPageState
    extends State<MarksHistoryPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _subjectFilter = 'ALL';
  String _assessmentFilter = 'ALL';

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

  List<MarksHistoryItem> get _filteredRecords {
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
                record.assessmentName
                    .toLowerCase()
                    .contains(query) ||
                (record.sectionName ?? '')
                    .toLowerCase()
                    .contains(query);

        final matchesSubject =
            _subjectFilter == 'ALL' ||
                record.subjectId.toString() ==
                    _subjectFilter;

        final matchesAssessment =
            _assessmentFilter == 'ALL' ||
                record.assessmentId.toString() ==
                    _assessmentFilter;

        return matchesSearch &&
            matchesSubject &&
            matchesAssessment;
      },
    ).toList();
  }

  List<MarksHistoryItem> get _visibleRecords {
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
      _assessmentFilter = 'ALL';
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

  String _formatMarks(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
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
                constraints.maxWidth < 850;

            final search =
                TextField(
              controller:
                  _searchController,
              enabled:
                  !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search student, roll number, subject or assessment',
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
                const DropdownMenuItem<
                    String>(
                  value: 'ALL',
                  child:
                      Text('All subjects'),
                ),
                ...widget.subjects.map(
                  (item) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        item.id.toString(),
                    child:
                        Text(
                      '${item.code} - ${item.name}',
                      overflow:
                          TextOverflow
                              .ellipsis,
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
                            _currentPage = 1;
                          });
                        },
            );

            final assessment =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _assessmentFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Assessment',
                prefixIcon:
                    Icon(
                  Icons
                      .assignment_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<
                    String>(
                  value: 'ALL',
                  child:
                      Text('All assessments'),
                ),
                ...widget.assessments.map(
                  (item) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        item.id.toString(),
                    child:
                        Text(
                      item.name,
                      overflow:
                          TextOverflow
                              .ellipsis,
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
                            _assessmentFilter =
                                value;
                            _currentPage = 1;
                          });
                        },
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
                  const Text('Clear'),
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
                  assessment,
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child:
                        clear,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: search,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: subject,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: assessment,
                ),
                const SizedBox(
                  width: 12,
                ),
                clear,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarksBadge(
    BuildContext context,
    MarksHistoryItem record,
  ) {
    final theme =
        Theme.of(context);

    final percentage =
        record.maxMarks <= 0
            ? 0.0
            : (record.marks /
                    record.maxMarks) *
                100;

    final Color foreground;
    final Color background;

    if (percentage >= 75) {
      foreground =
          Colors.green.shade700;
      background =
          Colors.green.withValues(
        alpha: 0.10,
      );
    } else if (percentage >= 40) {
      foreground =
          Colors.orange.shade800;
      background =
          Colors.orange.withValues(
        alpha: 0.10,
      );
    } else {
      foreground =
          theme.colorScheme.error;
      background =
          theme.colorScheme.errorContainer
              .withValues(
        alpha: 0.55,
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
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
        '${_formatMarks(record.marks)} / ${_formatMarks(record.maxMarks)}',
        style: theme
            .textTheme
            .labelMedium
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
                      .history_edu_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No marks history found',
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
                      : 'Your marks submissions will appear here.',
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
                  Text('Student'),
            ),
            DataColumn(
              label:
                  Text('Subject'),
            ),
            DataColumn(
              label:
                  Text('Assessment'),
            ),
            DataColumn(
              label:
                  Text('Section'),
            ),
            DataColumn(
              label:
                  Text('Marks'),
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
                        widget
                                    .onViewRecord ==
                                null
                            ? null
                            : (_) =>
                                widget
                                    .onViewRecord!(
                                  record,
                                ),
                    cells: [
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
                          child:
                              Column(
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
                                record.subjectCode,
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
                              .assessmentName,
                        ),
                      ),
                      DataCell(
                        Text(
                          record
                                  .sectionName ??
                              '—',
                        ),
                      ),
                      DataCell(
                        _buildMarksBadge(
                          context,
                          record,
                        ),
                      ),
                      DataCell(
                        _buildLockBadge(
                          context,
                          record.locked,
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

  Widget _buildLockBadge(
    BuildContext context,
    bool locked,
  ) {
    final theme =
        Theme.of(context);

    final foreground = locked
        ? theme.colorScheme.primary
        : Colors.orange.shade800;

    final background = locked
        ? theme.colorScheme.primaryContainer
        : Colors.orange.withValues(
            alpha: 0.10,
          );

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
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            locked
                ? Icons.lock_outline
                : Icons.lock_open_outlined,
            size: 14,
            color: foreground,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            locked ? 'Locked' : 'Editable',
            style: theme
                .textTheme
                .labelSmall
                ?.copyWith(
              color: foreground,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _subjectFilter != 'ALL' ||
        _assessmentFilter != 'ALL';
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final records =
        _filteredRecords;

    final locked = records
        .where(
          (record) => record.locked,
        )
        .length;

    final editable = records.length -
        locked;

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
            title: 'Records',
            value:
                records.length.toString(),
            icon:
                Icons.history_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Locked',
            value:
                locked.toString(),
            icon:
                Icons.lock_outline,
          ),
          _buildSummaryCard(
            context,
            title: 'Editable',
            value:
                editable.toString(),
            icon:
                Icons.edit_outlined,
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map(
                  (card) => SizedBox(
                    width:
                        (constraints.maxWidth - 10) /
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
            const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                BorderRadius.circular(8),
          ),
          child: Text(
            '$_currentPage / $_totalPages',
            style: theme
                .textTheme
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Marks History',
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
                'Refresh marks',
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
                    'Marks History',
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
                    'Review marks entered for your assigned subjects and assessments.',
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
                  if (widget.errorMessage !=
                      null) ...[
                    _buildError(
                      context,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
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
}

class MarksHistoryItem {
  final int id;
  final int studentId;
  final int subjectId;
  final int assessmentId;

  final String studentName;
  final String rollNo;

  final String subjectName;
  final String subjectCode;

  final String assessmentName;
  final String? sectionName;

  final double marks;
  final double maxMarks;

  final bool locked;

  const MarksHistoryItem({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.assessmentId,
    required this.studentName,
    required this.rollNo,
    required this.subjectName,
    required this.subjectCode,
    required this.assessmentName,
    this.sectionName,
    required this.marks,
    required this.maxMarks,
    this.locked = false,
  });

  factory MarksHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final student =
        json['student'];

    final subject =
        json['subject'];

    final assessment =
        json['assessment'];

    final section =
        json['section'];

    return MarksHistoryItem(
      id:
          _toInt(json['id']) ?? 0,
      studentId:
          _toInt(
                json['student_id'],
              ) ??
              (student is Map
                  ? _toInt(student['id']) ?? 0
                  : 0),
      subjectId:
          _toInt(
                json['subject_id'],
              ) ??
              (subject is Map
                  ? _toInt(subject['id']) ?? 0
                  : 0),
      assessmentId:
          _toInt(
                json['assessment_id'],
              ) ??
              (assessment is Map
                  ? _toInt(assessment['id']) ??
                      0
                  : 0),
      studentName:
          student is Map
              ? student['name']?.toString() ??
                  ''
              : json['student_name']?.toString() ??
                  '',
      rollNo:
          student is Map
              ? student['roll_no']?.toString() ??
                  ''
              : json['roll_no']?.toString() ??
                  '',
      subjectName:
          subject is Map
              ? subject['name']?.toString() ??
                  ''
              : json['subject_name']?.toString() ??
                  '',
      subjectCode:
          subject is Map
              ? subject['code']?.toString() ??
                  ''
              : json['subject_code']?.toString() ??
                  '',
      assessmentName:
          assessment is Map
              ? assessment['name']?.toString() ??
                  ''
              : json['assessment_name']?.toString() ??
                  '',
      sectionName:
          section is Map
              ? section['name']?.toString()
              : json['section_name']?.toString(),
      marks:
          _toDouble(
                json['marks'],
              ) ??
              0,
      maxMarks:
          _toDouble(
                json['max_marks'],
              ) ??
              (assessment is Map
                  ? _toDouble(
                        assessment['max_marks'],
                      ) ??
                      0
                  : 0),
      locked:
          json['locked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'assessment_id': assessmentId,
      'student_name': studentName,
      'roll_no': rollNo,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'assessment_name': assessmentName,
      'section_name': sectionName,
      'marks': marks,
      'max_marks': maxMarks,
      'locked': locked,
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

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}

class MarksHistorySubjectOption {
  final int id;
  final String code;
  final String name;

  const MarksHistorySubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });
}

class MarksHistoryAssessmentOption {
  final int id;
  final String name;

  const MarksHistoryAssessmentOption({
    required this.id,
    required this.name,
  });
}