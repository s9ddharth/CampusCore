import 'package:flutter/material.dart';

class EditStudentPage extends StatefulWidget {
  final StudentEditData student;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  final List<StudentEditDepartmentOption> departments;
  final List<StudentEditSectionOption> sections;

  final Future<void> Function(
    EditStudentData data,
  )? onSubmit;

  final VoidCallback? onCancel;

  const EditStudentPage({
    super.key,
    required this.student,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.departments = const [],
    this.sections = const [],
    this.onSubmit,
    this.onCancel,
  });

  @override
  State<EditStudentPage> createState() =>
      _EditStudentPageState();
}

class _EditStudentPageState
    extends State<EditStudentPage> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _rollNoController;

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _phoneController;

  DateTime? _selectedDateOfBirth;
  int? _selectedDepartmentId;
  int? _selectedSectionId;
  int? _selectedSemester;
  late String _status;

  final List<int> _semesterOptions =
      List.generate(
    8,
    (index) => index + 1,
  );

  @override
  void initState() {
    super.initState();

    _rollNoController =
        TextEditingController(
      text: widget.student.rollNo,
    );

    _nameController =
        TextEditingController(
      text: widget.student.name,
    );

    _emailController =
        TextEditingController(
      text: widget.student.email,
    );

    _phoneController =
        TextEditingController(
      text: widget.student.phone ?? '',
    );

    _selectedDateOfBirth =
        widget.student.dob;

    _selectedDepartmentId =
        widget.student.departmentId;

    _selectedSectionId =
        widget.student.sectionId;

    _selectedSemester =
        widget.student.semester;

    _status = widget.student.status;
  }

  @override
  void didUpdateWidget(
    covariant EditStudentPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.student.id !=
            widget.student.id ||
        oldWidget.student.rollNo !=
            widget.student.rollNo ||
        oldWidget.student.name !=
            widget.student.name ||
        oldWidget.student.email !=
            widget.student.email) {
      _rollNoController.text =
          widget.student.rollNo;
      _nameController.text =
          widget.student.name;
      _emailController.text =
          widget.student.email;
      _phoneController.text =
          widget.student.phone ?? '';

      _selectedDateOfBirth =
          widget.student.dob;
      _selectedDepartmentId =
          widget.student.departmentId;
      _selectedSectionId =
          widget.student.sectionId;
      _selectedSemester =
          widget.student.semester;
      _status =
          widget.student.status;
    }

    if (_selectedDepartmentId !=
            null &&
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

    final pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(email)) {
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

    final digits =
        phone.replaceAll(
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

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDateOfBirth =
          picked;
    });
  }

  String _formatDate(
    DateTime date,
  ) {
    final day = date.day
        .toString()
        .padLeft(
          2,
          '0',
        );

    final month = date.month
        .toString()
        .padLeft(
          2,
          '0',
        );

    return '$day/$month/${date.year}';
  }

  List<StudentEditSectionOption>
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

    return matching.isEmpty
        ? widget.sections
        : matching;
  }

  void _onDepartmentChanged(
    int? value,
  ) {
    setState(() {
      _selectedDepartmentId =
          value;

      final availableSections =
          _filteredSections;

      if (_selectedSectionId !=
              null &&
          !availableSections.any(
            (section) =>
                section.id ==
                _selectedSectionId,
          )) {
        _selectedSectionId =
            availableSections.isEmpty
                ? null
                : availableSections
                    .first
                    .id;
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

    if (_selectedSemester == null) {
      _showMessage(
        'Please select a semester.',
      );
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

    final data = EditStudentData(
      id: widget.student.id,
      rollNo:
          _rollNoController.text.trim(),
      name:
          _nameController.text.trim(),
      dob: _selectedDateOfBirth,
      phone:
          _phoneController.text
                  .trim()
                  .isEmpty
              ? null
              : _phoneController.text
                  .trim(),
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
          content:
              Text(message),
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
      enabled:
          !widget.isLoading,
      keyboardType:
          keyboardType,
      textInputAction:
          textInputAction,
      validator:
          validator,
      decoration:
          InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon),
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

    final hasDate =
        _selectedDateOfBirth !=
            null;

    return InkWell(
      onTap: widget.isLoading
          ? null
          : _pickDateOfBirth,
      borderRadius:
          BorderRadius.circular(4),
      child:
          InputDecorator(
        decoration:
            const InputDecoration(
          labelText:
              'Date of Birth',
          prefixIcon:
              Icon(
            Icons
                .calendar_today_outlined,
          ),
          border:
              OutlineInputBorder(),
        ),
        child: Text(
          hasDate
              ? _formatDate(
                  _selectedDateOfBirth!,
                )
              : 'Select date of birth',
          style: theme
              .textTheme
              .bodyLarge
              ?.copyWith(
            color: hasDate
                ? null
                : theme
                    .colorScheme
                    .onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<int>(
      initialValue:
          _selectedDepartmentId,
      decoration:
          const InputDecoration(
        labelText: 'Department',
        prefixIcon:
            Icon(
          Icons
              .account_tree_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items: widget.departments
          .map(
            (department) =>
                DropdownMenuItem<int>(
              value:
                  department.id,
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
          Icons.groups_outlined,
        ),
        border:
            OutlineInputBorder(),
      ),
      items: sections
          .map(
            (section) =>
                DropdownMenuItem<int>(
              value:
                  section.id,
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
          Icons.school_outlined,
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
      validator: (_) =>
          _selectedSemester ==
                  null
              ? 'Select a semester'
              : null,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
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
          child:
              Text('Active'),
        ),
        DropdownMenuItem(
          value: 'INACTIVE',
          child:
              Text('Inactive'),
        ),
      ],
      onChanged:
          widget.isLoading
              ? null
              : (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _status =
                        value;
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
                          .edit_note_outlined,
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
                          'Student Information',
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
                          'Update the student master record and enrollment details.',
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
                        'Student roll number',
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
                    icon:
                        Icons.person_outline,
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
                    icon:
                        Icons.email_outlined,
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
                    icon:
                        Icons.phone_outlined,
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

                  final status =
                      _buildStatusDropdown();

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
                        status,
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
                            child:
                                section,
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
                      status,
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
                        'Changes are submitted to the backend for validation before the student record is updated.',
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
                                    .save_outlined,
                              ),
                    label: Text(
                      widget.isLoading
                          ? 'Saving...'
                          : 'Save Changes',
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
            const Text(
          'Edit Student',
        ),
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
                    'Edit Student',
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
                    'Update ${widget.student.name}\'s information.',
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

class StudentEditData {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditData({
    required this.id,
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
      'id': id,
      'roll_no': rollNo,
      'name': name,
      'dob':
          dob?.toIso8601String(),
      'phone': phone,
      'email': email,
      'semester': semester,
      'department_id':
          departmentId,
      'section_id': sectionId,
      'status': status,
    };
  }
}

class StudentEditData {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditData({
    required this.id,
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
}

class StudentDepartmentOption {
  final int id;
  final String name;

  const StudentDepartmentOption({
    required this.id,
    required this.name,
  });
}

class StudentEditDepartmentOption {
  final int id;
  final String name;

  const StudentEditDepartmentOption({
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

class StudentEditSectionOption {
  final int id;
  final String name;
  final int? semester;
  final int? departmentId;
  final String? academicYear;

  const StudentEditSectionOption({
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

class StudentEditDataModel {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditDataModel({
    required this.id,
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
}

class StudentEditDataSource {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditDataSource({
    required this.id,
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
}

class StudentEditDataRecord {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditDataRecord({
    required this.id,
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
}

class StudentEditDataPayload {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditDataPayload({
    required this.id,
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
}

class StudentEditDataRequest {
  final int id;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int semester;
  final int? departmentId;
  final int? sectionId;
  final String status;

  const StudentEditDataRequest({
    required this.id,
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
}