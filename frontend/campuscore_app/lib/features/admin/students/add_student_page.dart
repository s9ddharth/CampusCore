import 'package:flutter/material.dart';

class AddStudentPage extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  final List<StudentDepartmentOption> departments;
  final List<StudentSectionOption> sections;

  final Future<void> Function(
    AddStudentData data,
  )? onSubmit;

  final VoidCallback? onCancel;

  const AddStudentPage({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.departments = const [],
    this.sections = const [],
    this.onSubmit,
    this.onCancel,
  });

  @override
  State<AddStudentPage> createState() =>
      _AddStudentPageState();
}

class _AddStudentPageState
    extends State<AddStudentPage> {
  final _formKey =
      GlobalKey<FormState>();

  final _rollNoController =
      TextEditingController();
  final _nameController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _phoneController =
      TextEditingController();

  DateTime? _selectedDateOfBirth;
  int? _selectedDepartmentId;
  int? _selectedSectionId;
  int? _selectedSemester;
  String _status = 'ACTIVE';

  final List<int> _semesterOptions =
      List.generate(8, (index) => index + 1);

  @override
  void initState() {
    super.initState();

    _selectedDepartmentId =
        widget.departments.isNotEmpty
            ? widget.departments.first.id
            : null;

    _selectedSectionId =
        widget.sections.isNotEmpty
            ? widget.sections.first.id
            : null;
  }

  @override
  void didUpdateWidget(
    covariant AddStudentPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (_selectedDepartmentId != null &&
        !widget.departments.any(
          (department) =>
              department.id ==
              _selectedDepartmentId,
        )) {
      _selectedDepartmentId =
          widget.departments.isEmpty
              ? null
              : widget.departments.first.id;
    }

    if (_selectedSectionId != null &&
        !widget.sections.any(
          (section) =>
              section.id ==
              _selectedSectionId,
        )) {
      _selectedSectionId =
          widget.sections.isEmpty
              ? null
              : widget.sections.first.id;
    }

    if (_selectedDepartmentId == null &&
        widget.departments.isNotEmpty) {
      _selectedDepartmentId =
          widget.departments.first.id;
    }

    if (_selectedSectionId == null &&
        widget.sections.isNotEmpty) {
      _selectedSectionId =
          widget.sections.first.id;
    }
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _requiredValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _emailValidator(
    String? value,
  ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(
    String? value,
  ) {
    final phone =
        value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final digits = phone.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.length < 10 ||
        digits.length > 15) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        _selectedDateOfBirth ??
            DateTime(
              now.year - 18,
              now.month,
              now.day,
            );

    final picked =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate:
          DateTime(1950),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth =
            picked;
      });
    }
  }

  String _formatDate(
    DateTime date,
  ) {
    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  List<StudentSectionOption>
      get _filteredSections {
    if (_selectedDepartmentId ==
        null) {
      return widget.sections;
    }

    final matching = widget.sections
        .where(
          (section) =>
              section.departmentId ==
              null ||
              section.departmentId ==
                  _selectedDepartmentId,
        )
        .toList();

    if (matching.isEmpty) {
      return widget.sections;
    }

    return matching;
  }

  void _onDepartmentChanged(
    int? value,
  ) {
    setState(() {
      _selectedDepartmentId =
          value;

      final validSections =
          _filteredSections;

      if (_selectedSectionId !=
              null &&
          !validSections.any(
            (section) =>
                section.id ==
                _selectedSectionId,
          )) {
        _selectedSectionId =
            validSections.isEmpty
                ? null
                : validSections.first.id;
      }
    });
  }

  Future<void> _submit() async {
    if (widget.isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (widget.departments.isNotEmpty &&
        _selectedDepartmentId ==
            null) {
      _showMessage(
        'Please select a department.',
      );
      return;
    }

    if (widget.sections.isNotEmpty &&
        _selectedSectionId == null) {
      _showMessage(
        'Please select a section.',
      );
      return;
    }

    if (_selectedSemester == null) {
      _showMessage(
        'Please select a semester.',
      );
      return;
    }

    final data = AddStudentData(
      rollNo:
          _rollNoController.text.trim(),
      name:
          _nameController.text.trim(),
      dob: _selectedDateOfBirth,
      phone:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      email:
          _emailController.text.trim(),
      semester:
          _selectedSemester!,
      departmentId:
          _selectedDepartmentId,
      sectionId:
          _selectedSectionId,
      status: _status,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(data);
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !widget.isLoading,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border:
            const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final value =
        _selectedDateOfBirth == null
            ? 'Select date of birth'
            : _formatDate(
                _selectedDateOfBirth!,
              );

    return InkWell(
      onTap: widget.isLoading
          ? null
          : _pickDateOfBirth,
      borderRadius:
          BorderRadius.circular(4),
      child: InputDecorator(
        decoration:
            const InputDecoration(
          labelText:
              'Date of Birth',
          prefixIcon: Icon(
            Icons
                .calendar_today_outlined,
          ),
          border:
              OutlineInputBorder(),
        ),
        child: Text(
          value,
          style: theme
              .textTheme
              .bodyLarge
              ?.copyWith(
            color:
                _selectedDateOfBirth ==
                        null
                    ? theme
                        .colorScheme
                        .onSurfaceVariant
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<
        String>(
      initialValue: _status,
      decoration:
          const InputDecoration(
        labelText: 'Status',
        prefixIcon:
            Icon(
          Icons
              .toggle_on_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'ACTIVE',
          child: Text('Active'),
        ),
        DropdownMenuItem(
          value: 'INACTIVE',
          child: Text('Inactive'),
        ),
      ],
      onChanged:
          widget.isLoading
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _status = value;
                  });
                },
    );
  }

  Widget _buildFeedback(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    if (widget.errorMessage !=
            null &&
        widget.errorMessage!
            .trim()
            .isNotEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(13),
        decoration:
            BoxDecoration(
          color: theme.colorScheme
              .errorContainer
              .withValues(
            alpha: 0.55,
          ),
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
              Icons
                  .error_outline,
              color: theme
                  .colorScheme
                  .error,
            ),
            const SizedBox(
              width: 9,
            ),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: theme
                    .textTheme
                    .bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.successMessage !=
            null &&
        widget.successMessage!
            .trim()
            .isNotEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(13),
        decoration:
            BoxDecoration(
          color: Colors.green
              .withValues(
            alpha: 0.08,
          ),
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
            const Icon(
              Icons
                  .check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(
              width: 9,
            ),
            Expanded(
              child: Text(
                widget
                    .successMessage!,
                style: theme
                    .textTheme
                    .bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<
        int>(
      initialValue:
          _selectedDepartmentId,
      decoration:
          const InputDecoration(
        labelText: 'Department',
        prefixIcon: Icon(
          Icons
              .account_tree_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items: widget.departments
          .map(
            (
              department,
            ) =>
                DropdownMenuItem<int>(
              value: department.id,
              child: Text(
                department.name,
                overflow:
                    TextOverflow
                        .ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged:
          widget.isLoading
              ? null
              : _onDepartmentChanged,
      validator: (_) {
        if (widget.departments
            .isEmpty) {
          return null;
        }

        return _selectedDepartmentId ==
                null
            ? 'Select a department'
            : null;
      },
    );
  }

  Widget _buildSectionDropdown() {
    final sections =
        _filteredSections;

    final validSelected =
        sections.any(
      (section) =>
          section.id ==
          _selectedSectionId,
    );

    return DropdownButtonFormField<int>(
      initialValue:
          validSelected
              ? _selectedSectionId
              : null,
      decoration:
          const InputDecoration(
        labelText: 'Section',
        prefixIcon:
            Icon(
          Icons
              .groups_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items: sections
          .map(
            (
              section,
            ) =>
                DropdownMenuItem<int>(
              value: section.id,
              child: Text(
                section.displayName,
                overflow:
                    TextOverflow
                        .ellipsis,
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
      validator: (_) {
        if (widget.sections
            .isEmpty) {
          return null;
        }

        return _selectedSectionId ==
                null
            ? 'Select a section'
            : null;
      },
    );
  }

  Widget _buildSemesterDropdown() {
    return DropdownButtonFormField<int>(
      initialValue:
          _selectedSemester,
      decoration:
          const InputDecoration(
        labelText: 'Semester',
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
            (semester) =>
                DropdownMenuItem<int>(
              value: semester,
              child: Text(
                'Semester $semester',
              ),
            ),
          )
          .toList(),
      onChanged:
          widget.isLoading
              ? null
              : (value) {
                  setState(() {
                    _selectedSemester =
                        value;
                  });
                },
      validator: (_) {
        return _selectedSemester ==
                null
            ? 'Select a semester'
            : null;
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
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
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .person_add_alt_1_outlined,
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
                          'Student Details',
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Create the student master record and enrollment information.',
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
                height: 22,
              ),
              LayoutBuilder(
                builder:
                    (
                  context,
                  constraints,
                ) {
                  final compact =
                      constraints
                              .maxWidth <
                          700;

                  final rollNo =
                      _buildTextField(
                    label:
                        'Roll Number',
                    hint:
                        'Example: CS001',
                    controller:
                        _rollNoController,
                    icon: Icons
                        .confirmation_number_outlined,
                    textInputAction:
                        TextInputAction
                            .next,
                    validator:
                        _requiredValidator,
                  );

                  final name =
                      _buildTextField(
                    label:
                        'Full Name',
                    hint:
                        'Student full name',
                    controller:
                        _nameController,
                    icon: Icons
                        .person_outline,
                    textInputAction:
                        TextInputAction
                            .next,
                    validator:
                        _requiredValidator,
                  );

                  final email =
                      _buildTextField(
                    label:
                        'Email',
                    hint:
                        'student@example.com',
                    controller:
                        _emailController,
                    icon: Icons
                        .email_outlined,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    textInputAction:
                        TextInputAction
                            .next,
                    validator:
                        _emailValidator,
                  );

                  final phone =
                      _buildTextField(
                    label:
                        'Phone',
                    hint:
                        'Optional phone number',
                    controller:
                        _phoneController,
                    icon: Icons
                        .phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                    textInputAction:
                        TextInputAction
                            .next,
                    validator:
                        _phoneValidator,
                  );

                  final department =
                      _buildDepartmentDropdown();

                  final section =
                      _buildSectionDropdown();

                  final semester =
                      _buildSemesterDropdown();

                  final dob =
                      _buildDateField(
                    context,
                  );

                  if (compact) {
                    return Column(
                      children: [
                        rollNo,
                        const SizedBox(
                          height: 14,
                        ),
                        name,
                        const SizedBox(
                          height: 14,
                        ),
                        email,
                        const SizedBox(
                          height: 14,
                        ),
                        phone,
                        const SizedBox(
                          height: 14,
                        ),
                        dob,
                        const SizedBox(
                          height: 14,
                        ),
                        department,
                        const SizedBox(
                          height: 14,
                        ),
                        section,
                        const SizedBox(
                          height: 14,
                        ),
                        semester,
                        const SizedBox(
                          height: 14,
                        ),
                        _buildStatusDropdown(),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: rollNo,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: name,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: email,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: phone,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child:
                                department,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: section,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child:
                                semester,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: dob,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      _buildStatusDropdown(),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      Icons
                          .info_outline,
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
                        'Student ID, department, semester and section are validated by the backend before the record is created.',
                        style: theme
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .end,
                children: [
                  OutlinedButton(
                    onPressed:
                        widget.isLoading
                            ? null
                            : widget
                                    .onCancel ??
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
                        widget.isLoading
                            ? null
                            : _submit,
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
                                    .person_add_outlined,
                              ),
                    label: Text(
                      widget.isLoading
                          ? 'Creating...'
                          : 'Create Student',
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Student'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed:
              widget.isLoading
                  ? null
                  : widget.onCancel ??
                      () =>
                          Navigator.of(
                            context,
                          ).maybePop(),
          icon:
              const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 950,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Add Student',
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
                    'Create a new student master record.',
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
                  if (widget
                              .errorMessage !=
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
                  _buildForm(
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

class AddStudentData {
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const AddStudentData({
    required this.rollNo,
    required this.name,
    this.dob,
    this.phone,
    required this.email,
    required this.semester,
    this.departmentId,
    this.sectionId,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'roll_no': rollNo,
      'name': name,
      'dob': dob?.toIso8601String(),
      'phone': phone,
      'email': email,
      'semester': semester,
      'department_id': departmentId,
      'section_id': sectionId,
      'status': status,
    };
  }
}

class StudentDepartmentOption {
  final int id;
  final String name;

  const StudentDepartmentOption({
    required this.id,
    required this.name,
  });
}

class StudentSectionOption {
  final int id;
  final String name;
  final int? semester;
  final int? departmentId;
  final String? academicYear;

  const StudentSectionOption({
    required this.id,
    required this.name,
    this.semester,
    this.departmentId,
    this.academicYear,
  });

  String get displayName {
    final parts = <String>[
      name,
    ];

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