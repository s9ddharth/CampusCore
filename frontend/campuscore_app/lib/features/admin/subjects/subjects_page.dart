import 'package:flutter/material.dart';

class SubjectsPage extends StatefulWidget {
  final List<SubjectListItem> subjects;
  final List<SubjectDepartmentOption> departments;

  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onAddSubject;
  final void Function(SubjectListItem subject)? onViewSubject;
  final void Function(SubjectListItem subject)? onEditSubject;
  final void Function(SubjectListItem subject)? onDeleteSubject;
  final VoidCallback? onManageAssignments;

  const SubjectsPage({
    super.key,
    this.subjects = const [],
    this.departments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddSubject,
    this.onViewSubject,
    this.onEditSubject,
    this.onDeleteSubject,
    this.onManageAssignments,
  });

  @override
  State<SubjectsPage> createState() =>
      _SubjectsPageState();
}

class _SubjectsPageState
    extends State<SubjectsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _semesterFilter = 'ALL';
  String _departmentFilter = 'ALL';

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

  List<String> get _semesterOptions {
    final semesters = widget.subjects
        .map((subject) => subject.semester)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    return [
      'ALL',
      ...semesters.map(
        (semester) => semester.toString(),
      ),
    ];
  }

  List<SubjectListItem> get _filteredSubjects {
    final query =
        _searchQuery.toLowerCase();

    return widget.subjects.where(
      (subject) {
        final matchesSearch =
            query.isEmpty ||
                subject.code
                    .toLowerCase()
                    .contains(query) ||
                subject.name
                    .toLowerCase()
                    .contains(query) ||
                (subject.departmentName ?? '')
                    .toLowerCase()
                    .contains(query);

        final matchesSemester =
            _semesterFilter == 'ALL' ||
                subject.semester?.toString() ==
                    _semesterFilter;

        final matchesDepartment =
            _departmentFilter == 'ALL' ||
                subject.departmentId?.toString() ==
                    _departmentFilter;

        return matchesSearch &&
            matchesSemester &&
            matchesDepartment;
      },
    ).toList();
  }

  List<SubjectListItem> get _visibleSubjects {
    final filtered =
        _filteredSubjects;

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
    final count =
        _filteredSubjects.length;

    if (count == 0) {
      return 1;
    }

    return (count + _pageSize - 1) ~/
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
      _semesterFilter = 'ALL';
      _departmentFilter = 'ALL';
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

  Future<void> _confirmDelete(
    SubjectListItem subject,
  ) async {
    if (widget.onDeleteSubject == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme =
            Theme.of(dialogContext);

        return AlertDialog(
          title: const Text(
            'Delete Subject?',
          ),
          content: Text(
            'Delete ${subject.code} - ${subject.name}? '
            'This may affect related academic records and assignments.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.error,
                foregroundColor:
                    theme.colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDeleteSubject!(
        subject,
      );
    }
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

            final searchField =
                TextField(
              controller:
                  _searchController,
              enabled:
                  !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search by code, subject name or department',
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

            final semesterDropdown =
                DropdownButtonFormField<String>(
              initialValue:
                  _semesterOptions
                          .contains(
                _semesterFilter,
              )
                      ? _semesterFilter
                      : 'ALL',
              decoration:
                  const InputDecoration(
                labelText:
                    'Semester',
                prefixIcon:
                    Icon(
                  Icons.school_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: _semesterOptions
                  .map(
                    (semester) =>
                        DropdownMenuItem<String>(
                      value: semester,
                      child: Text(
                        semester == 'ALL'
                            ? 'All semesters'
                            : 'Semester $semester',
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  widget.isLoading
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _semesterFilter = value;
                            _currentPage = 1;
                          });
                        },
            );

            final departmentDropdown =
                DropdownButtonFormField<String>(
              initialValue:
                  _departmentFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Department',
                prefixIcon:
                    Icon(
                  Icons.account_tree_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: 'ALL',
                  child:
                      Text('All departments'),
                ),
                ...widget.departments.map(
                  (department) =>
                      DropdownMenuItem<String>(
                    value:
                        department.id.toString(),
                    child: Text(
                      department.name,
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
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _departmentFilter =
                                value;
                            _currentPage = 1;
                          });
                        },
            );

            final clearButton =
                OutlinedButton.icon(
              onPressed:
                  widget.isLoading
                      ? null
                      : _clearFilters,
              icon: const Icon(
                Icons.filter_alt_off_outlined,
              ),
              label: const Text(
                'Clear',
              ),
            );

            if (compact) {
              return Column(
                children: [
                  searchField,
                  const SizedBox(
                    height: 12,
                  ),
                  semesterDropdown,
                  const SizedBox(
                    height: 12,
                  ),
                  departmentDropdown,
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: clearButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: searchField,
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 190,
                  child: semesterDropdown,
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 230,
                  child:
                      departmentDropdown,
                ),
                const SizedBox(
                  width: 12,
                ),
                clearButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreditBadge(
    BuildContext context,
    dynamic credits,
  ) {
    final theme =
        Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: theme.colorScheme
            .secondaryContainer,
        borderRadius:
            BorderRadius.circular(
          999,
        ),
      ),
      child: Text(
        '$credits credits',
        style: theme
            .textTheme
            .labelSmall
            ?.copyWith(
          color: theme.colorScheme
              .onSecondaryContainer,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSemesterBadge(
    BuildContext context,
    int? semester,
  ) {
    final theme =
        Theme.of(context);

    if (semester == null) {
      return const Text('—');
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: theme.colorScheme
            .primaryContainer,
        borderRadius:
            BorderRadius.circular(
          999,
        ),
      ),
      child: Text(
        'Sem $semester',
        style: theme
            .textTheme
            .labelSmall
            ?.copyWith(
          color:
              theme.colorScheme.primary,
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

    if (_visibleSubjects.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 42,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No subjects found',
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
                  _searchQuery.isNotEmpty ||
                          _semesterFilter !=
                              'ALL' ||
                          _departmentFilter !=
                              'ALL'
                      ? 'Try changing the search or filters.'
                      : 'Create a subject to get started.',
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
                if (_searchQuery.isNotEmpty ||
                    _semesterFilter !=
                        'ALL' ||
                    _departmentFilter !=
                        'ALL') ...[
                  const SizedBox(
                    height: 14,
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        _clearFilters,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
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
                  Text('Subject'),
            ),
            DataColumn(
              label:
                  Text('Department'),
            ),
            DataColumn(
              label:
                  Text('Semester'),
            ),
            DataColumn(
              label:
                  Text('Credits'),
            ),
            DataColumn(
              label:
                  Text('Actions'),
            ),
          ],
          rows: _visibleSubjects
              .map(
                (subject) {
                  return DataRow(
                    onSelectChanged:
                        widget.onViewSubject ==
                                null
                            ? null
                            : (_) =>
                                widget
                                    .onViewSubject!(
                                  subject,
                                ),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 290,
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
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                                child:
                                    Icon(
                                  Icons
                                      .menu_book_outlined,
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
                                      subject
                                          .code,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      subject
                                          .name,
                                      maxLines:
                                          1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
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
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          subject
                                  .departmentName ??
                              'Not assigned',
                        ),
                      ),
                      DataCell(
                        _buildSemesterBadge(
                          context,
                          subject.semester,
                        ),
                      ),
                      DataCell(
                        _buildCreditBadge(
                          context,
                          subject.credits,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip:
                                  'View subject',
                              onPressed:
                                  widget
                                          .onViewSubject ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onViewSubject!(
                                            subject,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .visibility_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Edit subject',
                              onPressed:
                                  widget
                                          .onEditSubject ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onEditSubject!(
                                            subject,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .edit_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Delete subject',
                              onPressed:
                                  widget
                                          .onDeleteSubject ==
                                      null
                                      ? null
                                      : () =>
                                          _confirmDelete(
                                            subject,
                                          ),
                              icon:
                                  Icon(
                                Icons
                                    .delete_outline,
                                color: theme
                                    .colorScheme
                                    .error,
                              ),
                            ),
                          ],
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

  Widget _buildPagination(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final total =
        _filteredSubjects.length;

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
              ? '0 subjects'
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
          icon: const Icon(
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
          icon: const Icon(
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
            const Text('Subjects'),
        actions: [
          if (widget.onManageAssignments !=
              null)
            OutlinedButton.icon(
              onPressed:
                  widget
                      .onManageAssignments,
              icon: const Icon(
                Icons.link_outlined,
              ),
              label: const Text(
                'Assignments',
              ),
            ),
          const SizedBox(
            width: 8,
          ),
          IconButton(
            tooltip:
                'Refresh subjects',
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
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Subject Management',
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
                              '${widget.subjects.length} subject${widget.subjects.length == 1 ? '' : 's'}',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed:
                            widget
                                .onAddSubject,
                        icon: const Icon(
                          Icons
                              .add_circle_outline,
                        ),
                        label:
                            const Text(
                          'Add Subject',
                        ),
                      ),
                    ],
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

class SubjectListItem {
  final int id;
  final String code;
  final String name;
  final dynamic credits;
  final int? semester;
  final int? departmentId;
  final String? departmentName;

  const SubjectListItem({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.semester,
    this.departmentId,
    this.departmentName,
  });

  factory SubjectListItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final department =
        json['department'];

    return SubjectListItem(
      id: _toInt(json['id']) ?? 0,
      code:
          json['code']?.toString() ?? '',
      name:
          json['name']?.toString() ?? '',
      credits:
          json['credits'] ?? 0,
      semester:
          _toInt(json['semester']),
      departmentId:
          _toInt(
        json['department_id'],
      ),
      departmentName:
          department is Map
              ? department['name']
                  ?.toString()
              : json['department_name']
                  ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      'semester': semester,
      'department_id': departmentId,
      'department_name':
          departmentName,
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
}

class SubjectDepartmentOption {
  final int id;
  final String name;

  const SubjectDepartmentOption({
    required this.id,
    required this.name,
  });
}