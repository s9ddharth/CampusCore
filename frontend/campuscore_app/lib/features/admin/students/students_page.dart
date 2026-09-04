import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  final List<StudentListItem> students;
  final List<StudentDepartmentFilter> departments;
  final List<StudentSectionFilter> sections;

  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onAddStudent;
  final void Function(StudentListItem student)? onViewStudent;
  final void Function(StudentListItem student)? onEditStudent;
  final void Function(StudentListItem student)? onDeleteStudent;

  const StudentsPage({
    super.key,
    this.students = const [],
    this.departments = const [],
    this.sections = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddStudent,
    this.onViewStudent,
    this.onEditStudent,
    this.onDeleteStudent,
  });

  @override
  State<StudentsPage> createState() =>
      _StudentsPageState();
}

class _StudentsPageState
    extends State<StudentsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _semesterFilter = 'ALL';
  String _departmentFilter = 'ALL';
  String _sectionFilter = 'ALL';

  int _currentPage = 1;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(
        _onSearchChanged,
      )
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
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
    final values = widget.students
        .map(
          (student) =>
              student.semester,
        )
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    return [
      'ALL',
      ...values.map(
        (value) => value.toString(),
      ),
    ];
  }

  List<StudentSectionFilter>
      get _filteredSectionsForDropdown {
    if (_departmentFilter == 'ALL') {
      return widget.sections;
    }

    final departmentId =
        int.tryParse(
      _departmentFilter,
    );

    if (departmentId == null) {
      return widget.sections;
    }

    return widget.sections
        .where(
          (section) =>
              section.departmentId ==
                  null ||
              section.departmentId ==
                  departmentId,
        )
        .toList();
  }

  List<StudentListItem>
      get _filteredStudents {
    final query =
        _searchQuery.toLowerCase();

    return widget.students.where(
      (student) {
        final matchesSearch =
            query.isEmpty ||
                student.rollNo
                    .toLowerCase()
                    .contains(query) ||
                student.name
                    .toLowerCase()
                    .contains(query) ||
                student.email
                    .toLowerCase()
                    .contains(query) ||
                (student.departmentName ??
                        '')
                    .toLowerCase()
                    .contains(query) ||
                (student.sectionName ??
                        '')
                    .toLowerCase()
                    .contains(query);

        final matchesStatus =
            _statusFilter == 'ALL' ||
                student.status.toUpperCase() ==
                    _statusFilter;

        final matchesSemester =
            _semesterFilter == 'ALL' ||
                student.semester?.toString() ==
                    _semesterFilter;

        final matchesDepartment =
            _departmentFilter == 'ALL' ||
                student.departmentId
                        ?.toString() ==
                    _departmentFilter;

        final matchesSection =
            _sectionFilter == 'ALL' ||
                student.sectionId?.toString() ==
                    _sectionFilter;

        return matchesSearch &&
            matchesStatus &&
            matchesSemester &&
            matchesDepartment &&
            matchesSection;
      },
    ).toList();
  }

  List<StudentListItem>
      get _visibleStudents {
    final filtered =
        _filteredStudents;

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
        _filteredStudents.length;

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
      _statusFilter = 'ALL';
      _semesterFilter = 'ALL';
      _departmentFilter = 'ALL';
      _sectionFilter = 'ALL';
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
    StudentListItem student,
  ) async {
    if (widget.onDeleteStudent == null) {
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
            'Delete Student?',
          ),
          content: Text(
            'Delete the student record for ${student.name} '
            '(${student.rollNo})?',
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
      widget.onDeleteStudent!(
        student,
      );
    }
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
  ) {
    final theme =
        Theme.of(context);

    final isActive =
        status.toUpperCase() ==
            'ACTIVE';

    final foreground = isActive
        ? Colors.green.shade700
        : theme.colorScheme
            .onSurfaceVariant;

    final background = isActive
        ? Colors.green.withValues(
            alpha: 0.10,
          )
        : theme.colorScheme
            .surfaceContainerHighest;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
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
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            status,
            style: theme.textTheme
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

  Widget _buildFilterCard(
    BuildContext context,
  ) {
    final sectionOptions =
        _filteredSectionsForDropdown;

    final sectionValue =
        sectionOptions.any(
      (section) =>
          section.id.toString() ==
          _sectionFilter,
    )
            ? _sectionFilter
            : 'ALL';

    if (sectionValue !=
        _sectionFilter) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _sectionFilter = 'ALL';
          _currentPage = 1;
        });
      });
    }

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
                constraints.maxWidth < 950;

            final searchField =
                TextField(
              controller:
                  _searchController,
              enabled:
                  !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search name, roll number, email, department or section',
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

            final statusDropdown =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _statusFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Status',
                prefixIcon:
                    Icon(
                  Icons
                      .toggle_on_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ALL',
                  child: Text(
                    'All statuses',
                  ),
                ),
                DropdownMenuItem(
                  value: 'ACTIVE',
                  child: Text(
                    'Active',
                  ),
                ),
                DropdownMenuItem(
                  value: 'INACTIVE',
                  child: Text(
                    'Inactive',
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
                            _currentPage = 1;
                          });
                        },
            );

            final semesterDropdown =
                DropdownButtonFormField<
                    String>(
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
                        DropdownMenuItem<
                            String>(
                      value:
                          semester,
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
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            _semesterFilter =
                                value;
                            _currentPage = 1;
                          });
                        },
            );

            final departmentDropdown =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _departmentFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Department',
                prefixIcon:
                    Icon(
                  Icons
                      .account_tree_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<
                    String>(
                  value: 'ALL',
                  child: Text(
                    'All departments',
                  ),
                ),
                ...widget.departments
                    .map(
                  (
                    department,
                  ) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        department.id
                            .toString(),
                    child:
                        Text(
                      department.name,
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
                            _departmentFilter =
                                value;
                            _sectionFilter =
                                'ALL';
                            _currentPage = 1;
                          });
                        },
            );

            final sectionDropdown =
                DropdownButtonFormField<
                    String>(
              initialValue:
                  sectionValue,
              decoration:
                  const InputDecoration(
                labelText:
                    'Section',
                prefixIcon:
                    Icon(
                  Icons.groups_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<
                    String>(
                  value: 'ALL',
                  child: Text(
                    'All sections',
                  ),
                ),
                ...sectionOptions.map(
                  (
                    section,
                  ) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        section.id
                            .toString(),
                    child:
                        Text(
                      section
                          .displayName,
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
                            _sectionFilter =
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
                  searchField,
                  const SizedBox(
                    height: 12,
                  ),
                  statusDropdown,
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
                  sectionDropdown,
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child:
                        clearButton,
                  ),
                ],
              );
            }

            return Column(
              children: [
                searchField,
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          statusDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          semesterDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          departmentDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          sectionDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    clearButton,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final hasFilters =
        _searchQuery.isNotEmpty ||
            _statusFilter != 'ALL' ||
            _semesterFilter != 'ALL' ||
            _departmentFilter != 'ALL' ||
            _sectionFilter != 'ALL';

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
                hasFilters
                    ? Icons
                        .person_search_outlined
                    : Icons
                        .people_outline,
                size: 54,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                hasFilters
                    ? 'No students match the current filters'
                    : 'No students found',
                textAlign:
                    TextAlign.center,
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
                hasFilters
                    ? 'Try changing the search or filters.'
                    : 'Student records will appear here.',
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
              if (hasFilters) ...[
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

  Widget _buildTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (_visibleStudents.isEmpty) {
      return _buildEmptyState(
        context,
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
          columnSpacing: 26,
          columns: const [
            DataColumn(
              label:
                  Text('Student'),
            ),
            DataColumn(
              label:
                  Text('Roll Number'),
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
                  Text('Section'),
            ),
            DataColumn(
              label:
                  Text('Status'),
            ),
            DataColumn(
              label:
                  Text('Actions'),
            ),
          ],
          rows: _visibleStudents
              .map(
                (student) {
                  final initials =
                      student.name
                          .trim()
                          .split(
                            RegExp(
                              r'\s+',
                            ),
                          )
                          .where(
                            (part) =>
                                part
                                    .isNotEmpty,
                          )
                          .take(2)
                          .map(
                            (part) =>
                                part[0]
                                    .toUpperCase(),
                          )
                          .join();

                  return DataRow(
                    onSelectChanged:
                        widget.onViewStudent ==
                                null
                            ? null
                            : (_) =>
                                widget
                                    .onViewStudent!(
                                  student,
                                ),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 235,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    theme
                                        .colorScheme
                                        .primaryContainer,
                                child:
                                    Text(
                                  initials
                                          .isEmpty
                                      ? '?'
                                      : initials,
                                  style: theme
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .primary,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
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
                                      student
                                          .name,
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
                                      student
                                          .email,
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
                          student.rollNo,
                        ),
                      ),
                      DataCell(
                        Text(
                          student
                                  .departmentName ??
                              'Not assigned',
                        ),
                      ),
                      DataCell(
                        Text(
                          student.semester ==
                                  null
                              ? '—'
                              : student
                                  .semester
                                  .toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          student.sectionName ??
                              'Not assigned',
                        ),
                      ),
                      DataCell(
                        _buildStatusBadge(
                          context,
                          student.status,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            IconButton(
                              tooltip:
                                  'View student',
                              onPressed:
                                  widget
                                          .onViewStudent ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onViewStudent!(
                                            student,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .visibility_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Edit student',
                              onPressed:
                                  widget
                                          .onEditStudent ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onEditStudent!(
                                            student,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .edit_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Delete student',
                              onPressed:
                                  widget
                                          .onDeleteStudent ==
                                      null
                                      ? null
                                      : () =>
                                          _confirmDelete(
                                            student,
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
        _filteredStudents.length;

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
              ? '0 students'
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
              color: theme
                  .colorScheme
                  .error,
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
          'Students',
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh students',
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
                              'Student Management',
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
                              '${widget.students.length} student${widget.students.length == 1 ? '' : 's'}',
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
                                .onAddStudent,
                        icon:
                            const Icon(
                          Icons
                              .person_add_alt_1_outlined,
                        ),
                        label:
                            const Text(
                          'Add Student',
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
                  _buildFilterCard(
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

class StudentListItem {
  final int id;
  final int? userId;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int? semester;
  final int? departmentId;
  final String? departmentName;
  final int? sectionId;
  final String? sectionName;
  final String status;

  const StudentListItem({
    required this.id,
    this.userId,
    required this.rollNo,
    required this.name,
    this.dob,
    this.phone,
    required this.email,
    this.semester,
    this.departmentId,
    this.departmentName,
    this.sectionId,
    this.sectionName,
    this.status = 'ACTIVE',
  });

  factory StudentListItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final department =
        json['department'];

    final section =
        json['section'];

    return StudentListItem(
      id: _toInt(json['id']) ?? 0,
      userId:
          _toInt(json['user_id']),
      rollNo:
          json['roll_no']?.toString() ??
              '',
      name:
          json['name']?.toString() ??
              '',
      dob:
          _toDate(json['dob']),
      phone:
          json['phone']?.toString(),
      email:
          json['email']?.toString() ??
              '',
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
      sectionId:
          _toInt(
        json['section_id'],
      ),
      sectionName:
          section is Map
              ? section['name']
                  ?.toString()
              : json['section_name']
                  ?.toString(),
      status:
          json['status']?.toString() ??
              'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'roll_no': rollNo,
      'name': name,
      'dob': dob?.toIso8601String(),
      'phone': phone,
      'email': email,
      'semester': semester,
      'department_id': departmentId,
      'department_name':
          departmentName,
      'section_id': sectionId,
      'section_name':
          sectionName,
      'status': status,
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

class StudentDepartmentFilter {
  final int id;
  final String name;

  const StudentDepartmentFilter({
    required this.id,
    required this.name,
  });
}

class StudentSectionFilter {
  final int id;
  final String name;
  final int? semester;
  final int? departmentId;
  final String? academicYear;

  const StudentSectionFilter({
    required this.id,
    required this.name,
    this.semester,
    this.departmentId,
    this.academicYear,
  });

  String get displayName {
    final parts = <String>[name];

    if (semester != null) {
      parts.add(
        'Sem $semester',
      );
    }

    if (academicYear != null &&
        academicYear!
            .trim()
            .isNotEmpty) {
      parts.add(
        academicYear!,
      );
    }

    return parts.join(' • ');
  }
}