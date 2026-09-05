import 'package:flutter/material.dart';

class MarksInputGrid extends StatefulWidget {
  final List<MarksInputRow> rows;
  final bool isLoading;
  final bool readOnly;
  final String submitLabel;
  final Future<void> Function(List<MarksInputValue> values)? onSubmit;

  const MarksInputGrid({
    super.key,
    required this.rows,
    this.isLoading = false,
    this.readOnly = false,
    this.submitLabel = 'Save Marks',
    this.onSubmit,
  });

  @override
  State<MarksInputGrid> createState() => _MarksInputGridState();
}

class _MarksInputGridState extends State<MarksInputGrid> {
  final _formKey = GlobalKey<FormState>();
  late List<_MarksRowState> _rowStates;

  @override
  void initState() {
    super.initState();
    _initializeRows();
  }

  @override
  void didUpdateWidget(covariant MarksInputGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rows != widget.rows) {
      _disposeRows();
      _initializeRows();
    }
  }

  void _initializeRows() {
    _rowStates = widget.rows.map(_MarksRowState.fromRow).toList();
  }

  void _disposeRows() {
    for (final row in _rowStates) {
      row.dispose();
    }
  }

  @override
  void dispose() {
    _disposeRows();
    super.dispose();
  }

  double? _parseMarks(String value) {
    return double.tryParse(value.trim());
  }

  Future<void> _save() async {
    if (widget.readOnly || widget.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final values = <MarksInputValue>[];

    for (final row in _rowStates) {
      final value = MarksInputValue(
        studentId: row.studentId,
        studentName: row.studentName,
        rollNo: row.rollNo,
        cat1: _parseMarks(row.cat1Controller.text),
        cat2: _parseMarks(row.cat2Controller.text),
        tee: _parseMarks(row.teeController.text),
        internals: _parseMarks(row.internalsController.text),
      );

      values.add(value);
    }

    if (widget.onSubmit != null) {
      await widget.onSubmit!(values);
    }
  }

  String? _validateMarks(
    String? value,
    double maximum,
    String label,
  ) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final marks = _parseMarks(value);

    if (marks == null) {
      return 'Enter a valid number';
    }

    if (marks < 0) {
      return '$label cannot be negative';
    }

    if (marks > maximum) {
      return 'Max $maximum';
    }

    return null;
  }

  Widget _buildMarksField({
    required TextEditingController controller,
    required String label,
    required double maximum,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !widget.readOnly && !widget.isLoading,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0-$maximum',
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => _validateMarks(
        value,
        maximum,
        label,
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    final theme = Theme.of(context);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.3),
        1: FlexColumnWidth(1.2),
        2: FixedColumnWidth(110),
        3: FixedColumnWidth(110),
        4: FixedColumnWidth(110),
        5: FixedColumnWidth(110),
      },
      border: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          children: [
            _headerCell(context, 'Student'),
            _headerCell(context, 'Roll No.'),
            _headerCell(context, 'CAT 1 / 50'),
            _headerCell(context, 'CAT 2 / 50'),
            _headerCell(context, 'TEE / 100'),
            _headerCell(context, 'Internals / 20'),
          ],
        ),
        ..._rowStates.map(
          (row) => TableRow(
            children: [
              _studentCell(
                context,
                row,
              ),
              _textCell(
                context,
                row.rollNo,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildMarksField(
                  controller: row.cat1Controller,
                  label: 'CAT 1',
                  maximum: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildMarksField(
                  controller: row.cat2Controller,
                  label: 'CAT 2',
                  maximum: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildMarksField(
                  controller: row.teeController,
                  label: 'TEE',
                  maximum: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildMarksField(
                  controller: row.internalsController,
                  label: 'Internals',
                  maximum: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return Column(
      children: List.generate(
        _rowStates.length,
        (index) => _buildMobileStudentCard(
          context,
          _rowStates[index],
          index,
        ),
      ),
    );
  }

  Widget _buildMobileStudentCard(
    BuildContext context,
    _MarksRowState row,
    int index,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    '${index + 1}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.studentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.rollNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;

                if (compact) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMarksField(
                              controller: row.cat1Controller,
                              label: 'CAT 1',
                              maximum: 50,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMarksField(
                              controller: row.cat2Controller,
                              label: 'CAT 2',
                              maximum: 50,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMarksField(
                              controller: row.teeController,
                              label: 'TEE',
                              maximum: 100,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMarksField(
                              controller: row.internalsController,
                              label: 'Internals',
                              maximum: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMarksField(
                            controller: row.cat1Controller,
                            label: 'CAT 1',
                            maximum: 50,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMarksField(
                            controller: row.cat2Controller,
                            label: 'CAT 2',
                            maximum: 50,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMarksField(
                            controller: row.teeController,
                            label: 'TEE',
                            maximum: 100,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMarksField(
                            controller: row.internalsController,
                            label: 'Internals',
                            maximum: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _studentCell(
    BuildContext context,
    _MarksRowState row,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              row.studentName.isEmpty
                  ? '?'
                  : row.studentName[0].toUpperCase(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.studentName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCell(
    BuildContext context,
    String text,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No students available.',
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return _buildMobileList(context);
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 860,
                  child: _buildDesktopTable(context),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (!widget.readOnly)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: widget.isLoading ? null : _save,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  widget.isLoading
                      ? 'Saving...'
                      : widget.submitLabel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MarksInputRow {
  final int studentId;
  final String studentName;
  final String rollNo;
  final double? cat1;
  final double? cat2;
  final double? tee;
  final double? internals;

  const MarksInputRow({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.cat1,
    this.cat2,
    this.tee,
    this.internals,
  });
}

class MarksInputValue {
  final int studentId;
  final String studentName;
  final String rollNo;
  final double? cat1;
  final double? cat2;
  final double? tee;
  final double? internals;

  const MarksInputValue({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.cat1,
    this.cat2,
    this.tee,
    this.internals,
  });

  double get rawTotal {
    return (cat1 ?? 0) +
        (cat2 ?? 0) +
        (tee ?? 0) +
        (internals ?? 0);
  }

  bool get hasMissingMarks {
    return cat1 == null ||
        cat2 == null ||
        tee == null ||
        internals == null;
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'cat1': cat1,
      'cat2': cat2,
      'tee': tee,
      'internals': internals,
    };
  }
}

class _MarksRowState {
  final int studentId;
  final String studentName;
  final String rollNo;

  final TextEditingController cat1Controller;
  final TextEditingController cat2Controller;
  final TextEditingController teeController;
  final TextEditingController internalsController;

  _MarksRowState({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.cat1Controller,
    required this.cat2Controller,
    required this.teeController,
    required this.internalsController,
  });

  factory _MarksRowState.fromRow(MarksInputRow row) {
    return _MarksRowState(
      studentId: row.studentId,
      studentName: row.studentName,
      rollNo: row.rollNo,
      cat1Controller: TextEditingController(
        text: row.cat1?.toString() ?? '',
      ),
      cat2Controller: TextEditingController(
        text: row.cat2?.toString() ?? '',
      ),
      teeController: TextEditingController(
        text: row.tee?.toString() ?? '',
      ),
      internalsController: TextEditingController(
        text: row.internals?.toString() ?? '',
      ),
    );
  }

  void dispose() {
    cat1Controller.dispose();
    cat2Controller.dispose();
    teeController.dispose();
    internalsController.dispose();
  }
}