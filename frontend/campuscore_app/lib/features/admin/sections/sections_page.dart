import 'package:flutter/material.dart';

class SectionsPage extends StatefulWidget {
  final List<SectionListItem> sections;
  final List<SectionDepartmentOption> departments;
  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onAddSection;
  final void Function(SectionListItem section)? onViewSection;
  final void Function(SectionListItem section)? onEditSection;
  final void Function(SectionListItem section)? onDeleteSection;

  const SectionsPage({
    super.key,
    this.sections = const [],
    this.departments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddSection,
    this.onViewSection,
    this.onEditSection,
    this.onDeleteSection,
  });

  @override
  State<SectionsPage> createState() =>
      _SectionsPageState();
}

class _SectionsPageState
    extends State<SectionsPage> {
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

    if (query == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  List<String> get _semesterOptions {
    final semesters = widget.sections
        .map((section) => section.semester)
        .toSet()
        .toList()
      ..sort();

    return ['ALL', ...semesters];
  }

  List<SectionListItem> get _filteredSections {
    final query =
        _searchQuery.toLowerCase();

    return widget.sections.where(
      (section) {
        final matchesSearch =
            query.isEmpty ||
                section.name
                    .toLowerCase()
                    .contains(query) ||
                section.departmentName
                    .toLowerCase()
                    .contains(query) ||
                section.academicYear
                    .toLowerCase()
                    .contains(query);

        final matchesSemester =
            _semesterFilter == 'ALL' ||
                section.semester ==
                    _semesterFilter;

        final matchesDepartment =
            _departmentFilter == 'ALL' ||
                section.departmentId
                        ?.toString() ==
                    _departmentFilter;

        return matchesSearch &&
            matchesSemester &&
            matchesDepartment;
      },
    ).toList();
  }

  List<SectionListItem> get _visibleSections {
    final filtered = _filteredSections;

    final start =
        (_currentPage - 1) * _pageSize;

    if (start >= filtered.length) {
      return const [];
    }

    final end = (start + _pageSize)
        .clamp(0, filtered.length);

    return filtered.sublist(
      start,
      end,
    );
  }

  int get _totalPages {
    final count =
        _filteredSections.length;

    if (count == 0) {
      return 1;
    }

    return (count + _pageSize - 1) ~/
        _pageSize;
  }

  void _changePage(int page) {
    if (page < 1 ||
        page > _totalPages ||
        page == _currentPage) {
      return;
    }

    setState(() {
      _currentPage = page;
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
    SectionListItem section,
  ) async {
    if (widget.onDeleteSection == null) {
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
            'Delete Section?',
          ),
          content: Text(
            'Delete section "${section.name}" for '
            '${section.academicYear}, Semester ${section.semester}?',
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
      widget.onDeleteSection!(
        section,
      );
    }
  }

  Widget _buildSearchAndFilters(
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
                constraints.maxWidth < 750;

            final searchField =
                TextField(
              controller:
                  _searchController,
              enabled: !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search sections, department or academic year',
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
                  Icons
                      .school_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: _semesterOptions
                  .map(
                    (semester) {
                      return DropdownMenuItem<
                          String>(
                        value: semester,
                        child: Text(
                          semester == 'ALL'
                              ? 'All semesters'
                              : 'Semester $semester',
                        ),
                      );
                    },
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
                ...widget.departments.map(
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
                            _currentPage = 1;
                          });
                        },
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
                  child:
                      semesterDropdown,
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 230,
                  child:
                      departmentDropdown,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    SectionListItem section,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: InkWell(
        onTap:
            widget.onViewSection == null
                ? null
                : () =>
                    widget.onViewSection!(
                      section,
                    ),
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color: theme
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons.groups_outlined,
                  color: theme
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      section.name,
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      section.departmentName,
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
              _buildSemesterBadge(
                context,
                section.semester,
              ),
              const SizedBox(
                width: 8,
              ),
              PopupMenuButton<String>(
                tooltip:
                    'Section actions',
                onSelected:
                    (action) {
                  switch (action) {
                    case 'view':
                      widget
                          .onViewSection
                          ?.call(section);
                      break;
                    case 'edit':
                      widget
                          .onEditSection
                          ?.call(section);
                      break;
                    case 'delete':
                      _confirmDelete(
                        section,
                      );
                      break;
                  }
                },
                itemBuilder:
                    (context) =>
                        const [
                  PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          Icon(
                        Icons
                            .visibility_outlined,
                      ),
                      title:
                          Text(
                        'View',
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          Icon(
                        Icons
                            .edit_outlined,
                      ),
                      title:
                          Text(
                        'Edit',
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          Icon(
                        Icons
                            .delete_outline,
                      ),
                      title:
                          Text(
                        'Delete',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterBadge(
    BuildContext context,
    String semester,
  ) {
    final theme =
        Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
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
        'Sem $semester',
        style: theme
            .textTheme
            .labelMedium
            ?.copyWith(
          color: theme.colorScheme
              .onSecondaryContainer,
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

    if (_visibleSections.isEmpty) {
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
                  Icons
                      .groups_2_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No sections found',
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
                  _searchQuery
                              .isNotEmpty ||
                          _semesterFilter !=
                              'ALL' ||
                          _departmentFilter !=
                              'ALL'
                      ? 'Try changing the search or filters.'
                      : 'Create a section to get started.',
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
                if (_searchQuery
                            .isNotEmpty ||
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
                    icon:
                        const Icon(
                      Icons
                          .filter_alt_off_outlined,
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
          columnSpacing: 30,
          columns: const [
            DataColumn(
              label:
                  Text('Section'),
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
                  Text('Academic Year'),
            ),
            DataColumn(
              label:
                  Text('Students'),
            ),
            DataColumn(
              label:
                  Text('Actions'),
            ),
          ],
          rows: _visibleSections
              .map(
                (section) {
                  return DataRow(
                    onSelectChanged:
                        widget
                                    .onViewSection ==
                                null
                            ? null
                            : (_) =>
                                widget
                                    .onViewSection!(
                                  section,
                                ),
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .class_outlined,
                              size: 20,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Text(
                              section.name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          section
                              .departmentName,
                        ),
                      ),
                      DataCell(
                        _buildSemesterBadge(
                          context,
                          section
                              .semester,
                        ),
                      ),
                      DataCell(
                        Text(
                          section
                              .academicYear,
                        ),
                      ),
                      DataCell(
                        Text(
                          '${section.studentCount}',
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip:
                                  'View section',
                              onPressed:
                                  widget
                                          .onViewSection ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onViewSection!(
                                            section,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .visibility_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Edit section',
                              onPressed:
                                  widget
                                          .onEditSection ==
                                      null
                                      ? null
                                      : () =>
                                          widget
                                              .onEditSection!(
                                            section,
                                          ),
                              icon:
                                  const Icon(
                                Icons
                                    .edit_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  'Delete section',
                              onPressed:
                                  widget
                                          .onDeleteSection ==
                                      null
                                      ? null
                                      : () =>
                                          _confirmDelete(
                                            section,
                                          ),
                              icon: Icon(
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

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _semesterFilter = 'ALL';
      _departmentFilter = 'ALL';
      _currentPage = 1;
    });
  }

  Widget _buildPagination(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final total =
        _filteredSections.length;

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
              ? '0 sections'
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
              CrossAxisAlignment.start,
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
            const Text('Sections'),
        actions: [
          IconButton(
            tooltip:
                'Refresh sections',
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
                              'Section Management',
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
                              '${widget.sections.length} section${widget.sections.length == 1 ? '' : 's'}',
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
                                .onAddSection,
                        icon:
                            const Icon(
                          Icons
                              .add_circle_outline,
                        ),
                        label:
                            const Text(
                          'Add Section',
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
                  _buildSearchAndFilters(
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

class SectionListItem {
  final int id;
  final String name;
  final String semester;
  final String academicYear;
  final int? departmentId;
  final String departmentName;
  final int studentCount;

  const SectionListItem({
    required this.id,
    required this.name,
    required this.semester,
    required this.academicYear,
    this.departmentId,
    required this.departmentName,
    this.studentCount = 0,
  });

  factory SectionListItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final department =
        json['department'];

    String departmentName = '';

    if (department is Map) {
      departmentName =
          department['name']
                  ?.toString() ??
              '';
    } else {
      departmentName =
          json['department_name']
                  ?.toString() ??
              '';
    }

    return SectionListItem(
      id: _toInt(json['id']) ?? 0,
      name:
          json['name']?.toString() ??
              '',
      semester:
          json['semester']?.toString() ??
              '',
      academicYear:
          json['academic_year']
                  ?.toString() ??
              '',
      departmentId:
          _toInt(
        json['department_id'],
      ),
      departmentName:
          departmentName,
      studentCount:
          _toInt(
                json['student_count'],
              ) ??
              _toInt(
                json['students_count'],
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'semester': semester,
      'academic_year':
          academicYear,
      'department_id':
          departmentId,
      'department_name':
          departmentName,
      'student_count':
          studentCount,
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

class SectionDepartmentOption {
  final int id;
  final String name;

  const SectionDepartmentOption({
    required this.id,
    required this.name,
  });
}