import 'package:flutter/material.dart';

class MarksEntryPage extends StatefulWidget {
  final List<MarksEntryStudent> students;
  final List<MarksEntrySubjectOption> subjects;
  final List<MarksEntryAssessmentOption> assessments;

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final Future<void> Function(
    MarksEntrySaveRequest request,
  )? onSave;

  final Future<void> Function(
    int subjectId,
    int assessmentId,
  )? onLoadStudents;

  final VoidCallback? onBack;

  const MarksEntryPage({
    super.key,
    this.students = const [],
    this.subjects = const [],
    this.assessments = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.onSave,
    this.onLoadStudents,
    this.onBack,
  });

  @override
  State<MarksEntryPage> createState() =>
      _MarksEntryPageState();
}

class _MarksEntryPageState
    extends State<MarksEntryPage> {
  int? _selectedSubjectId;
  int? _selectedAssessmentId;

  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String?> _errors = {};

  @override
  void initState() {
    super.initState();

    _selectedSubjectId =
        widget.subjects.isNotEmpty
            ? widget.subjects.first.id
            : null;

    _selectedAssessmentId =
        widget.assessments.isNotEmpty
            ? widget.assessments.first.id
            : null;

    _syncControllers();
  }

  @override
  void didUpdateWidget(
    covariant MarksEntryPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.students != widget.students) {
      _syncControllers();
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

    if (_selectedAssessmentId != null &&
        !widget.assessments.any(
          (assessment) =>
              assessment.id ==
              _selectedAssessmentId,
        )) {
      _selectedAssessmentId =
          widget.assessments.isEmpty
              ? null
              : widget.assessments.first.id;
    }
  }

  void _syncControllers() {
    final studentIds = widget.students
        .map(
          (student) => student.studentId,
        )
        .toSet();

    final oldIds = _controllers.keys.toList();

    for (final id in oldIds) {
      if (!studentIds.contains(id)) {
        _controllers[id]?.dispose();
        _controllers.remove(id);
      }
    }

    for (final student in widget.students) {
      if (!_controllers.containsKey(student.studentId)) {
        _controllers[student.studentId] =
            TextEditingController(
          text: student.marks == null
              ? ''
              : _formatMarks(student.marks!),
        );
      } else if (student.marks != null &&
          _controllers[student.studentId]!.text.isEmpty) {
        _controllers[student.studentId]!.text =
            _formatMarks(student.marks!);
      }
    }
  }

  String _formatMarks(
    double marks,
  ) {
    if (marks == marks.roundToDouble()) {
      return marks.toInt().toString();
    }

    return marks.toStringAsFixed(2);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double? _parseMarks(
    String value,
  ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return double.tryParse(trimmed);
  }

  MarksEntryAssessmentOption?
      get _selectedAssessment {
    for (final assessment in widget.assessments) {
      if (assessment.id == _selectedAssessmentId) {
        return assessment;
      }
    }

    return null;
  }

  int get _enteredCount {
    return _controllers.values
        .where(
          (controller) =>
              controller.text.trim().isNotEmpty,
        )
        .length;
  }

  int get _validCount {
    final maxMarks =
        _selectedAssessment?.maxMarks;

    if (maxMarks == null) {
      return _enteredCount;
    }

    return _controllers.values.where(
      (controller) {
        final value =
            _parseMarks(controller.text);

        return value != null &&
            value >= 0 &&
            value <= maxMarks;
      },
    ).length;
  }

  void _onSubjectChanged(
    int? value,
  ) {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedSubjectId = value;
      _errors.clear();
    });
  }

  Future<void> _onAssessmentChanged(
    int? value,
  ) async {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedAssessmentId = value;
      _errors.clear();
    });

    if (_selectedSubjectId != null &&
        widget.onLoadStudents != null) {
      await widget.onLoadStudents!(
        _selectedSubjectId!,
        value,
      );
    }
  }

  void _setAllMarks(
    String value,
  ) {
    if (widget.isLoading || widget.isSaving) {
      return;
    }

    for (final controller in _controllers.values) {
      controller.text = value;
    }

    setState(() {
      _errors.clear();
    });
  }

  void _validateStudent(
    MarksEntryStudent student,
  ) {
    final controller =
        _controllers[student.studentId];

    if (controller == null) {
      return;
    }

    final value =
        _parseMarks(controller.text);

    final maxMarks =
        _selectedAssessment?.maxMarks;

    String? error;

    if (controller.text.trim().isEmpty) {
      error = 'Required';
    } else if (value == null) {
      error = 'Invalid mark';
    } else if (value < 0) {
      error = 'Cannot be negative';
    } else if (maxMarks != null &&
        value > maxMarks) {
      error =
          'Maximum is ${_formatMarks(maxMarks)}';
    }

    setState(() {
      _errors[student.studentId] = error;
    });
  }

  bool _validateAll() {
    bool valid = true;

    final maxMarks =
        _selectedAssessment?.maxMarks;

    final newErrors = <int, String?>{};

    for (final student in widget.students) {
      final controller =
          _controllers[student.studentId];

      if (controller == null) {
        newErrors[student.studentId] =
            'Required';
        valid = false;
        continue;
      }

      final text =
          controller.text.trim();

      final value =
          _parseMarks(text);

      String? error;

      if (text.isEmpty) {
        error = 'Required';
      } else if (value == null) {
        error = 'Invalid mark';
      } else if (value < 0) {
        error = 'Cannot be negative';
      } else if (maxMarks != null &&
          value > maxMarks) {
        error =
            'Maximum is ${_formatMarks(maxMarks)}';
      }

      newErrors[student.studentId] =
          error;

      if (error != null) {
        valid = false;
      }
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(newErrors);
    });

    return valid;
  }

  Future<void> _saveMarks() async {
    if (widget.isLoading || widget.isSaving) {
      return;
    }

    if (_selectedSubjectId == null) {
      _showMessage(
        'Select a subject first.',
      );
      return;
    }

    if (_selectedAssessmentId == null) {
      _showMessage(
        'Select an assessment first.',
      );
      return;
    }

    if (widget.students.isEmpty) {
      _showMessage(
        'There are no students available for marks entry.',
      );
      return;
    }

    if (!_validateAll()) {
      _showMessage(
        'Please correct the invalid marks before saving.',
      );
      return;
    }

    final records = <MarksEntryRecord>[];

    for (final student in widget.students) {
      final controller =
          _controllers[student.studentId];

      final value =
          _parseMarks(controller!.text)!;

      records.add(
        MarksEntryRecord(
          studentId: student.studentId,
          marks: value,
        ),
      );
    }

    final request = MarksEntrySaveRequest(
      subjectId: _selectedSubjectId!,
      assessmentId: _selectedAssessmentId!,
      records: records,
    );

    if (widget.onSave != null) {
      await widget.onSave!(request);
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

  Widget _buildFeedback(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    if (widget.errorMessage != null &&
        widget.errorMessage!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.successMessage != null &&
        widget.successMessage!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.green.withValues(
            alpha: 0.08,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.successMessage!,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
              initialValue:
                  _selectedSubjectId,
              decoration:
                  const InputDecoration(
                labelText: 'Subject',
                prefixIcon:
                    Icon(
                  Icons.menu_book_outlined,
                ),
                border:
                    OutlineInputBorder(),
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

            final assessmentDropdown =
                DropdownButtonFormField<int>(
              initialValue:
                  _selectedAssessmentId,
              decoration:
                  const InputDecoration(
                labelText: 'Assessment',
                prefixIcon:
                    Icon(
                  Icons.assignment_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: widget.assessments
                  .map(
                    (assessment) =>
                        DropdownMenuItem<int>(
                      value: assessment.id,
                      child: Text(
                        '${assessment.name} • Max ${_formatMarks(assessment.maxMarks)}',
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
                      : _onAssessmentChanged,
            );

            if (compact) {
              return Column(
                children: [
                  subjectDropdown,
                  const SizedBox(height: 12),
                  assessmentDropdown,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: subjectDropdown,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: assessmentDropdown,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final maxMarks =
        _selectedAssessment?.maxMarks;

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
            title: 'Students',
            value:
                widget.students.length.toString(),
            icon:
                Icons.people_outline,
          ),
          _buildSummaryCard(
            context,
            title: 'Entered',
            value:
                _enteredCount.toString(),
            icon:
                Icons.edit_note_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Valid',
            value:
                _validCount.toString(),
            icon:
                Icons.check_circle_outline,
          ),
          _buildSummaryCard(
            context,
            title: 'Maximum',
            value: maxMarks == null
                ? '—'
                : _formatMarks(maxMarks),
            icon:
                Icons.score_outlined,
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

  Widget _buildBulkActions(
    BuildContext context,
  ) {
    final maxMarks =
        _selectedAssessment?.maxMarks;

    final enabled =
        !widget.isLoading &&
            !widget.isSaving &&
            maxMarks != null;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment:
              WrapCrossAlignment.center,
          children: [
            Text(
              'Quick fill:',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            OutlinedButton.icon(
              onPressed: enabled
                  ? () => _setAllMarks('0')
                  : null,
              icon:
                  const Icon(
                Icons.exposure_zero,
              ),
              label:
                  const Text(
                'Set 0',
              ),
            ),
            OutlinedButton.icon(
              onPressed: enabled
                  ? () => _setAllMarks(
                        _formatMarks(
                          maxMarks / 2,
                        ),
                      )
                  : null,
              icon:
                  const Icon(
                Icons.horizontal_rule,
              ),
              label:
                  const Text(
                'Set 50%',
              ),
            ),
            OutlinedButton.icon(
              onPressed: enabled
                  ? () => _setAllMarks(
                        _formatMarks(maxMarks),
                      )
                  : null,
              icon:
                  const Icon(
                Icons.check,
              ),
              label:
                  const Text(
                'Set maximum',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksField(
    BuildContext context,
    MarksEntryStudent student,
  ) {
    final controller =
        _controllers[student.studentId];

    if (controller == null) {
      return const SizedBox.shrink();
    }

    final error =
        _errors[student.studentId];

    final maxMarks =
        _selectedAssessment?.maxMarks;

    return SizedBox(
      width: 170,
      child: TextField(
        controller: controller,
        enabled:
            !widget.isLoading &&
                !widget.isSaving,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        textAlign: TextAlign.center,
        onChanged: (_) {
          if (_errors.containsKey(
                student.studentId,
              ) &&
              _errors[student.studentId] !=
                  null) {
            _validateStudent(
              student,
            );
          } else {
            setState(() {});
          }
        },
        decoration:
            InputDecoration(
          labelText:
              maxMarks == null
                  ? 'Marks'
                  : 'Max ${_formatMarks(maxMarks)}',
          errorText:
              error,
          suffixText:
              maxMarks == null
                  ? null
                  : '/ ${_formatMarks(maxMarks)}',
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (widget.students.isEmpty) {
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
                  Icons
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
                  'No students available',
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
                  _selectedSubjectId == null ||
                          _selectedAssessmentId ==
                              null
                      ? 'Select a subject and assessment to load students.'
                      : 'No students are available for this selection.',
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
                  Text('#'),
            ),
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
                  Text('Section'),
            ),
            DataColumn(
              label:
                  Text('Previous Marks'),
            ),
            DataColumn(
              label:
                  Text('Marks'),
            ),
          ],
          rows: widget.students
              .asMap()
              .entries
              .map(
                (entry) {
                  final index =
                      entry.key;

                  final student =
                      entry.value;

                  final currentController =
                      _controllers[
                          student.studentId];

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${index + 1}',
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 240,
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
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
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
                        Text(
                          student.marks == null
                              ? '—'
                              : _formatMarks(
                                  student.marks!,
                                ),
                        ),
                      ),
                      DataCell(
                        currentController == null
                            ? const Text('—')
                            : _buildMarksField(
                                context,
                                student,
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Marks Entry'),
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
            tooltip:
                'Reload students',
            onPressed:
                widget.isLoading ||
                        widget.isSaving ||
                        _selectedSubjectId ==
                            null ||
                        _selectedAssessmentId ==
                            null ||
                        widget.onLoadStudents ==
                            null
                    ? null
                    : () =>
                        widget.onLoadStudents!(
                          _selectedSubjectId!,
                          _selectedAssessmentId!,
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
                    'Marks Entry',
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
                    'Enter assessment marks for students in your assigned class.',
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
                  _buildTable(
                    context,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .end,
                    children: [
                      OutlinedButton(
                        onPressed:
                            widget.isSaving
                                ? null
                                : widget.onBack ??
                                    () =>
                                        Navigator.of(
                                          context,
                                        ).maybePop(),
                        child:
                            const Text(
                          'Cancel',
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      FilledButton.icon(
                        onPressed:
                            widget.isLoading ||
                                    widget.isSaving
                                ? null
                                : _saveMarks,
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
                              : 'Save Marks',
                        ),
                      ),
                    ],
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

class MarksEntrySaveRequest {
  final int subjectId;
  final int assessmentId;
  final List<MarksEntryRecord> records;

  const MarksEntrySaveRequest({
    required this.subjectId,
    required this.assessmentId,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'assessment_id': assessmentId,
      'records': records
          .map(
            (record) => record.toJson(),
          )
          .toList(),
    };
  }
}

class MarksEntryRecord {
  final int studentId;
  final double marks;

  const MarksEntryRecord({
    required this.studentId,
    required this.marks,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'marks': marks,
    };
  }
}

class MarksEntryStudent {
  final int studentId;
  final String name;
  final String rollNo;
  final String email;
  final String? sectionName;
  final double? marks;

  const MarksEntryStudent({
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.email,
    this.sectionName,
    this.marks,
  });

  factory MarksEntryStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    final student =
        json['student'];

    final section =
        json['section'];

    return MarksEntryStudent(
      studentId:
          _toInt(json['student_id']) ??
              _toInt(json['id']) ??
              (student is Map
                  ? _toInt(student['id']) ?? 0
                  : 0),
      name:
          student is Map
              ? student['name']?.toString() ?? ''
              : json['name']?.toString() ?? '',
      rollNo:
          student is Map
              ? student['roll_no']?.toString() ?? ''
              : json['roll_no']?.toString() ?? '',
      email:
          student is Map
              ? student['email']?.toString() ?? ''
              : json['email']?.toString() ?? '',
      sectionName:
          section is Map
              ? section['name']?.toString()
              : json['section_name']?.toString(),
      marks:
          _toDouble(json['marks']),
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

class MarksEntrySubjectOption {
  final int id;
  final String code;
  final String name;

  const MarksEntrySubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });
}

class MarksEntryAssessmentOption {
  final int id;
  final String name;
  final double maxMarks;
  final double? weightage;
  final int? sequence;

  const MarksEntryAssessmentOption({
    required this.id,
    required this.name,
    required this.maxMarks,
    this.weightage,
    this.sequence,
  });
}