import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  final List<StudentListItem> students;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddStudent;
  final void Function(StudentListItem student)? onViewStudent;
  final void Function(StudentListItem student)? onEditStudent;
  final void Function(StudentListItem student)? onDeleteStudent;

  const StudentsScreen({
    super.key,
    this.students = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddStudent,
    this.onViewStudent,
    this.onEditStudent,
    this.onDeleteStudent,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';
  String _statusFilter = 'All';
  String _semesterFilter = 'All';

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

  List<StudentListItem> get _filteredStudents {
    return widget.students.where((student) {
      final matchesQuery =
          _query.isEmpty ||
          student.name.toLowerCase().contains(_query) ||
          student.rollNo.toLowerCase().contains(_query) ||
          (student.email?.toLowerCase().contains(_query) ?? false);

      final matchesStatus =
          _statusFilter == 'All' ||
          student.status.toLowerCase() ==
              _statusFilter.toLowerCase();

      final matchesSemester =
          _semesterFilter == 'All' ||
          student.semester.toString() == _semesterFilter;

      return matchesQuery &&
          matchesStatus &&
          matchesSemester;
    }).toList();
  }

  List<String> get _semesterOptions {
    final semesters = widget.students
        .map((student) => student.semester)
        .where((semester) => semester > 0)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...semesters.map((semester) => semester.toString()),
    ];
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = 'All';
      _semesterFilter = 'All';
    });
  }

  Future<void> _confirmDelete(
    StudentListItem student,
  ) async {
    if (widget.onDeleteStudent == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Delete Student?'),
          content: Text(
            'Delete ${student.name.isEmpty ? 'this student' : student.name}? '
            'This action should only be used when the student record '
            'is no longer required.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDeleteStudent!(student);
    }
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
      case 'suspended':
        return Colors.orange;
      case 'graduated':
      case 'completed':
        return scheme.primary;
      case 'dropped':
      case 'cancelled':
      case 'canceled':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  Widget _statusBadge(
    BuildContext context,
    String status,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, status);

    final text = status.trim().isEmpty
        ? 'Unknown'
        : status;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _studentAvatar(
    BuildContext context,
    StudentListItem student,
  ) {
    final theme = Theme.of(context);

    final value = student.name.trim();

    String initials = '?';

    if (value.isNotEmpty) {
      final parts = value
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.length == 1) {
        initials = parts.first.substring(0, 1).toUpperCase();
      } else {
        initials =
            '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
            .toUpperCase();
      }
    }

    return CircleAvatar(
      radius: 21,
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
    );
  }

  Widget _studentInfo(
    BuildContext context,
    StudentListItem student,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _studentAvatar(
          context,
          student,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                student.name.isEmpty
                    ? 'Unnamed Student'
                    : student.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                student.rollNo.isEmpty
                    ? 'No roll number'
                    : student.rollNo,
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

  Widget _mobileStudentCard(
    BuildContext context,
    StudentListItem student,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onViewStudent == null
            ? null
            : () => widget.onViewStudent!(student),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _studentInfo(
                      context,
                      student,
                    ),
                  ),
                  _statusBadge(
                    context,
                    student.status,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _detailRow(
                context,
                Icons.account_tree_outlined,
                student.department ?? 'Department not assigned',
              ),
              _detailRow(
                context,
                Icons.groups_outlined,
                student.section ?? 'Section not assigned',
              ),
              _detailRow(
                context,
                Icons.school_outlined,
                'Semester ${student.semester}',
              ),
              if (student.email != null &&
                  student.email!.trim().isNotEmpty)
                _detailRow(
                  context,
                  Icons.email_outlined,
                  student.email!,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  if (widget.onViewStudent != null)
                    TextButton.icon(
                      onPressed: () =>
                          widget.onViewStudent!(student),
                      icon: const Icon(
                        Icons.visibility_outlined,
                      ),
                      label: const Text('View'),
                    ),
                  if (widget.onEditStudent != null)
                    TextButton.icon(
                      onPressed: () =>
                          widget.onEditStudent!(student),
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text('Edit'),
                    ),
                  if (widget.onDeleteStudent != null)
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () =>
                          _confirmDelete(student),
                      color:
                          theme.colorScheme.error,
                      icon: const Icon(
                        Icons.delete_outline,
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

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color:
                theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopTable(
    BuildContext context,
    List<StudentListItem> students,
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
              label: Text('Department'),
            ),
            DataColumn(
              label: Text('Section'),
            ),
            DataColumn(
              label: Text('Semester'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: students.map((student) {
            return DataRow(
              onSelectChanged:
                  widget.onViewStudent == null
                      ? null
                      : (selected) {
                          if (selected == true) {
                            widget.onViewStudent!(
                              student,
                            );
                          }
                        },
              cells: [
                DataCell(
                  SizedBox(
                    width: 250,
                    child: _studentInfo(
                      context,
                      student,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 170,
                    child: Text(
                      student.department ?? '-',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    student.section ?? '-',
                  ),
                ),
                DataCell(
                  Text(
                    student.semester.toString(),
                  ),
                ),
                DataCell(
                  _statusBadge(
                    context,
                    student.status,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onViewStudent != null)
                        IconButton(
                          tooltip: 'View',
                          onPressed: () =>
                              widget.onViewStudent!(
                            student,
                          ),
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      if (widget.onEditStudent != null)
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              widget.onEditStudent!(
                            student,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                        ),
                      if (widget.onDeleteStudent != null)
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDelete(student),
                          color:
                              theme.colorScheme.error,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          columnSpacing: 28,
          horizontalMargin: 14,
          dataRowMinHeight: 68,
          dataRowMaxHeight: 82,
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 700;

            final search = Expanded(
              flex: compact ? 0 : 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search by name, roll number or email',
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
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
              ),
            );

            final status = DropdownButtonFormField<String>(
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
                  value: 'Active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'Inactive',
                  child: Text('Inactive'),
                ),
                DropdownMenuItem(
                  value: 'Graduated',
                  child: Text('Graduated'),
                ),
                DropdownMenuItem(
                  value: 'Suspended',
                  child: Text('Suspended'),
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
                    (semester) =>
                        DropdownMenuItem<String>(
                      value: semester,
                      child: Text(
                        semester == 'All'
                            ? 'All Semesters'
                            : 'Semester $semester',
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

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 12),
                      Expanded(child: semester),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                search,
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: status,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: semester,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear filters',
                  onPressed:
                      _query.isEmpty &&
                              _statusFilter == 'All' &&
                              _semesterFilter == 'All'
                          ? null
                          : _clearFilters,
                  icon: Icon(
                    Icons.filter_alt_off_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    final hasFilters =
        _query.isNotEmpty ||
        _statusFilter != 'All' ||
        _semesterFilter != 'All';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
      ),
      child: Column(
        children: [
          Icon(
            hasFilters
                ? Icons.search_off_outlined
                : Icons.people_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters
                ? 'No students match your filters.'
                : 'No students available.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try changing the search or filters.'
                : 'Add a student to begin building the student directory.',
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
              icon: const Icon(
                Icons.clear_all,
              ),
              label: const Text(
                'Clear Filters',
              ),
            ),
          ] else if (widget.onAddStudent != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.onAddStudent,
              icon: const Icon(
                Icons.person_add_outlined,
              ),
              label: const Text(
                'Add Student',
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed:
                  widget.isLoading ? null : widget.onRefresh,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          if (widget.onAddStudent != null)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: FilledButton.icon(
                onPressed: widget.isLoading
                    ? null
                    : widget.onAddStudent,
                icon: const Icon(
                  Icons.person_add_outlined,
                ),
                label: const Text(
                  'Add Student',
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.students.length} '
                    '${widget.students.length == 1 ? 'student' : 'students'} '
                    'in the directory',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.errorMessage != null &&
                      widget.errorMessage!
                          .trim()
                          .isNotEmpty)
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
                          color: theme
                              .colorScheme
                              .error
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
                  _buildFilters(context),
                  const SizedBox(height: 18),
                  Expanded(
                    child: widget.isLoading &&
                            widget.students.isEmpty
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : filtered.isEmpty
                            ? _buildEmptyState(context)
                            : LayoutBuilder(
                                builder:
                                    (context, constraints) {
                                  if (constraints.maxWidth <
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
                                          (context, index) {
                                        return _mobileStudentCard(
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

class StudentListItem {
  final int id;
  final String name;
  final String rollNo;
  final String? email;
  final String? phone;
  final String? department;
  final String? section;
  final int semester;
  final String status;

  const StudentListItem({
    required this.id,
    required this.name,
    required this.rollNo,
    this.email,
    this.phone,
    this.department,
    this.section,
    required this.semester,
    this.status = 'Active',
  });
}