import 'package:flutter/material.dart';

class FacultyPage extends StatefulWidget {
  final List<FacultyListItem> faculty;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onAddFaculty;
  final void Function(FacultyListItem faculty)? onViewFaculty;
  final void Function(FacultyListItem faculty)? onEditFaculty;
  final void Function(FacultyListItem faculty)? onDeleteFaculty;

  const FacultyPage({
    super.key,
    this.faculty = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddFaculty,
    this.onViewFaculty,
    this.onEditFaculty,
    this.onDeleteFaculty,
  });

  @override
  State<FacultyPage> createState() =>
      _FacultyPageState();
}

class _FacultyPageState
    extends State<FacultyPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _statusFilter = 'ALL';
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
    final value =
        _searchController.text.trim();

    if (_searchQuery == value) {
      return;
    }

    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  List<FacultyListItem> get _filteredFaculty {
    final query =
        _searchQuery.toLowerCase();

    return widget.faculty.where((faculty) {
      final matchesSearch =
          query.isEmpty ||
              faculty.name
                  .toLowerCase()
                  .contains(query) ||
              faculty.employeeId
                  .toLowerCase()
                  .contains(query) ||
              faculty.email
                  .toLowerCase()
                  .contains(query) ||
              (faculty.departmentName ?? '')
                  .toLowerCase()
                  .contains(query);

      final matchesStatus =
          _statusFilter == 'ALL' ||
              faculty.status.toUpperCase() ==
                  _statusFilter;

      return matchesSearch &&
          matchesStatus;
    }).toList();
  }

  List<FacultyListItem> get _visibleFaculty {
    final filtered =
        _filteredFaculty;

    final start =
        (_currentPage - 1) * _pageSize;

    if (start >= filtered.length) {
      return const [];
    }

    final end =
        (start + _pageSize)
            .clamp(0, filtered.length);

    return filtered.sublist(
      start,
      end,
    );
  }

  int get _totalPages {
    final count =
        _filteredFaculty.length;

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
    if (widget.onRefresh == null ||
        widget.isLoading) {
      return;
    }

    await widget.onRefresh!();
  }

  Future<void> _confirmDelete(
    FacultyListItem faculty,
  ) async {
    if (widget.onDeleteFaculty == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Faculty?',
          ),
          content: Text(
            'Delete the faculty record for ${faculty.name}? '
            'This is an administrative action and should be used carefully.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(false),
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context)
                        .colorScheme
                        .error,
                foregroundColor:
                    Theme.of(context)
                        .colorScheme
                        .onError,
              ),
              onPressed: () =>
                  Navigator.of(context)
                      .pop(true),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDeleteFaculty!(faculty);
    }
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

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
                    650;

            final search =
                TextField(
              controller:
                  _searchController,
              decoration:
                  InputDecoration(
                hintText:
                    'Search by name, employee ID, email or department',
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

            final filter =
                DropdownButtonFormField<String>(
              initialValue:
                  _statusFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Status',
                prefixIcon:
                    Icon(
                  Icons.filter_alt_outlined,
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
                  (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _statusFilter =
                      value;
                  _currentPage = 1;
                });
              },
            );

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(
                    height: 12,
                  ),
                  filter,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: search,
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 220,
                  child: filter,
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

    final isActive =
        normalized == 'ACTIVE';

    final background =
        isActive
            ? Colors.green.withValues(
                alpha: 0.10,
              )
            : theme.colorScheme
                .surfaceContainerHighest;

    final foreground =
        isActive
            ? Colors.green.shade700
            : theme.colorScheme
                .onSurfaceVariant;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
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
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(
              color: foreground,
              shape:
                  BoxShape.circle,
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

  Widget _buildFacultyTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (_visibleFaculty.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.all(36),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons
                      .person_search_outlined,
                  size: 48,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  _filteredFaculty
                          .isEmpty
                      ? 'No faculty found'
                      : 'No faculty on this page',
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
                  _searchQuery.isNotEmpty
                      ? 'Try changing the search or status filter.'
                      : 'Faculty records will appear here.',
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
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 14,
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _statusFilter =
                            'ALL';
                      });
                    },
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
          columnSpacing: 28,
          horizontalMargin: 18,
          columns: const [
            DataColumn(
              label: Text(
                'Faculty',
              ),
            ),
            DataColumn(
              label: Text(
                'Employee ID',
              ),
            ),
            DataColumn(
              label: Text(
                'Department',
              ),
            ),
            DataColumn(
              label: Text(
                'Phone',
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
              ),
            ),
          ],
          rows: _visibleFaculty.map(
            (faculty) {
              final initials =
                  faculty.name
                      .trim()
                      .split(
                        RegExp(
                          r'\s+',
                        ),
                      )
                      .where(
                        (part) =>
                            part.isNotEmpty,
                      )
                      .take(2)
                      .map(
                        (part) =>
                            part[0]
                                .toUpperCase(),
                      )
                      .join();

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme
                                    .colorScheme
                                    .primaryContainer,
                            child: Text(
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
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  faculty
                                      .name,
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  faculty
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
                      faculty.employeeId,
                    ),
                  ),
                  DataCell(
                    Text(
                      faculty
                              .departmentName ??
                          'Not assigned',
                    ),
                  ),
                  DataCell(
                    Text(
                      faculty.phone ??
                          'Not provided',
                    ),
                  ),
                  DataCell(
                    _buildStatusBadge(
                      context,
                      faculty.status,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip:
                              'View faculty',
                          onPressed:
                              widget
                                      .onViewFaculty ==
                                  null
                                  ? null
                                  : () => widget
                                      .onViewFaculty!(
                                    faculty,
                                  ),
                          icon:
                              const Icon(
                            Icons
                                .visibility_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Edit faculty',
                          onPressed:
                              widget
                                      .onEditFaculty ==
                                  null
                                  ? null
                                  : () => widget
                                      .onEditFaculty!(
                                    faculty,
                                  ),
                          icon:
                              const Icon(
                            Icons
                                .edit_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Delete faculty',
                          onPressed:
                              widget
                                      .onDeleteFaculty ==
                                  null
                                  ? null
                                  : () =>
                                      _confirmDelete(
                                    faculty,
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
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final totalItems =
        _filteredFaculty.length;

    final start =
        totalItems == 0
            ? 0
            : ((_currentPage - 1) *
                    _pageSize) +
                1;

    final end =
        totalItems == 0
            ? 0
            : (_currentPage *
                    _pageSize)
                .clamp(0, totalItems);

    return Row(
      children: [
        Text(
          totalItems == 0
              ? '0 faculty'
              : '$start-$end of $totalItems',
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
            Icons
                .chevron_left,
          ),
        ),
        Container(
          constraints:
              const BoxConstraints(
            minWidth: 38,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
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
            textAlign:
                TextAlign.center,
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
            Icons
                .chevron_right,
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
            const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons
                  .error_outline,
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
            const Text('Faculty'),
        actions: [
          IconButton(
            tooltip:
                'Refresh faculty',
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
                      strokeWidth:
                          2,
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
                    CrossAxisAlignment.start,
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
                              'Faculty Management',
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
                              '${widget.faculty.length} faculty record${widget.faculty.length == 1 ? '' : 's'}',
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
                                .onAddFaculty,
                        icon:
                            const Icon(
                          Icons
                              .person_add_alt_1_outlined,
                        ),
                        label:
                            const Text(
                          'Add Faculty',
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
                  _buildSearchBar(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildFacultyTable(
                    context,
                  ),
                  const SizedBox(
                    height: 12,
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

class FacultyListItem {
  final int id;
  final int? userId;
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final int? departmentId;
  final String? departmentName;
  final String status;

  const FacultyListItem({
    required this.id,
    this.userId,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    this.departmentId,
    this.departmentName,
    this.status = 'ACTIVE',
  });

  factory FacultyListItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final department =
        json['department'];

    String? departmentName;

    if (department is Map) {
      departmentName =
          department['name']
              ?.toString();
    } else {
      departmentName =
          json['department_name']
              ?.toString();
    }

    return FacultyListItem(
      id: _toInt(json['id']) ?? 0,
      userId:
          _toInt(json['user_id']),
      employeeId:
          json['employee_id']
                  ?.toString() ??
              '',
      name:
          json['name']
                  ?.toString() ??
              '',
      email:
          json['email']
                  ?.toString() ??
              '',
      phone:
          json['phone']?.toString(),
      departmentId:
          _toInt(
        json['department_id'],
      ),
      departmentName:
          departmentName,
      status:
          json['status']
                  ?.toString() ??
              'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'department_id':
          departmentId,
      'department_name':
          departmentName,
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
}