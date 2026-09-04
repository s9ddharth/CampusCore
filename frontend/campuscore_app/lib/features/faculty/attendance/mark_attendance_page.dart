import 'package:flutter/material.dart';

class MarkAttendancePage extends StatefulWidget {
  final List<MarkAttendanceStudent> students;
  final List<MarkAttendanceSubjectOption> subjects;

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final Future<void> Function(
    MarkAttendanceRequest request,
  )? onSave;

  final Future<void> Function(
    int subjectId,
    DateTime date,
  )? onLoadStudents;

  final VoidCallback? onBack;

  const MarkAttendancePage({
    super.key,
    this.students = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.onSave,
    this.onLoadStudents,
    this.onBack,
  });

  @override
  State<MarkAttendancePage> createState() =>
      _MarkAttendancePageState();
}

class _MarkAttendancePageState
    extends State<MarkAttendancePage> {
  int? _selectedSubjectId;
  DateTime _selectedDate = DateTime.now();

  final Map<int, String> _attendance = {};

  @override
  void initState() {
    super.initState();

    _selectedSubjectId =
        widget.subjects.isNotEmpty
            ? widget.subjects.first.id
            : null;

    _initializeAttendance();
  }

  @override
  void didUpdateWidget(
    covariant MarkAttendancePage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.students != widget.students) {
      _initializeAttendance();
    }

    if (_selectedSubjectId != null &&
        !widget.subjects.any(
          (subject) =>
              subject.id == _selectedSubjectId,
        )) {
      _selectedSubjectId =
          widget.subjects.isEmpty
              ? null
              : widget.subjects.first.id;
    }
  }

  void _initializeAttendance() {
    for (final student in widget.students) {
      _attendance.putIfAbsent(
        student.studentId,
        () => student.initialStatus ?? 'PRESENT',
      );
    }
  }

  List<MarkAttendanceStudent> get _visibleStudents {
    return widget.students;
  }

  int get _presentCount {
    return _attendance.values
        .where(
          (status) => status == 'PRESENT',
        )
        .length;
  }

  int get _absentCount {
    return _attendance.values
        .where(
          (status) => status == 'ABSENT',
        )
        .length;
  }

  int get _lateCount {
    return _attendance.values
        .where(
          (status) => status == 'LATE',
        )
        .length;
  }

  int get _excusedCount {
    return _attendance.values
        .where(
          (status) => status == 'EXCUSED',
        )
        .length;
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });

    if (_selectedSubjectId != null &&
        widget.onLoadStudents != null) {
      await widget.onLoadStudents!(
        _selectedSubjectId!,
        picked,
      );
    }
  }

  Future<void> _onSubjectChanged(
    int? subjectId,
  ) async {
    if (subjectId == null) {
      return;
    }

    setState(() {
      _selectedSubjectId = subjectId;
      _attendance.clear();
    });

    if (widget.onLoadStudents != null) {
      await widget.onLoadStudents!(
        subjectId,
        _selectedDate,
      );
    }
  }

  void _setStatusForAll(
    String status,
  ) {
    if (widget.isSaving || widget.isLoading) {
      return;
    }

    setState(() {
      for (final student in _visibleStudents) {
        _attendance[student.studentId] =
            status;
      }
    });
  }

  void _setStudentStatus(
    int studentId,
    String status,
  ) {
    if (widget.isSaving || widget.isLoading) {
      return;
    }

    setState(() {
      _attendance[studentId] = status;
    });
  }

  Future<void> _saveAttendance() async {
    if (widget.isSaving || widget.isLoading) {
      return;
    }

    if (_selectedSubjectId == null) {
      _showMessage(
        'Select a subject before saving attendance.',
      );
      return;
    }

    if (_visibleStudents.isEmpty) {
      _showMessage(
        'There are no students to mark attendance for.',
      );
      return;
    }

    for (final student in _visibleStudents) {
      if (!_attendance.containsKey(
        student.studentId,
      )) {
        _showMessage(
          'Attendance is incomplete. Mark every student before saving.',
        );
        return;
      }
    }

    final records = _visibleStudents
        .map(
          (student) => MarkAttendanceRecord(
            studentId: student.studentId,
            status:
                _attendance[student.studentId]!,
          ),
        )
        .toList();

    final request = MarkAttendanceRequest(
      subjectId: _selectedSubjectId!,
      date: _dateOnly(_selectedDate),
      records: records,
    );

    if (widget.onSave != null) {
      await widget.onSave!(request);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
  ) {
    final theme = Theme.of(context);
    final normalized = status.toUpperCase();

    final Color foreground;
    final Color background;

    switch (normalized) {
      case 'PRESENT':
        foreground = Colors.green.shade700;
        background =
            Colors.green.withValues(alpha: 0.10);
        break;
      case 'ABSENT':
        foreground = theme.colorScheme.error;
        background =
            theme.colorScheme.errorContainer.withValues(
          alpha: 0.55,
        );
        break;
      case 'LATE':
        foreground = Colors.orange.shade800;
        background =
            Colors.orange.withValues(alpha: 0.10);
        break;
      case 'EXCUSED':
        foreground = theme.colorScheme.primary;
        background =
            theme.colorScheme.primaryContainer;
        break;
      default:
        foreground =
            theme.colorScheme.onSurfaceVariant;
        background = theme.colorScheme
            .surfaceContainerHighest;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        theme.textTheme.bodySmall?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style:
                        theme.textTheme.titleMedium?.copyWith(
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

  Widget _buildSummary(
    BuildContext context,
  ) {
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
            title: 'Present',
            value: _presentCount.toString(),
            icon: Icons.check_circle_outline,
          ),
          _buildSummaryCard(
            context,
            title: 'Absent',
            value: _absentCount.toString(),
            icon: Icons.cancel_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Late',
            value: _lateCount.toString(),
            icon: Icons.schedule_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Excused',
            value: _excusedCount.toString(),
            icon: Icons.assignment_turned_in_outlined,
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
                const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControls(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth < 800;

            final subjectDropdown =
                DropdownButtonFormField<int>(
              initialValue: _selectedSubjectId,
              decoration:
                  const InputDecoration(
                labelText: 'Subject',
                prefixIcon:
                    Icon(Icons.menu_book_outlined),
                border: OutlineInputBorder(),
              ),
              items: widget.subjects
                  .map(
                    (subject) =>
                        DropdownMenuItem<int>(
                      value: subject.id,
                      child: Text(
                        '${subject.code} - ${subject.name}',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  widget.isLoading ||
                          widget.isSaving
                      ? null
                      : _onSubjectChanged,
            );

            final dateButton =
                OutlinedButton.icon(
              onPressed:
                  widget.isLoading ||
                          widget.isSaving
                      ? null
                      : _pickDate,
              icon: const Icon(
                Icons.calendar_today_outlined,
              ),
              label: Text(
                _formatDate(_selectedDate),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize:
                    const Size(170, 56),
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  subjectDropdown,
                  const SizedBox(height: 12),
                  dateButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: subjectDropdown,
                ),
                const SizedBox(width: 12),
                dateButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBulkActions(
    BuildContext context,
  ) {
    final disabled =
        widget.isLoading ||
            widget.isSaving ||
            _visibleStudents.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment:
              WrapCrossAlignment.center,
          children: [
            Text(
              'Mark all:',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            OutlinedButton.icon(
              onPressed: disabled
                  ? null
                  : () => _setStatusForAll(
                        'PRESENT',
                      ),
              icon: const Icon(
                Icons.check_circle_outline,
              ),
              label:
                  const Text('Present'),
            ),
            OutlinedButton.icon(
              onPressed: disabled
                  ? null
                  : () => _setStatusForAll(
                        'ABSENT',
                      ),
              icon: const Icon(
                Icons.cancel_outlined,
              ),
              label:
                  const Text('Absent'),
            ),
            OutlinedButton.icon(
              onPressed: disabled
                  ? null
                  : () => _setStatusForAll(
                        'LATE',
                      ),
              icon: const Icon(
                Icons.schedule_outlined,
              ),
              label:
                  const Text('Late'),
            ),
            OutlinedButton.icon(
              onPressed: disabled
                  ? null
                  : () => _setStatusForAll(
                        'EXCUSED',
                      ),
              icon: const Icon(
                Icons.assignment_turned_in_outlined,
              ),
              label:
                  const Text('Excused'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(
    BuildContext context,
    int studentId,
  ) {
    final current =
        _attendance[studentId] ??
            'PRESENT';

    final theme =
        Theme.of(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        isDense: true,
        items: const [
          DropdownMenuItem(
            value: 'PRESENT',
            child: Text('Present'),
          ),
          DropdownMenuItem(
            value: 'ABSENT',
            child: Text('Absent'),
          ),
          DropdownMenuItem(
            value: 'LATE',
            child: Text('Late'),
          ),
          DropdownMenuItem(
            value: 'EXCUSED',
            child: Text('Excused'),
          ),
        ],
        onChanged:
            widget.isSaving ||
                    widget.isLoading
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }

                    _setStudentStatus(
                      studentId,
                      value,
                    );
                  },
        selectedItemBuilder:
            (context) {
          return const [
            Text('Present'),
            Text('Absent'),
            Text('Late'),
            Text('Excused'),
          ];
        },
        style: theme
            .textTheme
            .bodyMedium
            ?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildStudentTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (_visibleStudents.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 48,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 54,
                  color: theme.colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No students available',
                  style: theme.textTheme
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
                  _selectedSubjectId == null
                      ? 'Select a subject to load its students.'
                      : 'No students are available for the selected subject and date.',
                  textAlign:
                      TextAlign.center,
                  style: theme.textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme.colorScheme
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
              label: Text(
                '#',
              ),
            ),
            DataColumn(
              label: Text(
                'Student',
              ),
            ),
            DataColumn(
              label: Text(
                'Roll Number',
              ),
            ),
            DataColumn(
              label: Text(
                'Section',
              ),
            ),
            DataColumn(
              label: Text(
                'Current',
              ),
            ),
            DataColumn(
              label: Text(
                'Mark Attendance',
              ),
            ),
          ],
          rows: _visibleStudents
              .asMap()
              .entries
              .map(
                (entry) {
                  final index =
                      entry.key;
                  final student =
                      entry.value;

                  final status =
                      _attendance[
                              student
                                  .studentId] ??
                          'PRESENT';

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${index + 1}',
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 230,
                          child: Column(
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
                                maxLines: 1,
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
                              if (student
                                  .email
                                  .isNotEmpty)
                                Text(
                                  student.email,
                                  maxLines: 1,
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
                      ),
                      DataCell(
                        Text(
                          student.rollNo,
                        ),
                      ),
                      DataCell(
                        Text(
                          student.sectionName ??
                              '—',
                        ),
                      ),
                      DataCell(
                        _buildStatusBadge(
                          context,
                          status,
                        ),
                      ),
                      DataCell(
                        _buildStatusSelector(
                          context,
                          student.studentId,
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

  Widget _buildFeedback(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (widget.errorMessage != null &&
        widget.errorMessage!
            .trim()
            .isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.colorScheme
              .errorContainer
              .withValues(
            alpha: 0.55,
          ),
          borderRadius:
              BorderRadius.circular(10),
        ),
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
              width: 9,
            ),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style:
                    theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.successMessage != null &&
        widget.successMessage!
            .trim()
            .isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color:
              Colors.green.withValues(
            alpha: 0.08,
          ),
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(
              width: 9,
            ),
            Expanded(
              child: Text(
                widget.successMessage!,
                style:
                    theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
            const Text('Mark Attendance'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed:
              widget.isSaving
                  ? null
                  : widget.onBack ??
                      () =>
                          Navigator.of(
                            context,
                          ).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh students',
            onPressed:
                widget.isLoading ||
                        widget.isSaving ||
                        _selectedSubjectId ==
                            null ||
                        widget.onLoadStudents ==
                            null
                    ? null
                    : () =>
                        widget.onLoadStudents!(
                          _selectedSubjectId!,
                          _selectedDate,
                        ),
            icon: const Icon(
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
                    'Mark Attendance',
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
                    'Record attendance for the selected subject and class date.',
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
                          null ||
                      widget.successMessage !=
                          null) ...[
                    _buildFeedback(
                      context,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                  _buildControls(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildSummary(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildBulkActions(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildStudentTable(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme
                                .colorScheme
                                .primary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              'Attendance is submitted as a subject/date record set. '
                              'The backend should validate the faculty assignment and student membership before persisting it.',
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child:
                        FilledButton.icon(
                      onPressed:
                          widget.isSaving ||
                                  widget.isLoading
                              ? null
                              : _saveAttendance,
                      icon:
                          widget.isSaving
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
                                      .save_outlined,
                                ),
                      label: Text(
                        widget.isSaving
                            ? 'Saving...'
                            : 'Save Attendance',
                      ),
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

class MarkAttendanceRequest {
  final int subjectId;
  final DateTime date;
  final List<MarkAttendanceRecord> records;

  const MarkAttendanceRequest({
    required this.subjectId,
    required this.date,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'date': date.toIso8601String().split('T').first,
      'records': records
          .map(
            (record) => record.toJson(),
          )
          .toList(),
    };
  }
}

class MarkAttendanceRecord {
  final int studentId;
  final String status;

  const MarkAttendanceRecord({
    required this.studentId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status,
    };
  }
}

class MarkAttendanceStudent {
  final int studentId;
  final String name;
  final String rollNo;
  final String email;
  final String? sectionName;
  final String? initialStatus;

  const MarkAttendanceStudent({
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.email,
    this.sectionName,
    this.initialStatus,
  });

  factory MarkAttendanceStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    final student =
        json['student'];

    final section =
        json['section'];

    return MarkAttendanceStudent(
      studentId:
          _toInt(
                json['student_id'],
              ) ??
              _toInt(
                json['id'],
              ) ??
              (student is Map
                  ? _toInt(student['id']) ??
                      0
                  : 0),
      name: student is Map
          ? student['name']?.toString() ?? ''
          : json['name']?.toString() ?? '',
      rollNo: student is Map
          ? student['roll_no']?.toString() ?? ''
          : json['roll_no']?.toString() ?? '',
      email: student is Map
          ? student['email']?.toString() ?? ''
          : json['email']?.toString() ?? '',
      sectionName: section is Map
          ? section['name']?.toString()
          : json['section_name']?.toString(),
      initialStatus:
          json['status']?.toString(),
    );
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

class MarkAttendanceSubjectOption {
  final int id;
  final String code;
  final String name;

  const MarkAttendanceSubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });
}