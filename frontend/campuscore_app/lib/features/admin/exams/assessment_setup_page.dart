import 'package:flutter/material.dart';

class AssessmentSetupPage extends StatefulWidget {
  final List<AssessmentSetupItem> assessments;
  final List<AssessmentSubjectOption> subjects;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final Future<void> Function(
    AssessmentSetupData data,
  )? onSave;
  final void Function(AssessmentSetupItem item)? onEdit;
  final void Function(AssessmentSetupItem item)? onDelete;

  const AssessmentSetupPage({
    super.key,
    this.assessments = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onSave,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AssessmentSetupPage> createState() =>
      _AssessmentSetupPageState();
}

class _AssessmentSetupPageState
    extends State<AssessmentSetupPage> {
  final _formKey = GlobalKey<FormState>();

  AssessmentSubjectOption? _selectedSubject;
  String _assessmentType = 'CAT1';
  DateTime? _selectedDate;

  final TextEditingController _maxMarksController =
      TextEditingController();

  final TextEditingController _weightController =
      TextEditingController();

  bool _isMandatory = true;
  String _statusFilter = 'All';
  String _subjectFilter = 'All';

  @override
  void initState() {
    super.initState();

    if (widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.first;
    }

    _maxMarksController.text = '50';
    _weightController.text = '25';
  }

  @override
  void didUpdateWidget(
    covariant AssessmentSetupPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

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

  @override
  void dispose() {
    _maxMarksController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  List<String> get _subjectOptions {
    final subjects = widget.assessments
        .map(
          (item) => item.subjectName.trim(),
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

  List<AssessmentSetupItem> get _filteredAssessments {
    return widget.assessments.where((item) {
      final statusMatches =
          _statusFilter == 'All' ||
          item.status.toLowerCase() ==
              _statusFilter.toLowerCase();

      final subjectMatches =
          _subjectFilter == 'All' ||
          item.subjectName == _subjectFilter;

      return statusMatches && subjectMatches;
    }).toList();
  }

  void _updateDefaultsForType(String type) {
    setState(() {
      _assessmentType = type;

      switch (type) {
        case 'CAT1':
        case 'CAT2':
          _maxMarksController.text = '50';
          _weightController.text = '25';
          break;

        case 'TEE':
          _maxMarksController.text = '100';
          _weightController.text = '50';
          break;

        case 'INTERNAL':
          _maxMarksController.text = '20';
          _weightController.text = '10';
          break;

        default:
          _maxMarksController.clear();
          _weightController.clear();
      }
    });
  }

  Future<void> _pickDate() async {
    if (widget.isLoading) {
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not scheduled';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim());
  }

  Future<void> _save() async {
    if (widget.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubject == null) {
      _showError('Select a subject.');
      return;
    }

    final maxMarks =
        _parseDouble(_maxMarksController.text);
    final weight =
        _parseDouble(_weightController.text);

    if (maxMarks == null || maxMarks <= 0) {
      _showError('Enter a valid maximum mark.');
      return;
    }

    if (weight == null ||
        weight < 0 ||
        weight > 100) {
      _showError(
        'Assessment weight must be between 0 and 100.',
      );
      return;
    }

    final data = AssessmentSetupData(
      subjectId: _selectedSubject!.id,
      assessmentType: _assessmentType,
      maxMarks: maxMarks,
      weight: weight,
      date: _selectedDate,
      isMandatory: _isMandatory,
    );

    if (widget.onSave != null) {
      await widget.onSave!(data);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Color _typeColor(
    BuildContext context,
    String type,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (type.toUpperCase()) {
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
    switch (type.toUpperCase()) {
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
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
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

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'active':
      case 'scheduled':
        return Colors.green;

      case 'draft':
      case 'pending':
        return Colors.orange;

      case 'locked':
      case 'completed':
        return scheme.primary;

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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
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
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event_note_outlined,
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
                          'Assessment Setup',
                          style:
                              theme.textTheme.titleMedium
                                  ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Configure assessment components before marks are entered.',
                          style:
                              theme.textTheme.bodySmall
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
                builder:
                    (context, constraints) {
                  final compact =
                      constraints.maxWidth < 700;

                  final subjectField =
                      DropdownButtonFormField<int>(
                    initialValue:
                        _selectedSubject?.id,
                    decoration:
                        const InputDecoration(
                      labelText: 'Subject',
                      border:
                          OutlineInputBorder(),
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
                                widget.subjects
                                    .firstWhere(
                              (item) =>
                                  item.id == value,
                            );

                            setState(() {
                              _selectedSubject =
                                  subject;
                            });
                          },
                    validator: (_) {
                      return _selectedSubject ==
                              null
                          ? 'Select a subject'
                          : null;
                    },
                  );

                  final typeField =
                      DropdownButtonFormField<String>(
                    initialValue:
                        _assessmentType,
                    decoration:
                        const InputDecoration(
                      labelText: 'Assessment Type',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
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
                    onChanged: widget.isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              _updateDefaultsForType(
                                value,
                              );
                            }
                          },
                  );

                  final maxMarksField =
                      TextFormField(
                    controller:
                        _maxMarksController,
                    enabled:
                        !widget.isLoading,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'Maximum Marks',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final parsed =
                          _parseDouble(
                        value ?? '',
                      );

                      if (parsed == null ||
                          parsed <= 0) {
                        return 'Enter a valid value';
                      }

                      return null;
                    },
                  );

                  final weightField =
                      TextFormField(
                    controller:
                        _weightController,
                    enabled:
                        !widget.isLoading,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'Weight (%)',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final parsed =
                          _parseDouble(
                        value ?? '',
                      );

                      if (parsed == null ||
                          parsed < 0 ||
                          parsed > 100) {
                        return 'Enter 0-100';
                      }

                      return null;
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
                        labelText: 'Assessment Date',
                        border:
                            OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons
                              .calendar_today_outlined,
                        ),
                      ),
                      child: Text(
                        _formatDate(
                          _selectedDate,
                        ),
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      children: [
                        subjectField,
                        const SizedBox(height: 12),
                        typeField,
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  maxMarksField,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: weightField,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        dateField,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: subjectField,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: typeField,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: maxMarksField,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: weightField,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: dateField,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title:
                    const Text('Mandatory assessment'),
                subtitle: const Text(
                  'Require marks for this assessment before results can be calculated.',
                ),
                value: _isMandatory,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _isMandatory = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : _save,
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
                        : 'Save Assessment',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            final compact =
                constraints.maxWidth < 650;

            final status =
                DropdownButtonFormField<String>(
              initialValue: _statusFilter,
              decoration:
                  const InputDecoration(
                labelText: 'Status',
                border:
                    OutlineInputBorder(),
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
                  value: 'Draft',
                  child: Text('Draft'),
                ),
                DropdownMenuItem(
                  value: 'Locked',
                  child: Text('Locked'),
                ),
                DropdownMenuItem(
                  value: 'Completed',
                  child: Text('Completed'),
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
              decoration:
                  const InputDecoration(
                labelText: 'Subject',
                border:
                    OutlineInputBorder(),
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
                  status,
                  const SizedBox(height: 10),
                  subject,
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 180,
                  child: status,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 260,
                  child: subject,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    AssessmentSetupItem item,
  ) async {
    if (widget.onDelete == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme =
            Theme.of(dialogContext);

        return AlertDialog(
          title: const Text(
            'Delete Assessment?',
          ),
          content: Text(
            'Delete ${_typeLabel(item.assessmentType)} '
            'for ${item.subjectName}? '
            'This should only be done when the assessment '
            'has not been used for finalized marks.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(false),
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.error,
                foregroundColor:
                    theme.colorScheme.onError,
              ),
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(true),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDelete!(item);
    }
  }

  Widget _assessmentCard(
    BuildContext context,
    AssessmentSetupItem item,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onEdit == null
            ? null
            : () => widget.onEdit!(item),
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _typeBadge(
                    context,
                    item.assessmentType,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subjectName.isEmpty
                              ? 'Unknown Subject'
                              : item.subjectName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme.textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        if (item.subjectCode
                            .isNotEmpty)
                          Text(
                            item.subjectCode,
                            style: theme.textTheme
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
                  _statusBadge(
                    context,
                    item.status,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _metric(
                    context,
                    label: 'Max Marks',
                    value:
                        '${item.maxMarks}',
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    label: 'Weight',
                    value:
                        '${item.weight.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    label: 'Date',
                    value:
                        _formatDate(item.date),
                  ),
                  if (item.isMandatory) ...[
                    const SizedBox(width: 8),
                    _metric(
                      context,
                      label: 'Required',
                      value: 'Yes',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  if (widget.onEdit != null)
                    TextButton.icon(
                      onPressed: () =>
                          widget.onEdit!(item),
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text(
                        'Edit',
                      ),
                    ),
                  if (widget.onDelete != null)
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () =>
                          _confirmDelete(item),
                      color: theme
                          .colorScheme
                          .error,
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

  Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme
                .colorScheme
                .outlineVariant,
          ),
          borderRadius:
              BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: theme.textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: theme.textTheme
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
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<AssessmentSetupItem> items,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      clipBehavior:
          Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStatePropertyAll(
            theme.colorScheme
                .surfaceContainerHighest,
          ),
          columns: const [
            DataColumn(
              label: Text('Subject'),
            ),
            DataColumn(
              label: Text('Type'),
            ),
            DataColumn(
              label: Text('Max Marks'),
            ),
            DataColumn(
              label: Text('Weight'),
            ),
            DataColumn(
              label: Text('Date'),
            ),
            DataColumn(
              label: Text('Required'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: items.map(
            (item) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subjectName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme.textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          if (item.subjectCode
                              .isNotEmpty)
                            Text(
                              item.subjectCode,
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
                    _typeBadge(
                      context,
                      item.assessmentType,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item.maxMarks}',
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item.weight.toStringAsFixed(1)}%',
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatDate(item.date),
                    ),
                  ),
                  DataCell(
                    Icon(
                      item.isMandatory
                          ? Icons.check
                          : Icons.remove,
                      color: item.isMandatory
                          ? Colors.green
                          : theme
                              .colorScheme
                              .onSurfaceVariant,
                    ),
                  ),
                  DataCell(
                    _statusBadge(
                      context,
                      item.status,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        if (widget.onEdit != null)
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () =>
                                widget.onEdit!(
                              item,
                            ),
                            icon:
                                const Icon(
                              Icons
                                  .edit_outlined,
                              size: 20,
                            ),
                          ),
                        if (widget.onDelete !=
                            null)
                          IconButton(
                            tooltip:
                                'Delete',
                            onPressed: () =>
                                _confirmDelete(
                              item,
                            ),
                            color: theme
                                .colorScheme
                                .error,
                            icon:
                                const Icon(
                              Icons
                                  .delete_outline,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ).toList(),
          columnSpacing: 26,
          horizontalMargin: 14,
          dataRowMinHeight: 66,
          dataRowMaxHeight: 82,
        ),
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(40),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 48,
              color: theme.colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              widget.assessments.isEmpty
                  ? 'No assessments available.'
                  : 'No assessments match the selected filters.',
              textAlign:
                  TextAlign.center,
              style: theme.textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.assessments.isEmpty
                  ? 'Create an assessment to begin the marks workflow.'
                  : 'Try changing the filters.',
              textAlign:
                  TextAlign.center,
              style: theme.textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme.colorScheme
                    .onSurfaceVariant,
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
    final theme = Theme.of(context);
    final filtered =
        _filteredAssessments;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assessment Setup',
        ),
        actions: [
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed:
                  widget.isLoading
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
                    'Assessment Setup',
                    style: theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Configure CAT, TEE and internal assessments before marks are entered.',
                    style: theme.textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.errorMessage !=
                          null &&
                      widget.errorMessage!
                          .trim()
                          .isNotEmpty)
                    Container(
                      width:
                          double.infinity,
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 16,
                      ),
                      padding:
                          const EdgeInsets
                              .all(14),
                      decoration:
                          BoxDecoration(
                        color: theme
                            .colorScheme
                            .errorContainer
                            .withValues(
                          alpha: 0.55,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                        border: Border.all(
                          color: theme
                              .colorScheme
                              .error
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .error_outline,
                            color: theme
                                .colorScheme
                                .error,
                          ),
                          const SizedBox(
                              width: 10),
                          Expanded(
                            child: Text(
                              widget
                                  .errorMessage!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildForm(context),
                  const SizedBox(height: 24),
                  _buildFilters(context),
                  const SizedBox(height: 18),
                  if (widget.isLoading &&
                      widget.assessments
                          .isEmpty)
                    const SizedBox(
                      height: 260,
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SizedBox(
                      height: 260,
                      child:
                          _buildEmpty(
                        context,
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        if (constraints
                                .maxWidth <
                            850) {
                          return Column(
                            children:
                                filtered
                                    .map(
                                      (item) =>
                                          _assessmentCard(
                                        context,
                                        item,
                                      ),
                                    )
                                    .toList(),
                          );
                        }

                        return _buildDesktopTable(
                          context,
                          filtered,
                        );
                      },
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

class AssessmentSetupItem {
  final int id;
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final String assessmentType;
  final double maxMarks;
  final double weight;
  final DateTime? date;
  final bool isMandatory;
  final String status;

  const AssessmentSetupItem({
    required this.id,
    this.subjectId,
    this.subjectName = '',
    this.subjectCode = '',
    this.assessmentType = 'CAT1',
    this.maxMarks = 0,
    this.weight = 0,
    this.date,
    this.isMandatory = true,
    this.status = 'Draft',
  });
}

class AssessmentSubjectOption {
  final int id;
  final String name;
  final String code;
  final int semester;

  const AssessmentSubjectOption({
    required this.id,
    required this.name,
    this.code = '',
    this.semester = 0,
  });
}

class AssessmentSetupData {
  final int subjectId;
  final String assessmentType;
  final double maxMarks;
  final double weight;
  final DateTime? date;
  final bool isMandatory;

  const AssessmentSetupData({
    required this.subjectId,
    required this.assessmentType,
    required this.maxMarks,
    required this.weight,
    this.date,
    this.isMandatory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'assessment_type': assessmentType,
      'max_marks': maxMarks,
      'weight': weight,
      'date': date
          ?.toIso8601String()
          .split('T')
          .first,
      'is_mandatory': isMandatory,
    };
  }
}