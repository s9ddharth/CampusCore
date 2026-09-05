import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final List<AttendanceRecord> records;
  final List<AttendanceStudentOption> students;
  final List<AttendanceSubjectOption> subjects;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final Future<void> Function(
    AttendanceSaveData data,
  )? onSave;

  const AttendancePage({
    super.key,
    this.records = const [],
    this.students = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onSave,
  });

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _formKey = GlobalKey<FormState>();

  AttendanceStudentOption? _selectedStudent;
  AttendanceSubjectOption? _selectedSubject;

  DateTime _selectedDate = DateTime.now();
  AttendanceStatus _selectedStatus =
      AttendanceStatus.present;

  String _semesterFilter = 'All';
  String _subjectFilter = 'All';

  @override
  void initState() {
    super.initState();

    if (widget.students.isNotEmpty) {
      _selectedStudent = widget.students.first;
    }

    if (widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.first;
    }
  }

  @override
  void didUpdateWidget(
    covariant AttendancePage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (_selectedStudent != null &&
        !widget.students.any(
          (student) =>
              student.id == _selectedStudent!.id,
        )) {
      _selectedStudent = widget.students.isEmpty
          ? null
          : widget.students.first;
    }

    if (_selectedSubject != null &&
        !widget.subjects.any(
          (subject) =>
              subject.id == _selectedSubject!.id,
        )) {
      _selectedSubject = widget.subjects.isEmpty
          ? null
          : widget.subjects.first;
    }
  }

  List<String> get _semesterOptions {
    final semesters = widget.records
        .map((record) => record.semester)
        .where((semester) => semester > 0)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...semesters.map(
        (semester) => semester.toString(),
      ),
    ];
  }

  List<String> get _subjectOptions {
    final subjects = widget.records
        .map(
          (record) => record.subjectName.trim(),
        )
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return [
      'All',
      ...subjects,
    ];
  }

  List<AttendanceRecord> get _filteredRecords {
    return widget.records.where((record) {
      final semesterMatches =
          _semesterFilter == 'All' ||
          record.semester.toString() ==
              _semesterFilter;

      final subjectMatches =
          _subjectFilter == 'All' ||
          record.subjectName == _subjectFilter;

      return semesterMatches && subjectMatches;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _pickDate() async {
    if (widget.isLoading) {
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _saveAttendance() async {
    if (widget.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudent == null) {
      _showError('Select a student.');
      return;
    }

    if (_selectedSubject == null) {
      _showError('Select a subject.');
      return;
    }

    final data = AttendanceSaveData(
      studentId: _selectedStudent!.id,
      subjectId: _selectedSubject!.id,
      date: _selectedDate,
      status: _selectedStatus,
    );

    if (widget.onSave != null) {
      await widget.onSave!(data);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Color _statusColor(
    BuildContext context,
    AttendanceStatus status,
  ) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Theme.of(context).colorScheme.error;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  IconData _statusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.late:
        return Icons.schedule_outlined;
      case AttendanceStatus.excused:
        return Icons.event_available_outlined;
    }
  }

  Widget _statusChoice(
    BuildContext context,
    AttendanceStatus status,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(context, status);
    final selected = _selectedStatus == status;

    return Expanded(
      child: InkWell(
        onTap: widget.isLoading
            ? null
            : () {
                setState(() {
                  _selectedStatus = status;
                });
              },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 160,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.10)
                : theme.colorScheme.surface,
            border: Border.all(
              color: selected
                  ? color
                  : theme.colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                _statusIcon(status),
                color: selected
                    ? color
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                _statusLabel(status),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? color
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryForm(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fact_check_outlined,
                      color:
                          theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mark Attendance',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Record attendance for a student and subject.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      constraints.maxWidth < 650;

                  final studentField =
                      DropdownButtonFormField<int>(
                    initialValue:
                        _selectedStudent?.id,
                    decoration: const InputDecoration(
                      labelText: 'Student',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.students
                        .map(
                          (student) =>
                              DropdownMenuItem<int>(
                            value: student.id,
                            child: Text(
                              student.rollNo.isEmpty
                                  ? student.name
                                  : '${student.name} (${student.rollNo})',
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.isLoading
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            final student =
                                widget.students.firstWhere(
                              (item) =>
                                  item.id == value,
                            );

                            setState(() {
                              _selectedStudent =
                                  student;
                            });
                          },
                    validator: (_) {
                      return _selectedStudent == null
                          ? 'Select a student'
                          : null;
                    },
                  );

                  final subjectField =
                      DropdownButtonFormField<int>(
                    initialValue:
                        _selectedSubject?.id,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.subjects
                        .map(
                          (subject) =>
                              DropdownMenuItem<int>(
                            value: subject.id,
                            child: Text(
                              subject.code.isEmpty
                                  ? subject.name
                                  : '${subject.code} - ${subject.name}',
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.isLoading
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            final subject =
                                widget.subjects.firstWhere(
                              (item) =>
                                  item.id == value,
                            );

                            setState(() {
                              _selectedSubject =
                                  subject;
                            });
                          },
                    validator: (_) {
                      return _selectedSubject == null
                          ? 'Select a subject'
                          : null;
                    },
                  );

                  final dateField = InkWell(
                    onTap: widget.isLoading
                        ? null
                        : _pickDate,
                    borderRadius:
                        BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      child: Text(
                        _formatDate(_selectedDate),
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      children: [
                        studentField,
                        const SizedBox(height: 12),
                        subjectField,
                        const SizedBox(height: 12),
                        dateField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: studentField),
                      const SizedBox(width: 12),
                      Expanded(child: subjectField),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 180,
                        child: dateField,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Attendance Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statusChoice(
                    context,
                    AttendanceStatus.present,
                  ),
                  const SizedBox(width: 8),
                  _statusChoice(
                    context,
                    AttendanceStatus.absent,
                  ),
                  const SizedBox(width: 8),
                  _statusChoice(
                    context,
                    AttendanceStatus.late,
                  ),
                  const SizedBox(width: 8),
                  _statusChoice(
                    context,
                    AttendanceStatus.excused,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : _saveAttendance,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                        ),
                  label: Text(
                    widget.isLoading
                        ? 'Saving...'
                        : 'Save Attendance',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    AttendanceRecord record,
  ) {
    final theme = Theme.of(context);
    final color = _statusColor(
      context,
      record.status,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              color.withValues(alpha: 0.10),
          foregroundColor: color,
          child: Icon(
            _statusIcon(record.status),
            size: 20,
          ),
        ),
        title: Text(
          record.studentName.isEmpty
              ? 'Unknown Student'
              : record.studentName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${record.subjectName} • '
            '${_formatDate(record.date)}',
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            _statusLabel(record.status),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecords(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final filtered = _filteredRecords;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Records',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${filtered.length} '
                        '${filtered.length == 1 ? 'record' : 'records'}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: widget.isLoading
                      ? null
                      : widget.onRefresh,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < 650;

                final semester =
                    DropdownButtonFormField<String>(
                  initialValue: _semesterFilter,
                  decoration:
                      const InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(),
                  ),
                  items: _semesterOptions
                      .map(
                        (value) =>
                            DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'All'
                                ? 'All Semesters'
                                : 'Semester $value',
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

                final subject =
                    DropdownButtonFormField<String>(
                  initialValue: _subjectFilter,
                  decoration:
                      const InputDecoration(
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

                if (compact) {
                  return Column(
                    children: [
                      semester,
                      const SizedBox(height: 10),
                      subject,
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: semester,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 250,
                      child: subject,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 42,
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No attendance records available.',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: theme.colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map(
                (record) => _buildRecordCard(
                  context,
                  record,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed: widget.isLoading
                  ? null
                  : widget.onRefresh,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Management',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Record and review student attendance by subject and date.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
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
                  _buildEntryForm(context),
                  const SizedBox(height: 24),
                  _buildRecords(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}

class AttendanceStudentOption {
  final int id;
  final String name;
  final String rollNo;

  const AttendanceStudentOption({
    required this.id,
    required this.name,
    this.rollNo = '',
  });
}

class AttendanceSubjectOption {
  final int id;
  final String name;
  final String code;
  final int semester;

  const AttendanceSubjectOption({
    required this.id,
    required this.name,
    this.code = '',
    this.semester = 0,
  });
}

class AttendanceRecord {
  final int id;
  final int? studentId;
  final String studentName;
  final String rollNo;
  final int? subjectId;
  final String subjectName;
  final DateTime date;
  final AttendanceStatus status;
  final int semester;

  const AttendanceRecord({
    required this.id,
    this.studentId,
    this.studentName = '',
    this.rollNo = '',
    this.subjectId,
    this.subjectName = '',
    required this.date,
    this.status = AttendanceStatus.present,
    this.semester = 0,
  });
}

class AttendanceSaveData {
  final int studentId;
  final int subjectId;
  final DateTime date;
  final AttendanceStatus status;

  const AttendanceSaveData({
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'subject_id': subjectId,
      'date': date.toIso8601String().split('T').first,
      'status': status.name,
    };
  }
}