import 'package:flutter/material.dart';

class SubjectAssignmentPage extends StatefulWidget {
  final List<SubjectAssignmentItem> assignments;
  final List<AssignmentFacultyOption> faculty;
  final List<AssignmentSubjectOption> subjects;
  final List<AssignmentSectionOption> sections;

  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;

  final Future<void> Function(
    SubjectAssignmentData data,
  )? onCreateAssignment;

  final Future<void> Function(
    SubjectAssignmentItem assignment,
  )? onDeleteAssignment;

  final VoidCallback? onBack;

  const SubjectAssignmentPage({
    super.key,
    this.assignments = const [],
    this.faculty = const [],
    this.subjects = const [],
    this.sections = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onCreateAssignment,
    this.onDeleteAssignment,
    this.onBack,
  });

  @override
  State<SubjectAssignmentPage> createState() =>
      _SubjectAssignmentPageState();
}

class _SubjectAssignmentPageState
    extends State<SubjectAssignmentPage> {
  int? _selectedFacultyId;
  int? _selectedSubjectId;
  int? _selectedSectionId;

  String _searchQuery = '';
  final TextEditingController _searchController =
      TextEditingController();

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

  List<SubjectAssignmentItem>
      get _filteredAssignments {
    final query =
        _searchQuery.toLowerCase();

    return widget.assignments.where(
      (assignment) {
        if (query.isEmpty) {
          return true;
        }

        return assignment.facultyName
                .toLowerCase()
                .contains(query) ||
            assignment.subjectName
                .toLowerCase()
                .contains(query) ||
            assignment.subjectCode
                .toLowerCase()
                .contains(query) ||
            assignment.sectionName
                .toLowerCase()
                .contains(query) ||
            assignment.academicYear
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  List<SubjectAssignmentItem>
      get _visibleAssignments {
    final filtered =
        _filteredAssignments;

    final start =
        (_currentPage - 1) * _pageSize;

    if (start >= filtered.length) {
      return const [];
    }

    final end = (start + _pageSize)
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
        _filteredAssignments.length;

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

  Future<void> _refresh() async {
    if (widget.isLoading ||
        widget.onRefresh == null) {
      return;
    }

    await widget.onRefresh!();
  }

  void _clearForm() {
    setState(() {
      _selectedFacultyId = null;
      _selectedSubjectId = null;
      _selectedSectionId = null;
    });
  }

  Future<void> _createAssignment() async {
    if (widget.isLoading) {
      return;
    }

    if (_selectedFacultyId == null ||
        _selectedSubjectId == null ||
        _selectedSectionId == null) {
      _showMessage(
        'Select faculty, subject and section.',
      );
      return;
    }

    final duplicate =
        widget.assignments.any(
      (assignment) =>
          assignment.facultyId ==
              _selectedFacultyId &&
          assignment.subjectId ==
              _selectedSubjectId &&
          assignment.sectionId ==
              _selectedSectionId,
    );

    if (duplicate) {
      _showMessage(
        'This faculty-subject-section assignment already exists.',
      );
      return;
    }

    final data = SubjectAssignmentData(
      facultyId: _selectedFacultyId!,
      subjectId: _selectedSubjectId!,
      sectionId: _selectedSectionId!,
    );

    if (widget.onCreateAssignment !=
        null) {
      await widget.onCreateAssignment!(
        data,
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _confirmDelete(
    SubjectAssignmentItem assignment,
  ) async {
    if (widget.onDeleteAssignment ==
        null) {
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
            'Remove Assignment?',
          ),
          content: Text(
            'Remove ${assignment.facultyName} from '
            '${assignment.subjectCode} - ${assignment.sectionName}?',
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
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.onDeleteAssignment!(
        assignment,
      );
    }
  }

  Widget _buildAssignmentForm(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
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
                    Icons.link_outlined,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Create Teaching Assignment',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Link a faculty member to a subject and section.',
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
            const SizedBox(
              height: 20,
            ),
            LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                final compact =
                    constraints.maxWidth < 800;

                final facultyDropdown =
                    DropdownButtonFormField<int>(
                  initialValue:
                      _selectedFacultyId,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Faculty',
                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  items: widget.faculty
                      .map(
                        (
                          faculty,
                        ) =>
                            DropdownMenuItem<
                                int>(
                          value:
                              faculty.id,
                          child:
                              Text(
                            '${faculty.name} (${faculty.employeeId})',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      widget.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedFacultyId =
                                    value;
                              });
                            },
                );

                final subjectDropdown =
                    DropdownButtonFormField<int>(
                  initialValue:
                      _selectedSubjectId,
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
                  items: widget.subjects
                      .map(
                        (
                          subject,
                        ) =>
                            DropdownMenuItem<
                                int>(
                          value:
                              subject.id,
                          child:
                              Text(
                            '${subject.code} - ${subject.name}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      widget.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSubjectId =
                                    value;
                              });
                            },
                );

                final sectionDropdown =
                    DropdownButtonFormField<int>(
                  initialValue:
                      _selectedSectionId,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Section',
                    prefixIcon:
                        Icon(
                      Icons
                          .groups_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  items: widget.sections
                      .map(
                        (
                          section,
                        ) =>
                            DropdownMenuItem<
                                int>(
                          value:
                              section.id,
                          child:
                              Text(
                            section.displayName,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      widget.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSectionId =
                                    value;
                              });
                            },
                );

                if (compact) {
                  return Column(
                    children: [
                      facultyDropdown,
                      const SizedBox(
                        height: 12,
                      ),
                      subjectDropdown,
                      const SizedBox(
                        height: 12,
                      ),
                      sectionDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child:
                          facultyDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          subjectDropdown,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          sectionDropdown,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                13,
              ),
              decoration:
                  BoxDecoration(
                color: theme.colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 19,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  Expanded(
                    child: Text(
                      'The assignment links faculty, subject and section. '
                      'Backend authorization remains responsible for determining what a faculty member can edit.',
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed:
                      widget.isLoading
                          ? null
                          : _clearForm,
                  child:
                      const Text(
                    'Clear',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FilledButton.icon(
                  onPressed:
                      widget.isLoading
                          ? null
                          : _createAssignment,
                  icon:
                      widget.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .add_link,
                            ),
                  label: Text(
                    widget.isLoading
                        ? 'Saving...'
                        : 'Assign Subject',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: TextField(
          controller:
              _searchController,
          enabled:
              !widget.isLoading,
          decoration:
              InputDecoration(
            hintText:
                'Search faculty, subject, section or academic year',
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
        ),
      ),
    );
  }

  Widget _buildAssignmentTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (_visibleAssignments.isEmpty) {
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
                  Icons.link_off_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No assignments found',
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
                  _searchQuery.isEmpty
                      ? 'No faculty-subject-section assignments have been created yet.'
                      : 'Try changing the search query.',
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
                  Text('Faculty'),
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
                  Text('Semester'),
            ),
            DataColumn(
              label:
                  Text('Academic Year'),
            ),
            DataColumn(
              label:
                  Text('Actions'),
            ),
          ],
          rows: _visibleAssignments
              .map(
                (assignment) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 190,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                assignment
                                    .facultyName,
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
                                assignment
                                    .employeeId,
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
                                assignment
                                    .subjectName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                              Text(
                                '${assignment.subjectCode} • ${assignment.credits} credits',
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
                          assignment
                              .sectionName,
                        ),
                      ),
                      DataCell(
                        Text(
                          assignment
                                  .semester ??
                              '—',
                        ),
                      ),
                      DataCell(
                        Text(
                          assignment
                              .academicYear,
                        ),
                      ),
                      DataCell(
                        IconButton(
                          tooltip:
                              'Remove assignment',
                          onPressed:
                              widget
                                      .onDeleteAssignment ==
                                  null
                                  ? null
                                  : () =>
                                      _confirmDelete(
                                        assignment,
                                      ),
                          icon: Icon(
                            Icons
                                .link_off_outlined,
                            color: theme
                                .colorScheme
                                .error,
                          ),
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
        _filteredAssignments.length;

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
              ? '0 assignments'
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
        title: const Text(
          'Subject Assignments',
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
                'Refresh assignments',
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
                  Text(
                    'Faculty Subject Assignment',
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
                    'Manage which faculty member teaches each subject for a section.',
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
                  _buildAssignmentForm(
                    context,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Current Assignments',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildSearchBar(
                    context,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _buildAssignmentTable(
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

class SubjectAssignmentData {
  final int facultyId;
  final int subjectId;
  final int sectionId;

  const SubjectAssignmentData({
    required this.facultyId,
    required this.subjectId,
    required this.sectionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'faculty_id': facultyId,
      'subject_id': subjectId,
      'section_id': sectionId,
    };
  }
}

class SubjectAssignmentItem {
  final int id;
  final int facultyId;
  final int subjectId;
  final int sectionId;

  final String facultyName;
  final String employeeId;

  final String subjectCode;
  final String subjectName;
  final String credits;

  final String sectionName;
  final String? semester;
  final String academicYear;

  const SubjectAssignmentItem({
    required this.id,
    required this.facultyId,
    required this.subjectId,
    required this.sectionId,
    required this.facultyName,
    required this.employeeId,
    required this.subjectCode,
    required this.subjectName,
    required this.credits,
    required this.sectionName,
    this.semester,
    required this.academicYear,
  });

  factory SubjectAssignmentItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final faculty =
        json['faculty'];

    final subject =
        json['subject'];

    final section =
        json['section'];

    return SubjectAssignmentItem(
      id: _toInt(json['id']) ?? 0,
      facultyId:
          _toInt(json['faculty_id']) ??
              0,
      subjectId:
          _toInt(json['subject_id']) ??
              0,
      sectionId:
          _toInt(json['section_id']) ??
              0,
      facultyName:
          faculty is Map
              ? faculty['name']
                      ?.toString() ??
                  ''
              : json['faculty_name']
                      ?.toString() ??
                  '',
      employeeId:
          faculty is Map
              ? faculty['employee_id']
                      ?.toString() ??
                  ''
              : json['employee_id']
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
      subjectName:
          subject is Map
              ? subject['name']
                      ?.toString() ??
                  ''
              : json['subject_name']
                      ?.toString() ??
                  '',
      credits:
          subject is Map
              ? subject['credits']
                      ?.toString() ??
                  ''
              : json['credits']
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
      semester:
          section is Map
              ? section['semester']
                  ?.toString()
              : json['semester']
                  ?.toString(),
      academicYear:
          section is Map
              ? section['academic_year']
                      ?.toString() ??
                  ''
              : json['academic_year']
                      ?.toString() ??
                  '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'subject_id': subjectId,
      'section_id': sectionId,
      'faculty_name': facultyName,
      'employee_id': employeeId,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'credits': credits,
      'section_name': sectionName,
      'semester': semester,
      'academic_year': academicYear,
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

class AssignmentFacultyOption {
  final int id;
  final String employeeId;
  final String name;

  const AssignmentFacultyOption({
    required this.id,
    required this.employeeId,
    required this.name,
  });
}

class AssignmentSubjectOption {
  final int id;
  final String code;
  final String name;
  final dynamic credits;

  const AssignmentSubjectOption({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
  });
}

class AssignmentSectionOption {
  final int id;
  final String name;
  final int? semester;
  final int? departmentId;
  final String? academicYear;

  const AssignmentSectionOption({
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