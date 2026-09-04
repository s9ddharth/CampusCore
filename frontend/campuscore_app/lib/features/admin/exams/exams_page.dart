import 'package:flutter/material.dart';

class ExamsPage extends StatefulWidget {
  final List<ExamItem> exams;
  final List<ExamSubjectOption> subjects;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddExam;
  final void Function(ExamItem exam)? onView;
  final void Function(ExamItem exam)? onEdit;
  final void Function(ExamItem exam)? onDelete;

  const ExamsPage({
    super.key,
    this.exams = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onAddExam,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  String _statusFilter = 'All';
  String _subjectFilter = 'All';
  String _typeFilter = 'All';

  List<String> get _subjectOptions {
    final values = widget.exams
        .map((exam) => exam.subjectName.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...values,
    ];
  }

  List<ExamItem> get _filteredExams {
    return widget.exams.where((exam) {
      final statusMatches = _statusFilter == 'All' ||
          exam.status.toLowerCase() ==
              _statusFilter.toLowerCase();

      final subjectMatches = _subjectFilter == 'All' ||
          exam.subjectName == _subjectFilter;

      final typeMatches = _typeFilter == 'All' ||
          exam.examType.toLowerCase() ==
              _typeFilter.toLowerCase();

      return statusMatches &&
          subjectMatches &&
          typeMatches;
    }).toList();
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'scheduled':
      case 'active':
        return Colors.green;

      case 'draft':
      case 'pending':
        return Colors.orange;

      case 'completed':
      case 'published':
      case 'locked':
        return scheme.primary;

      case 'cancelled':
      case 'canceled':
        return scheme.error;

      default:
        return scheme.onSurfaceVariant;
    }
  }

  Color _typeColor(
    BuildContext context,
    String type,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (type.trim().toUpperCase()) {
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

  String _typeLabel(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CAT1':
        return 'CAT 1';

      case 'CAT2':
        return 'CAT 2';

      case 'TEE':
        return 'TEE';

      case 'INTERNAL':
        return 'Internal';

      default:
        return type;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not scheduled';
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day/$month/$year';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }

    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute = time.minute
        .toString()
        .padLeft(2, '0');

    final suffix = time.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$hour:$minute $suffix';
  }

  Widget _statusBadge(
    BuildContext context,
    String status,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, status);

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
        status.trim().isEmpty ? 'Unknown' : status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _typeBadge(
    BuildContext context,
    String type,
  ) {
    final theme = Theme.of(context);
    final color = _typeColor(context, type);

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
        _typeLabel(type),
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ExamItem exam) async {
    if (widget.onDelete == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Delete Exam?'),
          content: Text(
            'Delete ${_typeLabel(exam.examType)} for '
            '${exam.subjectName.isEmpty ? 'this subject' : exam.subjectName}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDelete!(exam);
    }
  }

  Widget _metric(
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examCard(
    BuildContext context,
    ExamItem exam,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onView == null
            ? null
            : () => widget.onView!(exam),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _typeBadge(
                    context,
                    exam.examType,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.subjectName.isEmpty
                              ? 'Unknown Subject'
                              : exam.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (exam.subjectCode.isNotEmpty)
                          Text(
                            exam.subjectCode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _statusBadge(
                    context,
                    exam.status,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _metric(
                    context,
                    label: 'Date',
                    value: _formatDate(exam.date),
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    label: 'Max Marks',
                    value: _formatNumber(exam.maxMarks),
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    label: 'Duration',
                    value: exam.durationMinutes == null
                        ? '-'
                        : '${exam.durationMinutes} min',
                  ),
                ],
              ),
              if (exam.time != null ||
                  exam.room != null ||
                  exam.venue != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 7,
                  children: [
                    if (exam.time != null)
                      _info(
                        context,
                        Icons.schedule_outlined,
                        _formatTime(exam.time),
                      ),
                    if (exam.room != null &&
                        exam.room!.trim().isNotEmpty)
                      _info(
                        context,
                        Icons.meeting_room_outlined,
                        exam.room!,
                      ),
                    if (exam.venue != null &&
                        exam.venue!.trim().isNotEmpty)
                      _info(
                        context,
                        Icons.location_on_outlined,
                        exam.venue!,
                      ),
                  ],
                ),
              ],
              if (exam.description != null &&
                  exam.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  exam.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  if (widget.onView != null)
                    TextButton.icon(
                      onPressed: () =>
                          widget.onView!(exam),
                      icon: const Icon(
                        Icons.visibility_outlined,
                      ),
                      label: const Text('View'),
                    ),
                  if (widget.onEdit != null)
                    TextButton.icon(
                      onPressed: () =>
                          widget.onEdit!(exam),
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text('Edit'),
                    ),
                  if (widget.onDelete != null)
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () =>
                          _confirmDelete(exam),
                      color: theme.colorScheme.error,
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

  Widget _info(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Widget _desktopTable(
    BuildContext context,
    List<ExamItem> exams,
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
              label: Text('Subject'),
            ),
            DataColumn(
              label: Text('Type'),
            ),
            DataColumn(
              label: Text('Date'),
            ),
            DataColumn(
              label: Text('Time'),
            ),
            DataColumn(
              label: Text('Max Marks'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: exams.map((exam) {
            return DataRow(
              onSelectChanged: widget.onView == null
                  ? null
                  : (selected) {
                      if (selected == true) {
                        widget.onView!(exam);
                      }
                    },
              cells: [
                DataCell(
                  SizedBox(
                    width: 230,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.subjectName.isEmpty
                              ? 'Unknown Subject'
                              : exam.subjectName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        if (exam.subjectCode.isNotEmpty)
                          Text(
                            exam.subjectCode,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: theme.colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  _typeBadge(
                    context,
                    exam.examType,
                  ),
                ),
                DataCell(
                  Text(_formatDate(exam.date)),
                ),
                DataCell(
                  Text(_formatTime(exam.time)),
                ),
                DataCell(
                  Text(_formatNumber(exam.maxMarks)),
                ),
                DataCell(
                  _statusBadge(
                    context,
                    exam.status,
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
                              widget.onView!(exam),
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      if (widget.onEdit != null)
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              widget.onEdit!(exam),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                        ),
                      if (widget.onDelete != null)
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDelete(exam),
                          color: theme.colorScheme.error,
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
          dataRowMaxHeight: 84,
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
                constraints.maxWidth < 750;

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
                  value: 'Scheduled',
                  child: Text('Scheduled'),
                ),
                DropdownMenuItem(
                  value: 'Draft',
                  child: Text('Draft'),
                ),
                DropdownMenuItem(
                  value: 'Completed',
                  child: Text('Completed'),
                ),
                DropdownMenuItem(
                  value: 'Locked',
                  child: Text('Locked'),
                ),
                DropdownMenuItem(
                  value: 'Cancelled',
                  child: Text('Cancelled'),
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

            final type =
                DropdownButtonFormField<String>(
              initialValue: _typeFilter,
              decoration: const InputDecoration(
                labelText: 'Exam Type',
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
                  _typeFilter = value;
                });
              },
            );

            if (compact) {
              return Column(
                children: [
                  status,
                  const SizedBox(height: 10),
                  subject,
                  const SizedBox(height: 10),
                  type,
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 175,
                  child: status,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: subject,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 175,
                  child: type,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final hasFilters =
        _statusFilter != 'All' ||
        _subjectFilter != 'All' ||
        _typeFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_outlined
                  : Icons.event_outlined,
              size: 48,
              color:
                  theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'No exams match the selected filters.'
                  : 'No exams available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try changing the filters.'
                  : 'Create an exam or assessment to begin the schedule.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!hasFilters &&
                widget.onAddExam != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.onAddExam,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Add Exam',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summary(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final filtered = _filteredExams;

    final scheduled = filtered
        .where(
          (exam) =>
              exam.status.toLowerCase() ==
              'scheduled',
        )
        .length;

    final completed = filtered
        .where(
          (exam) =>
              exam.status.toLowerCase() ==
                  'completed' ||
              exam.status.toLowerCase() ==
                  'locked',
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 650 ? 2 : 4;

        final cards = [
          _summaryCard(
            context,
            title: 'Total Exams',
            value: '${filtered.length}',
            icon: Icons.event_outlined,
            color: theme.colorScheme.primary,
          ),
          _summaryCard(
            context,
            title: 'Scheduled',
            value: '$scheduled',
            icon: Icons.schedule_outlined,
            color: Colors.orange,
          ),
          _summaryCard(
            context,
            title: 'Completed',
            value: '$completed',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _summaryCard(
            context,
            title: 'Subjects',
            value: '${_subjectOptions.length - 1}',
            icon: Icons.menu_book_outlined,
            color: Colors.blue,
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
    final filtered = _filteredExams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed: widget.isLoading
                  ? null
                  : widget.onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          if (widget.onAddExam != null)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: FilledButton.icon(
                onPressed: widget.isLoading
                    ? null
                    : widget.onAddExam,
                icon: const Icon(Icons.add),
                label: const Text('Add Exam'),
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
                    'Exam Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Manage assessment schedules and examination details.',
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
                  _summary(context),
                  const SizedBox(height: 18),
                  _filters(context),
                  const SizedBox(height: 18),
                  Expanded(
                    child: widget.isLoading &&
                            widget.exams.isEmpty
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
                                          const EdgeInsets
                                              .only(
                                        bottom: 24,
                                      ),
                                      itemCount:
                                          filtered.length,
                                      itemBuilder:
                                          (context, index) {
                                        return _examCard(
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

class ExamItem {
  final int id;
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final String examType;
  final DateTime? date;
  final TimeOfDay? time;
  final int? durationMinutes;
  final double maxMarks;
  final String status;
  final String? room;
  final String? venue;
  final String? description;

  const ExamItem({
    required this.id,
    this.subjectId,
    this.subjectName = '',
    this.subjectCode = '',
    this.examType = 'TEE',
    this.date,
    this.time,
    this.durationMinutes,
    this.maxMarks = 0,
    this.status = 'Draft',
    this.room,
    this.venue,
    this.description,
  });
}

class ExamSubjectOption {
  final int id;
  final String name;
  final String code;
  final int semester;

  const ExamSubjectOption({
    required this.id,
    required this.name,
    this.code = '',
    this.semester = 0,
  });
}